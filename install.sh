#!/usr/bin/env bash
set -euo pipefail

dotfiles="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
backup_dir="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

link() {
    local source="$dotfiles/$1" target="$2"

    if [[ -e "$target" && ! -L "$target" ]]; then
        mkdir -p "$backup_dir"
        mv "$target" "$backup_dir/"
        printf 'Backed up %s to %s\n' "$target" "$backup_dir"
    fi

    mkdir -p "$(dirname "$target")"
    ln -sfn "$source" "$target"
}

install_gnome() {
    local extensions="$HOME/.local/share/gnome-shell/extensions"
    local own=app-focus-shortcuts@niyaz.local
    local just_perfection=just-perfection-desktop@just-perfection

    link "desktop/gnome/extensions/$own" "$extensions/$own"
    glib-compile-schemas "$dotfiles/desktop/gnome/extensions/$own/schemas"

    if [[ ! -d "$extensions/$just_perfection" ]]; then
        local shell_version zip
        shell_version="$(gnome-shell --version | grep -oE '[0-9]+' | head -1)"
        zip="$(mktemp --suffix=.zip)"
        curl -fsSL -o "$zip" "https://extensions.gnome.org/download-extension/$just_perfection.shell-extension.zip?shell_version=$shell_version"
        gnome-extensions install --force "$zip"
        rm "$zip"
    fi

    dconf load / < "$dotfiles/desktop/gnome/dconf.ini"
}

install_neovim() {
    link editors/neovim "$HOME/.config/nvim"
}

install_gnome
install_neovim
