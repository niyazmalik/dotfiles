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

install_packages() {
    sudo pacman -S --needed - < "$dotfiles/packages/arch/pacman.txt"
}

install_gnome() {
    local extensions="$HOME/.local/share/gnome-shell/extensions"
    local own=app-focus-shortcuts@niyaz.local
    local dconf_ini="$dotfiles/desktop/gnome/dconf.ini"
    local shell_version uuid zip

    link "desktop/gnome/extensions/$own" "$extensions/$own"
    glib-compile-schemas "$dotfiles/desktop/gnome/extensions/$own/schemas"

    shell_version="$(gnome-shell --version | grep -oE '[0-9]+' | head -1)"
    for uuid in $(sed -n 's/^enabled-extensions=//p' "$dconf_ini" | grep -oE "[^' ,\[]+@[^' ,]+"); do
        [[ -d "$extensions/$uuid" ]] && continue
        zip="$(mktemp --suffix=.zip)"
        curl -fsSL -o "$zip" "https://extensions.gnome.org/download-extension/$uuid.shell-extension.zip?shell_version=$shell_version"
        gnome-extensions install --force "$zip"
        rm "$zip"
    done

    dconf load / < "$dconf_ini"
}

install_neovim() {
    link editors/neovim "$HOME/.config/nvim"
}

install_shell() {
    link shells/bash/.bashrc "$HOME/.bashrc"
    link shells/bash/.bash_profile "$HOME/.bash_profile"
    link shells/bash/.inputrc "$HOME/.inputrc"

    if [[ ! -d "$HOME/.oh-my-bash" ]]; then
        git clone --depth 1 https://github.com/ohmybash/oh-my-bash.git "$HOME/.oh-my-bash"
    fi
    link prompts/oh-my-bash/robbyrussell-niyaz "$HOME/.oh-my-bash/custom/themes/robbyrussell-niyaz"
}

install_git() {
    link git/.gitconfig "$HOME/.gitconfig"
}

install_scripts() {
    for script in "$dotfiles"/bin/*; do
        link "bin/$(basename "$script")" "$HOME/.local/bin/$(basename "$script")"
    done
}

install_terminal() {
    link terminals/alacritty/alacritty.toml "$HOME/.config/alacritty/alacritty.toml"
    link multiplexers/tmux/.tmux.conf "$HOME/.tmux.conf"
}

install_packages
install_gnome
install_neovim
install_shell
install_terminal
install_git
install_scripts
