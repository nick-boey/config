$PackageString = "
Microsoft.VisualStudio.2022.Community,
Microsoft.VisualStudioCode,
Microsoft.PowerToys,
Microsoft.PowerShell,
Docker.DockerDesktop,
Figma.Figma,
OpenJS.NodeJS.LTS,
JetBrains.RustRover,
JetBrains.Rider,
Valve.Steam,
wez.wezterm,
Helix.Helix,
Neovim.Neovim,
sxyazi.yazi
Spotify.Spotify,
Rustlang.Rustup,
MikTex.MikTex,
JesseDuffield.lazygit,
Typst.Typst,
ajeetdsouze.zoxide,
Obsidian.Obsidian,
junegunn.fzf,
sharkdp.fd,
Python.Python.3.13,
7zip.7zip,
Git.Git,
"

$Delimiter = ","

$SoftwareList = $PackageString.Split($Delimiter)

Write-Host "Starting Winget package installation..."

foreach ($Software in $SoftwareList) {
    $Software = $Software.Trim()

    if (-not [string]::IsNullOrEmpty($Software)) {
        Write-Host "Attempting to install '$Software'..."

        try {
            # Execute Winget install command
            $wingetResult = winget install --accept-source-agreements --accept-package-agreements "$Software" -h -e 2>&1

            # Check the exit code
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Successfully installed '$Software'." -ForegroundColor Green
            } elseif ($wingetResult -like "*No package found matching input criteria*") {
                Write-Warning "Package '$Software' not found in Winget repositories."
            } else {
                Write-Error "Failed to install '$Software'. Error details:"
                Write-Error $wingetResult
            }
        } catch {
            Write-Error "An unexpected error occurred during the installation of '$Software':"
            Write-Error $_
        }
        Write-Host "" 
    } else {
        Write-Warning "Skipping empty package name."
    }
}

Write-Host "Winget package installation process completed."
