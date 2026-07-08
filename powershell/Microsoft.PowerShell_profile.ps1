# PowerShell profile — deployed via dotter to
#   ~/.config/powershell/Microsoft.PowerShell_profile.ps1

# --- gwta: Git Worktree Add --------------------------------------------------
# Create (or refuse a duplicate) a worktree for a remote branch or a GitHub PR,
# then cd into it. PowerShell port of the zsh `gwta` in zsh/.zshrc.
#   gwta <branch>       branch mode (bare, non-numeric arg)
#   gwta -b <branch>    branch mode, forced (e.g. a branch named "42")
#   gwta <number>       PR mode (bare, all-digits arg)
#   gwta -p <number>    PR mode, forced
#   gwta ls | list      list origin branches + their open PRs
#   gwta -h             usage
# The worktree is created at <repo-root>/../<slug> (all '/' in the branch name
# replaced with '-') so worktrees sit as flat siblings of the main clone.
# Same-repo PRs only (fork PRs are refused). In the listing, open (non-draft)
# PRs are coloured green; drafts and plain branches keep the default colour.
# (PowerShell uses single-dash flags -b/-p/-h, unlike the zsh --long forms.)

function _gwta_err {
    param([string]$Message)
    Write-Host "gwta: $Message" -ForegroundColor Red
}

function _gwta_list {
    $ErrorActionPreference = 'Continue'

    $null = git rev-parse --show-toplevel 2>$null
    if ($LASTEXITCODE -ne 0) { _gwta_err 'not inside a git repository'; return }

    # One round-trip to origin for every ref, including the HEAD symref.
    $remoteRefs = git ls-remote --symref origin 2>$null
    if ($LASTEXITCODE -ne 0) { _gwta_err 'could not reach origin'; return }

    $defaultBranch = $null
    $branches = [System.Collections.Generic.List[string]]::new()
    foreach ($line in $remoteRefs) {
        if ($line -match '^ref:\s+refs/heads/(\S+)\s+HEAD$') { $defaultBranch = $Matches[1]; continue }
        if ($line -notmatch '^ref:' -and $line -match 'refs/heads/(\S+)$') { $branches.Add($Matches[1]) }
    }

    # Open, same-repo PRs keyed by head branch.
    $prMap = @{}
    if (Get-Command gh -ErrorAction SilentlyContinue) {
        $raw = gh pr list --state open --limit 300 --json number,headRefName,isDraft,title,isCrossRepository 2>$null
        if ($LASTEXITCODE -eq 0 -and $raw) {
            foreach ($pr in ($raw -join "`n" | ConvertFrom-Json)) {
                if (-not $pr.isCrossRepository) { $prMap[$pr.headRefName] = $pr }
            }
        }
    }

    # Which origin branches have a local worktree checked out?
    $hasWorktree = @{}
    foreach ($line in (git worktree list --porcelain 2>$null)) {
        if ($line -match '^branch refs/heads/(.+)$') { $hasWorktree[$Matches[1]] = $true }
    }

    # Colour open (non-draft) PRs green on a terminal; drafts keep the default
    # colour. GWTA_FORCE_COLOR forces colour on (e.g. `gwta ls | less -R`).
    $useColor = $env:GWTA_FORCE_COLOR -or (-not [Console]::IsOutputRedirected)
    $esc = [char]27
    $green = if ($useColor) { "$esc[32m" } else { '' }
    $reset = if ($useColor) { "$esc[0m" } else { '' }
    $bold = if ($useColor) { "$esc[1m" } else { '' }

    # Partition into with/without worktree, each split into PR rows + plain.
    $wtPr = [System.Collections.Generic.List[object]]::new()
    $wtPlain = [System.Collections.Generic.List[string]]::new()
    $noPr = [System.Collections.Generic.List[object]]::new()
    $noPlain = [System.Collections.Generic.List[string]]::new()
    foreach ($b in $branches) {
        if ($defaultBranch -and $b -eq $defaultBranch) { continue }
        $wt = $hasWorktree.ContainsKey($b)
        if ($prMap.ContainsKey($b)) {
            if ($wt) { $wtPr.Add($prMap[$b]) } else { $noPr.Add($prMap[$b]) }
        }
        else {
            if ($wt) { $wtPlain.Add($b) } else { $noPlain.Add($b) }
        }
    }

    if ($wtPr.Count -eq 0 -and $wtPlain.Count -eq 0 -and $noPr.Count -eq 0 -and $noPlain.Count -eq 0) {
        _gwta_err 'no branches on origin (besides its default)'; return
    }

    # Order a group's lines: PRs newest-number-first (open ones green), then plain (alpha).
    $emit = {
        param($rows, $plain)
        foreach ($pr in ($rows | Sort-Object { [int]$_.number } -Descending)) {
            $text = "#$($pr.number) [$($pr.headRefName)]: $($pr.title)"
            if ($pr.isDraft) { $text } else { "$green$text$reset" }
        }
        foreach ($b in ($plain | Sort-Object)) { "[$b]" }
    }

    $printed = $false
    if ($wtPr.Count -or $wtPlain.Count) {
        "$bold" + 'Branches with worktrees' + "$reset"
        & $emit $wtPr $wtPlain
        $printed = $true
    }
    if ($noPr.Count -or $noPlain.Count) {
        if ($printed) { '' }
        "$bold" + 'Branches without worktrees' + "$reset"
        & $emit $noPr $noPlain
    }
}

function gwta {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Target,
        [Alias('b')][string]$Branch,
        [Alias('p')][string]$PullRequest,
        [Alias('h')][switch]$Help
    )
    $ErrorActionPreference = 'Continue'
    $usage = 'usage: gwta <branch> | -b <branch> | <pr-number> | -p <pr-number> | ls|list'

    if ($Help) { Write-Host $usage; return }

    # Determine mode + argument.
    $mode = $null
    $arg = $null
    if ($Branch) { $mode = 'branch'; $arg = $Branch }
    elseif ($PullRequest) { $mode = 'pr'; $arg = $PullRequest }
    elseif ($Target) {
        if ($Target -in @('ls', 'list')) { _gwta_list; return }
        $arg = $Target
        $mode = if ($Target -match '^\d+$') { 'pr' } else { 'branch' }
    }
    else {
        _gwta_err 'missing branch/PR argument'
        Write-Host $usage
        return
    }

    # Must be inside a git repository.
    $root = git rev-parse --show-toplevel 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $root) { _gwta_err 'not inside a git repository'; return }

    # Resolve the branch name.
    if ($mode -eq 'pr') {
        if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
            _gwta_err 'gh (GitHub CLI) is required for PR mode'; return
        }
        $raw = gh pr view $arg --json headRefName,isCrossRepository 2>$null
        if ($LASTEXITCODE -ne 0 -or -not $raw) { _gwta_err "could not look up PR #$arg"; return }
        $pr = $raw -join "`n" | ConvertFrom-Json
        if ($pr.isCrossRepository) {
            _gwta_err "PR #$arg is from a fork (cross-repository); not supported"; return
        }
        $branch = $pr.headRefName
        if (-not $branch) { _gwta_err "could not determine branch for PR #$arg"; return }
        Write-Host "gwta: PR #$arg -> branch '$branch'"
    }
    else {
        $branch = $arg
    }

    # Destination: a flat sibling of the repo root.
    $slug = $branch -replace '/', '-'
    $dest = Join-Path (Split-Path -Parent $root) $slug

    # Refuse if a worktree already exists for this branch or the path is taken.
    $worktrees = git worktree list --porcelain
    if ($worktrees -contains "branch refs/heads/$branch") {
        _gwta_err "a worktree for '$branch' already exists (see: git worktree list)"; return
    }
    if (Test-Path -LiteralPath $dest) {
        _gwta_err "destination '$dest' already exists"; return
    }

    # Pull the branch from origin.
    git fetch origin $branch 2>$null
    if ($LASTEXITCODE -ne 0) { _gwta_err "branch '$branch' not found on origin"; return }
    git show-ref --verify --quiet "refs/remotes/origin/$branch"
    if ($LASTEXITCODE -ne 0) { _gwta_err "'origin/$branch' not found after fetch"; return }

    # Create the worktree (reuse an existing local branch if there is one).
    git show-ref --verify --quiet "refs/heads/$branch"
    if ($LASTEXITCODE -eq 0) {
        git worktree add $dest $branch
    }
    else {
        git worktree add --track -b $branch $dest "origin/$branch"
    }
    if ($LASTEXITCODE -ne 0) { return }

    Set-Location -LiteralPath $dest
    Write-Host "gwta: switched to worktree at $dest"
}
