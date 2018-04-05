#!/bin/sh
set -e

# Remove build users
for i in $(seq 32); do
  if getent passwd "nixbld$i" >/dev/null; then
    userdel "nixbld$i"
  fi
done

if getent group "nixbld" >/dev/null && [ -z "$(getent group "nixbld" | cut -d ':' -f 4)" ]; then
  groupdel "nixbld"
fi
