# Agent Guidelines for Config Repository

This repository contains personal configuration files (dotfiles) for various development tools and window managers across Windows and Linux environments. This guide helps AI coding agents understand the repository structure, conventions, and workflows.

## Repository Overview

**Type**: Dotfiles/Configuration repository  
**Primary Purpose**: Cross-platform configuration management using dotter  
**Platforms**: Windows, macOS, Linux (Arch-based)  
**Configuration Manager**: [dotter](https://github.com/SuperCuber/dotter)

## Directory Structure

```
config/
├── .dotter/              # Dotter configuration files
│   ├── global.toml      # Intentionally empty (all paths are OS-specific)
│   ├── macos.toml       # macOS file mappings
│   ├── linux.toml       # Linux file mappings
│   ├── windows.toml     # Windows file mappings
│   └── cache.toml       # Auto-generated cache (git-ignored)
├── helix/               # Helix editor configuration
├── wezterm/             # WezTerm terminal configuration (Windows)
├── ghostty/             # Ghostty terminal configuration (macOS)
├── komorebi/            # Komorebi window manager (Windows)
├── hypr/                # Hyprland configuration (Linux)
├── waybar/              # Waybar status bar (Linux)
├── yasb/                # YASB status bar (Windows)
├── yazi/                # Yazi file manager
├── lazygit/             # LazyGit configuration
├── gh/                  # GitHub CLI configuration
├── aerospace/           # AeroSpace window manager (macOS)
├── install-macos.sh     # macOS software installation script (Homebrew)
└── install-windows.ps1  # Windows software installation script (winget)
```

## Build/Lint/Test Commands

This is a configuration repository without traditional build/test commands. Key operations:

### Dotter Deployment
```bash
# Deploy configurations (run from repository root)
dotter deploy

# Which OS mappings apply is set per-machine in .dotter/local.toml
# (git-ignored) via `includes`, not by a command-line flag:
#   includes = [".dotter/macos.toml"]   # or linux.toml / windows.toml
```

### Manual Testing
Test individual configurations by:
1. Deploying with dotter
2. Opening the relevant application
3. Verifying configuration loads without errors

### Validation
```bash
# Check TOML syntax
# Use editor LSP or tools like taplo

# Check Lua syntax (wezterm)
lua -c "dofile('wezterm/.wezterm.lua')"

# Check shell scripts
shellcheck waybar/scripts/*.sh
```

## Code Style Guidelines

### General Principles
- **Simplicity**: Favor simple, readable configurations over complex abstractions
- **Cross-platform awareness**: Be mindful of Windows vs Linux differences
- **Comments**: Add comments for non-obvious configurations or workarounds

### File-Type Specific Guidelines

#### TOML Files (.dotter/*, yazi/, helix/)
- Use 2-space indentation
- Group related settings with blank lines
- Use inline tables sparingly, prefer expanded format
- Quote strings when necessary

```toml
# Good
[helix.files]
helix = "~/.config/helix"

[yazi.files]
yazi = "~/.config/yazi"

# Avoid
[helix.files]
helix="~/.config/helix"
[yazi.files]
yazi="~/.config/yazi"
```

#### Lua Files (wezterm/)
- **Indentation**: 2 spaces (enforced by stylua)
- **Line width**: 120 characters max
- **Quotes**: Prefer single quotes for strings
- **Tables**: Trailing commas in multiline tables

```lua
-- Good
local config = {
  setting = 'value',
  another = true,
}

-- Avoid
local config = {setting="value",another=true}
```

#### Shell Scripts (waybar/scripts/)
- Use `#!/bin/bash` shebang
- 2-space or 4-space indentation (be consistent within file)
- Quote variables: `"$variable"`
- Use `[[ ]]` for conditionals, not `[ ]`

```bash
# Good
if [[ "$selected_wallpaper" == "$ASSETS/main.png" ]]; then
    echo "Selected main theme"
fi

# Avoid
if [ $selected_wallpaper = "$ASSETS/main.png" ]; then
  echo "Selected main theme"
fi
```

#### PowerShell Scripts (install-windows.ps1, powershell/)
- PascalCase for variables: `$PackageString`, `$SoftwareList`
- 4-space indentation
- Use try-catch for error handling
- Check `$LASTEXITCODE` after external commands
- Use `Write-Host`, `Write-Warning`, `Write-Error` appropriately

```powershell
# Good
try {
    $wingetResult = winget install "$Software" -h -e 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Successfully installed '$Software'." -ForegroundColor Green
    }
} catch {
    Write-Error "An unexpected error occurred: $_"
}
```

#### JSON Files (komorebi/, zed/)
- 2-space indentation
- Use trailing commas where permitted
- Alphabetize keys when logical

#### YAML Files (yasb/, lazygit/, gh/)
- 2-space indentation
- Use `---` document separator if multiple documents
- Prefer flow style for short arrays/objects

## Naming Conventions

- **Files**: Use lowercase with hyphens or underscores
  - Config files: `config.toml`, `config.yml`
  - Scripts: `select.sh`, `refresh.sh`, `install-windows.ps1`
- **Directories**: Lowercase, match application name
- **Variables (Lua)**: snake_case
- **Variables (PowerShell)**: PascalCase
- **Functions (Lua)**: snake_case

## Common Operations

### Adding a New Application Configuration

1. Create directory matching application name
2. Add configuration files
3. Update appropriate dotter TOML file:
   - `.dotter/macos.toml` for macOS
   - `.dotter/linux.toml` for Linux
   - `.dotter/windows.toml` for Windows
   (`global.toml` stays empty: every target path differs per OS)
4. Test with `dotter deploy`
5. Commit with message format: "Add [app] config"

### Modifying Existing Configuration

1. Edit configuration file directly
2. Test by redeploying: `dotter deploy`
3. Verify in application
4. Commit with message format: "Update [feature/setting]"

Example commit messages (from history):
- "Fix wezterm config"
- "Update yasb menu transparencies"
- "Add helix to Windows setup"
- "Remove unused configs"

## Platform-Specific Notes

### Windows
- Use PowerShell for scripts when possible
- Configurations typically in `~/AppData/Local` or `~/AppData/Roaming`
- Window manager: Komorebi
- Status bar: YASB
- Terminal: WezTerm

### macOS
- Use bash/zsh for scripts
- Configurations in `~/.config/`, except apps that use
  `~/Library/Application Support/` (e.g. lazygit)
- Window manager: AeroSpace
- Terminal: Ghostty (kept in step with wezterm/: same theme and pane keys)

### Linux
- Use bash for scripts
- Configurations in `~/.config/`
- Window manager: Hyprland
- Status bar: Waybar
- Terminal: Kitty or WezTerm

## Error Handling

- Always test configuration changes before committing
- For scripts, handle errors explicitly with try-catch or conditionals
- Log errors meaningfully for debugging
- Don't commit broken configurations

## Common Pitfalls

1. **Path separators**: Windows uses `\`, Linux uses `/`
2. **Line endings**: Maintain consistent CRLF (Windows) or LF (Linux)
3. **Case sensitivity**: Remember Linux filesystems are case-sensitive
4. **Dotter cache**: Regenerate after manual file moves with `dotter deploy`
5. **Application-specific**: Some apps auto-format configs (e.g., zed/settings.json).
   These rewrite the deployed file in place; since it is a symlink back here,
   the repo picks the change up — review it before committing rather than
   reverting it.
6. **Ghostty reads two paths on macOS**: `~/.config/ghostty/config` (this
   repo) and `~/Library/Application Support/com.mitchellh.ghostty/config.ghostty`.
   The Application Support one is loaded **second and wins**. Ghostty recreates
   it as an empty file, which is inert — but if it ever gains content it will
   silently override this repo. Keep it empty; edit `ghostty/config` here.
   (`ghostty +edit-config` correctly opens the repo file.)
7. **Secrets**: never commit API keys or license keys. They belong in
   `~/.zshrc.local` (zsh) or `local.ps1` next to `$PROFILE` (PowerShell),
   both sourced at the end of the committed profile.

## Tools and Dependencies

- **dotter**: Configuration deployment
- **helix**: Alternative modal editor
- **stylua**: Lua formatter
- **shellcheck**: Shell script linter (recommended)
