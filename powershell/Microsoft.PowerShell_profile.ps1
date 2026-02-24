$Env:YAZI_FILE_ONE = 'C:\Program Files\Git\usr\bin\file.exe'
Invoke-Expression (& { (zoxide init powershell | Out-String) })

function y {
    $tmp = [System.IO.Path]::GetTempFileName()
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp -Encoding UTF8
    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
        Set-Location -LiteralPath ([System.IO.Path]::GetFullPath($cwd))
    }
    Remove-Item -Path $tmp
}

function kswitch{
    komorebic stop
    komorebic start --whkd
    exit
  }

function ccd {
    claude --dangerously-skip-permissions
}

function ccdc {
    claude --dangerously-skip-permissions --continue
}

Set-Alias brush "C:\Users\nboey\Documents\src\computer-vision\brush\target\release\brush_app.exe"
Set-Alias colmap "C:\Users\nboey\Documents\src\computer-vision\colmap-bin\COLMAP.bat"
Set-Alias glomap "C:\Users\nboey\AppData\Local\GLOMAP\glomap.exe"

Set-PSReadLineKeyHandler -Chord "Shift+Tab" -Function ForwardWord

$env:EDITOR = "nvim.exe"
$env:ENABLE_LSP_TOOL = 1

oh-my-posh init pwsh --config ~/.omp/nick.omp.toml | Invoke-Expression
