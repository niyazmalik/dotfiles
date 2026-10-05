# dotfiles

This is my whole setup on Arch Linux with GNOME: Neovim, tmux, Alacritty, bash, my GNOME extension and a couple of small scripts.
I keep it here so a new laptop is one clone and one script away from feeling like mine.

Every config in this repo is symlinked into place, not copied.
So when I tweak something on my machine, I am editing the repo directly, and the change is one commit away from every other machine.

## Setting up a new machine

Install Arch with GNOME first, log in, and open a terminal inside GNOME.
The GNOME settings need a running session, so a bare TTY will not do.

```sh
git clone https://github.com/niyazmalik/dotfiles.git ~/Projects/dotfiles
cd ~/Projects/dotfiles
./install.sh
```

The script installs the packages from `packages/arch/pacman.txt`, links every config into place, installs oh-my-bash and the Just Perfection extension, and loads my GNOME settings.
If a file is already sitting where a link needs to go, it gets moved to `~/.dotfiles-backup/<timestamp>/` first, so running the script again is safe.

Then I copy two private files over from my old machine by hand, because they never belong in a public repo:

- `~/.bash_local` holds my work aliases, tokens and anything else that only makes sense on my machine. `.bashrc` sources it at the end.
- `~/.gitconfig.local` holds my git name and email. `.gitconfig` includes it.

Finally I log out and back in so GNOME picks up the extensions, open Neovim once so lazy.nvim installs the plugins pinned in `lazy-lock.json`, and install the AUR packages from `packages/arch/aur.txt` with my AUR helper.

## What lives where

| Path | What it is | Linked to |
| --- | --- | --- |
| `bin/` | `mm` and `vv` | `~/.local/bin/` |
| `desktop/gnome/extensions/` | my app-focus-shortcuts extension | `~/.local/share/gnome-shell/extensions/` |
| `desktop/gnome/dconf.ini` | the GNOME settings this setup depends on | loaded with `dconf load` |
| `editors/neovim/` | Neovim config | `~/.config/nvim` |
| `git/.gitconfig` | git config | `~/.gitconfig` |
| `multiplexers/tmux/.tmux.conf` | tmux config | `~/.tmux.conf` |
| `packages/arch/` | the packages these configs need | installed with pacman |
| `prompts/oh-my-bash/` | my prompt theme | `~/.oh-my-bash/custom/themes/` |
| `shells/bash/` | `.bashrc`, `.bash_profile`, `.inputrc` | `~/` |
| `terminals/alacritty/alacritty.toml` | Alacritty config | `~/.config/alacritty/` |

## Things I use daily

My extension gives me Super+E to focus or open Files, Super+S for Settings, and Super+N to toggle the notification panel even though my top bar is hidden.
Super+P takes a screenshot with Flameshot.

`mm` saves the audio from a YouTube, YouTube Music or any other yt-dlp link into `~/Music`, and `vv` saves the video into `~/Videos`.
Both take an optional file name and a `-f` format, and `--help` shows the rest.

## When something breaks

If my extension stops loading after a GNOME upgrade, it is almost always `shell-version` in its `metadata.json`.
It only lists the GNOME versions I have actually tested, so a new major version has to be added there by hand.
