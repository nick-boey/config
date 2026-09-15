# Configurations

My configuration files. This repo is the source of truth — edit here, then
`dotter deploy`, never the other way around.

## Setup on a new machine

### 1. Install software

**macOS** — `./install-macos.sh` (Homebrew; installs `dotter` too)
**Windows** — `.\install-windows.ps1` (winget; installs `dotter` via cargo at the end)

### 2. Deploy configs

Create `.dotter/local.toml` (git-ignored, machine-local) pointing at the right
OS file and listing the packages you want:

```toml
includes = [".dotter/macos.toml"]   # or linux.toml / windows.toml

packages = ["zsh", "yazi", "powershell", "helix", "zed", "gh", "lazygit", "aerospace"]
```

Then, from the repo root:

```sh
dotter deploy
```

Every deploy path is OS-specific, so `.dotter/global.toml` is intentionally
empty — all mappings live in `macos.toml`, `linux.toml` and `windows.toml`.

## Secrets

API keys and license keys are **never** committed. They live outside the repo
and are sourced at the end of the shell profile:

- zsh — `~/.zshrc.local`
- PowerShell — `local.ps1` next to `$PROFILE`

## WIP - Sunset colour scheme

- #191919 - Background colour
- #BCE3Df - Light blue
- #B8CB8E - Light green
- #CE9FA3 - Rosy brown
- #FFBA9B - Peach
- #46353F - Dark purple

## TODO

- [ ] Add Rider configuration
