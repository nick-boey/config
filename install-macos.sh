#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Check for Homebrew, install if missing
if ! command -v brew &>/dev/null; then
  echo -e "${YELLOW}Homebrew not found. Installing...${NC}"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo -e "${GREEN}Homebrew found.${NC}"
fi

echo "Updating Homebrew..."
brew update

# CLI formulae
formulae=(
  git
  node
  python@3.13
  fzf
  fd
  rustup
  typst
  lazygit
  neovim
  yazi
  helix
  zoxide
  7zip
)

# GUI casks
casks=(
  visual-studio-code
  docker
  figma
  steam
  spotify
  obsidian
  rider
  rustrover
  ghostty
  zed
)

failed=()

echo ""
echo "Installing CLI formulae..."
for formula in "${formulae[@]}"; do
  echo "Attempting to install '$formula'..."
  if brew install "$formula" 2>&1; then
    echo -e "${GREEN}Successfully installed '$formula'.${NC}"
  else
    echo -e "${RED}Failed to install '$formula'.${NC}"
    failed+=("$formula")
  fi
  echo ""
done

echo "Installing casks..."
for cask in "${casks[@]}"; do
  echo "Attempting to install '$cask'..."
  if brew install --cask "$cask" 2>&1; then
    echo -e "${GREEN}Successfully installed '$cask'.${NC}"
  else
    echo -e "${RED}Failed to install '$cask'.${NC}"
    failed+=("$cask")
  fi
  echo ""
done

echo "==============================="
if [[ ${#failed[@]} -eq 0 ]]; then
  echo -e "${GREEN}All packages installed successfully.${NC}"
else
  echo -e "${YELLOW}The following packages failed to install:${NC}"
  for pkg in "${failed[@]}"; do
    echo -e "${RED}  - $pkg${NC}"
  done
fi
echo "Homebrew package installation process completed."
