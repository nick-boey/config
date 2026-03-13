# Agent Guidelines for Config Repository

This repository contains personal configuration files (dotfiles) for various development tools and window managers across Windows and Linux environments. This guide helps AI coding agents understand the repository structure, conventions, and workflows.

## Repository Overview

**Type**: Dotfiles/Configuration repository  
**Primary Purpose**: Cross-platform configuration management using dotter  
**Platforms**: Windows (primary), Linux (Arch-based)  
**Configuration Manager**: [dotter](https://github.com/SuperCuber/dotter)

## Directory Structure

```
config/
├── .dotter/              # Dotter configuration files
│   ├── global.toml      # Windows-specific file mappings
│   ├── linux.toml       # Linux-specific file mappings
│   └── cache.toml       # Auto-generated cache (git-ignored)
├── nvim/                # Neovim configuration (LazyVim-based)
├── helix/               # Helix editor configuration
├── wezterm/             # WezTerm terminal configuration
├── komorebi/            # Komorebi window manager (Windows)
├── hypr/                # Hyprland configuration (Linux)
├── waybar/              # Waybar status bar (Linux)
├── yasb/                # YASB status bar (Windows)
├── yazi/                # Yazi file manager
├── lazygit/             # LazyGit configuration
├── gh/                  # GitHub CLI configuration
└── install.ps1          # Windows software installation script
```

## Build/Lint/Test Commands

This is a configuration repository without traditional build/test commands. Key operations:

### Dotter Deployment
```bash
# Deploy configurations (run from repository root)
dotter deploy

# Deploy with specific profile
dotter deploy -p linux
dotter deploy -p windows
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

# Check Lua syntax (for nvim/wezterm)
lua -c "dofile('nvim/init.lua')"

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
[nvim.files]
nvim = "~/.config/nvim"

[yazi.files]
yazi = "~/.config/yazi"

# Avoid
[nvim.files]
nvim="~/.config/nvim"
[yazi.files]
yazi="~/.config/yazi"
```

#### Lua Files (nvim/, wezterm/)
- **Indentation**: 2 spaces (enforced by stylua)
- **Line width**: 120 characters max
- **Quotes**: Prefer single quotes for strings
- **Formatting**: Use stylua with config in `nvim/stylua.toml`
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

#### PowerShell Scripts (install.ps1)
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
  - Scripts: `select.sh`, `refresh.sh`, `install.ps1`
- **Directories**: Lowercase, match application name
- **Variables (Lua)**: snake_case
- **Variables (PowerShell)**: PascalCase
- **Functions (Lua)**: snake_case

## Common Operations

### Adding a New Application Configuration

1. Create directory matching application name
2. Add configuration files
3. Update appropriate dotter TOML file:
   - `.dotter/global.toml` for Windows
   - `.dotter/linux.toml` for Linux
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
5. **Application-specific**: Some apps auto-format configs (e.g., zed/settings.json)

## Tools and Dependencies

- **dotter**: Configuration deployment
- **nvim**: LazyVim-based Neovim setup
- **helix**: Alternative modal editor
- **stylua**: Lua formatter
- **shellcheck**: Shell script linter (recommended)
