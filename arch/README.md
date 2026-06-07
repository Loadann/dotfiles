# Arch / EndeavourOS dotfiles

Everything needed to bring a fresh EndeavourOS machine close to this one.

## Quick start

```sh
git clone <your-repo-url> ~/tools/dotfiles
~/tools/dotfiles/arch/setup.sh        # interactive: y/n per component
# or
~/tools/dotfiles/arch/setup.sh -y     # assume yes to everything
```

`setup.sh` asks before each part, so you can skip e.g. Hyprland or the AUR
packages on a machine that doesn't need them.

## How it works — symlinks, not copies

Configs are **symlinked** from `~` back into this repo:

| Live path                         | Repo source                  |
|-----------------------------------|------------------------------|
| `~/.zshrc`                        | `../.zshrc`                  |
| `~/.config/nvim`                  | `../nvim`                    |
| `~/.config/hypr`                  | `config/hypr`               |
| `~/.local/bin/screenshot-region-*`| `bin/`                       |

So when you tweak a config on this machine you're editing the repo directly.
To publish changes:

```sh
cd ~/tools/dotfiles && git add -A && git commit -m "tweak hypr" && git push
```

## Contents

- `packages.txt` — explicitly-installed native packages (`pacman -Qqen`)
- `packages-aur.txt` — AUR/foreign packages (`pacman -Qqm`)
- `config/hypr/` — Hyprland + hyprpaper config
- `bin/` — Wayland screenshot helpers (grim + slurp + wl-copy)

### Refreshing the package lists

After installing new things, regenerate the lists and commit them:

```sh
pacman -Qqen > ~/tools/dotfiles/arch/packages.txt
pacman -Qqm  > ~/tools/dotfiles/arch/packages-aur.txt
```

## Per-machine notes

- **Monitors:** the `monitor=` lines in `config/hypr/hyprland.conf` are specific
  to this rig (DP-3 / DP-5 / HDMI-A-2). Adjust on a new machine.
- **Wallpaper:** `hyprpaper.conf` points at `~/Downloads/Kath.png`, which isn't
  bundled — drop in your own or edit the path.
- **AUR/yay:** if `yay` is missing, `setup.sh` bootstraps `yay-bin` automatically.
