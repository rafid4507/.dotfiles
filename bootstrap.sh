#!/usr/bin/env bash
# ============================================================================
#  bootstrap.sh — set up a fresh Arch machine from this repo in one command
#
#  Usage (after cloning this repo to ~/.dotfiles):
#      cd ~/.dotfiles && ./bootstrap.sh
#
#  It installs Ansible, then runs the playbook, which installs every package,
#  enables the services, deploys the dotfiles with GNU Stow, and sets fish as
#  your login shell.
#
#  NOTE: cloning this repo needs GitHub access. On a brand-new machine, add an
#  SSH key to GitHub first (see README.md), or clone over HTTPS with a token.
# ============================================================================
set -euo pipefail
cd "$(dirname "$0")"

echo "==> Installing Ansible (needs sudo)..."
sudo pacman -S --needed --noconfirm ansible python-packaging

echo "==> Installing Ansible collections..."
cd ansible
ansible-galaxy collection install -r requirements.yml

echo "==> Running the playbook (enter your sudo password when prompted)..."
ansible-playbook playbook.yml --ask-become-pass

echo
echo "==> Done! Log out and back in, then start niri with:  niri-session"
