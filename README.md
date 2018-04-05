Nix multi-user distro packages with fpm
---------------------------------------

This repository is an experimental attempt at building distro packages (RPM / Deb / Pacman) for a multi-user install of Nix with fpm (https://github.com/jordansissel/fpm).

This is currently out-of-tree to make the edit/build/test loop faster (so Nix doesn't need to be recompiled every time I tweak something).
It will eventually integrated into Nix repo itself and PR'd.

## To build

````
git submodule update --init

# Then pick one:
nix-build -A deb
nix-build -A pacman
nix-build -A rpm

# Or build all at once:
nix-build -A all
````

## To use
Copy `result/nix_42-FIXME_amd64.deb` to a Debian/Ubuntu box with systemd (I've tested Ubuntu Xenial), then:
````
sudo dpkg -i result/nix_42-FIXME_amd64.deb
````
and after next login Nix should work for both root and regular users.

## Rationale for this particular implementation

TODO: write this
