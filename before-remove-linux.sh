#!/bin/sh
set -e

# Stop and disable the Nix daemon.
if command -v systemctl >/dev/null 2>&1; then
  systemctl stop nix-daemon.socket nix-daemon.service 2>/dev/null || true
  systemctl disable nix-daemon.socket nix-daemon.service 2>/dev/null || true
fi
