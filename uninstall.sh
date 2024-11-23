#!/bin/bash
# fzf-cd uninstall script

# Remove the entire fzf-cd directory
rm -rf "$HOME/.local/lib/fzf-cd"

# Scan and remove the fzf-cd snippet from the user's .zshrc file
sed -i '/# Fuzzy Directory Navigator Configuration/,/bindkey.*___fzf_cd/d' ~/.zshrc

# Alternative more precise removal in case the first method fails
sed -i '/# Fuzzy Directory Navigator Configuration\n/{N;N;N;N;N;N;N;d}' ~/.zshrc

echo "fzf-cd has been uninstalled."
