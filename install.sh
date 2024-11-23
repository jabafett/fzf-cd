#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if a command exists
check_dependency() {
  if ! command -v "$1" &>/dev/null; then
    echo -e "${RED}Error: $1 is not installed${NC}"
    echo "Please install $1 first"
    return 1
  fi
  echo -e "${GREEN}✓ Found $1${NC}"
  return 0
}

# Function to create directory if it doesn't exist
create_dir_if_missing() {
  if [ ! -d "$1" ]; then
    mkdir -p "$1"
    echo -e "${GREEN}Created directory: $1${NC}"
  fi
}

# Banner
echo -e "${YELLOW}"
echo "====================================="
echo "   FZF Directory Navigator Install"
echo "====================================="
echo -e "${NC}"

# Check dependencies
echo "Checking dependencies..."
deps=(zsh fzf fd bat lsd)
failed=0
for dep in "${deps[@]}"; do
  if ! check_dependency "$dep"; then
    failed=1
  fi
done

if [ $failed -eq 1 ]; then
  echo -e "${RED}Please install missing dependencies and try again${NC}"
  exit 1
fi

# Get directory of this script
script_dir=$(dirname "$0")

# Check if this is a Zinit installation
if [[ -n "$ZINIT" ]]; then
  # Zinit handles installation through its own mechanisms
  echo -e "\n${YELLOW}Zinit installation detected${NC}"
  echo -e "Please install this plugin through Zinit by adding:"
  echo -e "${GREEN}zinit ice wait lucid${NC}"
  echo -e "${GREEN}zinit load jabafett/fzf-cd${NC}"
  echo -e "to your .zshrc file"
  exit 0
fi

# Continue with standard installation for non-Zinit case
echo "Setting up directories..."
create_dir_if_missing "$HOME/.local/bin"
create_dir_if_missing "$HOME/.local/lib/fzf-cd"

# Copy scripts to their locations
echo "Installing scripts..."
cp "$script_dir/fzf-cd-lib" "$HOME/.local/lib/fzf-cd"
cp "$script_dir/fzf-cd-preview" "$HOME/.local/lib/fzf-cd"

# Make scripts executable
chmod +x "$HOME/.local/lib/fzf-cd/fzf-cd-lib"
chmod +x "$HOME/.local/lib/fzf-cd/fzf-cd-preview"

# Default key binding
DEFAULT_KEYBIND="^f" # Ctrl+F

# Ask user for key binding
echo -e "\nWhat key binding would you like to use for the fuzzy directory navigator?"
echo "Default is Ctrl+F (^f). Press enter to use default, or enter a new binding:"
read -r keybind
keybind=${keybind:-$DEFAULT_KEYBIND}

# Create zsh widget configuration
zsh_config="\n# Fuzzy Directory Navigator Configuration
source \"$HOME/.local/lib/fzf-cd/fzf-cd-lib\"
___fzf_cd() {
  __fzf_cd "$@"
  zle accept-line
}
zle -N ___fzf_cd
bindkey '$keybind' ___fzf_cd"

# Add configuration to .zshrc if not already present
if ! grep -q "___fzf_cd" "$HOME/.zshrc"; then
  echo -e "$zsh_config" >>"$HOME/.zshrc"
  echo -e "${GREEN}Added zsh configuration to ~/.zshrc${NC}"
else
  echo -e "${YELLOW}Zsh configuration already exists in ~/.zshrc${NC}"
fi

# Final instructions
echo -e "\n${GREEN}Installation complete!${NC}"
echo -e "${YELLOW}Please restart your shell or run: source ~/.zshrc${NC}"
echo -e "\nUsage:"
echo -e "  - Press ${GREEN}$keybind${NC} to activate the fuzzy directory navigator"
echo -e "  - Use ${GREEN}Ctrl+R${NC} to search current directory (including files)"
echo -e "  - Use ${GREEN}Ctrl+E${NC} to open files in your default editor"
echo -e "  - Press ${GREEN}Enter${NC} to change to selected directory"
echo -e "  - Use ${GREEN}Ctrl+C${NC} or ${GREEN}Esc${NC} to cancel"
