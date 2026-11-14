# Ansible

Reproduces this whole Arch + niri machine (packages, services, dotfiles) from a
fresh install, using one command.

> **You do not need Ansible for day-to-day use.** GNU Stow already manages your
> dotfiles, and `../install.sh` deploys them. Ansible is only worth it when you
> want to rebuild the *entire machine* (packages + services + configs)
> automatically.

## What it manages

| Stage | Detail |
| ----- | ------ |
| Packages | Full official-repo set (compositor, bar, portals, audio, fonts, apps) |
| AUR | `yay` + `catppuccin-gtk-theme-mocha` |
| Services | `bluetooth`, `NetworkManager` (system); `pipewire`, `wireplumber` (user) |
| Dotfiles | Clones this repo and runs `install.sh` (Stow) |
| Shell | Sets `fish` as the login shell |

## Prerequisites

A **minimal Arch install** with a normal user that has `sudo`. Then:

```bash
sudo pacman -S --needed ansible python-packaging
```

## Run it

```bash
cd ~/.dotfiles/ansible
ansible-galaxy collection install -r requirements.yml
ansible-playbook playbook.yml --ask-become-pass
```

`--ask-become-pass` prompts once for your sudo password. Re-running is safe
(idempotent) — nothing changes if the machine is already configured.

## Dry run

See what *would* change without touching anything:

```bash
ansible-playbook playbook.yml --ask-become-pass --check --diff
```

## Notes

- The playbook runs against `localhost` (see `inventory.ini`).
- AUR packages are built by a dedicated unprivileged `aur_builder` user that is
  only allowed to run `pacman` via sudo — AUR builds must never run as root.
- The dotfiles repo is cloned over SSH, so the target machine needs a GitHub SSH
  key (see the top-level README).
