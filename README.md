# dotfiles

Arch Linux + GNOME setup: Neovim, tmux, Alacritty, bash, a GNOME extension and a couple of scripts.

Configs are symlinked into place, not copied, so editing a config on the machine edits the repo.

## Setup on a new machine

1. Install Arch with GNOME, log in, and open a terminal inside the GNOME session.
   The GNOME settings need a running session, so a bare TTY will not work.

2. Clone and run the install script:

   ```sh
   git clone https://github.com/niyazmalik/dotfiles.git ~/Projects/dotfiles
   cd ~/Projects/dotfiles
   ./install.sh
   ```

3. Copy the two private files from the old machine.
   They are not in this repo on purpose.

   - `~/.bash_local`: machine-specific aliases, tokens and paths. Sourced at the end of `.bashrc`.
   - `~/.gitconfig.local`: git name and email. Included by `.gitconfig`.

4. Log out and back in so GNOME loads the extensions.

5. Open Neovim once. lazy.nvim installs the plugins pinned in `lazy-lock.json`.

6. Install the AUR packages from `packages/arch/aur.txt` with an AUR helper.

## What install.sh does

- Installs the packages in `packages/arch/pacman.txt`.
- Symlinks every config into place.
- Installs oh-my-bash and links the prompt theme.
- Downloads every GNOME extension listed in `desktop/gnome/dconf.ini` from extensions.gnome.org.
- Loads the GNOME settings from `desktop/gnome/dconf.ini`.

Any existing file in the way of a symlink is moved to `~/.dotfiles-backup/<timestamp>/`, so the script is safe to run again.

## Layout

| Path | Contents | Linked to |
| --- | --- | --- |
| `bin/` | `mm` and `vv` | `~/.local/bin/` |
| `desktop/gnome/extensions/` | app-focus-shortcuts extension | `~/.local/share/gnome-shell/extensions/` |
| `desktop/gnome/dconf.ini` | GNOME and extension settings | loaded with `dconf load` |
| `editors/neovim/` | Neovim config | `~/.config/nvim` |
| `git/.gitconfig` | git config | `~/.gitconfig` |
| `multiplexers/tmux/.tmux.conf` | tmux config | `~/.tmux.conf` |
| `packages/arch/` | required packages | installed with pacman |
| `prompts/oh-my-bash/` | prompt theme | `~/.oh-my-bash/custom/themes/` |
| `shells/bash/` | `.bashrc`, `.bash_profile`, `.inputrc` | `~/` |
| `terminals/alacritty/alacritty.toml` | Alacritty config | `~/.config/alacritty/` |

## Shortcuts and scripts

| Key | Action |
| --- | --- |
| Super+E | Focus or open Files |
| Super+S | Focus or open Settings |
| Super+N | Show or hide the top bar |
| Super+P | Screenshot with Flameshot |

- `mm <url> [name]` saves audio to `~/Music`. Works with YouTube, YouTube Music and anything else yt-dlp supports.
- `vv <url> [name]` saves video to `~/Videos`.

Both accept `-f <format>`. Run either with `--help` for the formats.

## Adding a GNOME extension

1. Add its UUID to `enabled-extensions` in `desktop/gnome/dconf.ini`.
2. Run `dconf dump /org/gnome/shell/extensions/<name>/`.
3. Copy the changed settings into `dconf.ini` under `[org/gnome/shell/extensions/<name>]`.

## Troubleshooting

If the app-focus-shortcuts extension stops loading after a GNOME upgrade, add the new GNOME version to `shell-version` in its `metadata.json`.
