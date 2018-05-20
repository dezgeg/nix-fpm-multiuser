#!/bin/sh
set -e

if command -v getenforce >/dev/null 2>&1; then
  if [ "$(getenforce)" = Enforcing ]; then
    echo "Sorry, installing Nix with SELinux enabled is currently not supported." >&2
    exit 1
  fi
fi
