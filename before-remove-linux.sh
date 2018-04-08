#!/bin/sh
set -e

# Stop and disable the Nix daemon.
if command -v systemctl >/dev/null 2>&1; then
  systemctl stop nix-daemon.socket nix-daemon.service || true
  systemctl disable nix-daemon.socket nix-daemon.service || true
fi
