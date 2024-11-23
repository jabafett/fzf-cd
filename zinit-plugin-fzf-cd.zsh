#!/usr/bin/env zsh

# Standard hash for plugin managers
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"
PLUGIN_DIR="${0:h}"

# Declare dependencies if not already installed
if (( ! $+commands[fzf] )); then
    zinit ice as"command" from"gh-r"
    zinit load junegunn/fzf
fi

if (( ! $+commands[fd] )); then
    zinit ice as"command" from"gh-r" mv"fd* -> fd" pick"fd/fd"
    zinit load @sharkdp/fd
fi

if (( ! $+commands[bat] )); then
    zinit ice as"command" from"gh-r" mv"bat* -> bat" pick"bat/bat"
    zinit load @sharkdp/bat
fi

if (( ! $+commands[lsd] )); then
    zinit ice as"command" from"gh-r" mv"lsd* -> lsd" pick"lsd/lsd"
    zinit load Peltoche/lsd
fi

# Ensure plugin directory exists
if [[ ! -d "${PLUGIN_DIR}/.local/lib/fzf-cd" ]]; then
    mkdir -p "${PLUGIN_DIR}/.local/lib/fzf-cd" || {
        echo "Failed to create plugin directory" >&2
        return 1
    }
fi

# Copy and update scripts with error handling
for script in fzf-cd-lib fzf-cd-preview; do
    if [[ ! -f "${PLUGIN_DIR}/.local/lib/fzf-cd/${script}" || \
          "${PLUGIN_DIR}/${script}" -nt "${PLUGIN_DIR}/.local/lib/fzf-cd/${script}" ]]; then
        cp "${PLUGIN_DIR}/${script}" "${PLUGIN_DIR}/.local/lib/fzf-cd/" || {
            echo "Failed to copy ${script}" >&2
            return 1
        }
        chmod +x "${PLUGIN_DIR}/.local/lib/fzf-cd/${script}" || {
            echo "Failed to make ${script} executable" >&2
            return 1
        }
    fi
done

# Add plugin directory to fpath for completions
[[ -d "${PLUGIN_DIR}/functions" ]] && fpath=("${PLUGIN_DIR}/functions" $fpath)

# Source the main library
if [[ -f "${PLUGIN_DIR}/.local/lib/fzf-cd/fzf-cd-lib" ]]; then
    source "${PLUGIN_DIR}/.local/lib/fzf-cd/fzf-cd-lib"
else
    echo "Failed to source fzf-cd-lib" >&2
    return 1
fi

# Create and bind the widget
___fzf_cd() {
    __fzf_cd "$@"
    zle accept-line
}
zle -N ___fzf_cd
bindkey '^f' ___fzf_cd  # Default to Ctrl+F

# Load completions if they exist
if [[ -f "${PLUGIN_DIR}/functions/_fzf_cd" ]]; then
    autoload -Uz _fzf_cd
fi