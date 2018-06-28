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
````

## To use

Copy `result/nix_42-FIXME_amd64.deb` to a Debian/Ubuntu box with systemd (I've tested Ubuntu Xenial and Debian Stretch), then:

```console
$ sudo dpkg -i result/nix_42-FIXME_amd64.deb
```

On rpm-based distributions copy `result/nix-FIXME.x86_64.rpm` over and run (tested with Fedora 27):

```console
$ rpm -i nix-2.0-1.x86_64.rpm
```

After next login Nix should work for both root and regular users.
To use nix, you may want to initialize a channel:

```
nix-channel --update
```

## Rationale & design choices for this particular implementation

The most significant difference in this implementation (compared to both the current in-tree RPM+Deb builders and the https://github.com/NixOS/nix/pull/1141 pull request)
is that instead of compiling Nix against the distro packages with distro build infrastructure (`rpmbuild` / `dpkg-buildpackage`) a Nix-built Nix using nixpkgs is used (and thus is installed to the usual `/nix/store/*-nix/bin/nix` location and not `/usr/bin/nix`).
The primary reason is to avoid the maintenance overhead of having to update (at least) three different build scripts whenever e.g. a new dependency is added or removed.
A second (and perhaps an even more important reason in the long run) is to avoid having the support costs go up due to these these packages; when bug reports come in there is no need to investigate if the cause is some distro library being subtly incompatible and so on,
since on every distro and the single-user installer will be running the exact same set of binaries.

So, once distro-specific build scripts are thrown away, we can also throw away distro-specific packaging scripts and use fpm (https://github.com/jordansissel/fpm) instead,
which is a tool that abstracts the process of creating distro packages from directory trees of build artifacts + pre/post install/remove scripts and metadata.
So far I've tried the `rpm`, `deb` and `pacman` backends of fpm and the end results look very promising for all of them.

The distro packages do not install files to `/nix` directly though, instead the Nix closure is installed to `/opt/multiuser-nix/bootstrap-store` and a post-install script copies it to `/nix/store`.
This is so that when the Nix distro package is upgraded, the distro package manager doesn't go deleting stuff from `/nix` and potentially corrupting the store.
Yes, it wastes some disk space, but hard links could be used (donce a particular fpm bug is fixed) to reduce the actual space waste to under a megabyte.

Uninstalling the distro package doesn't remove `/nix`. But since it will stop & remove the daemon, the build users and the `/etc/profile.d` snippet, effectively Nix and installed packages will stop working.
Reinstalling the distro package makes things work again just as they were before the uninstallation. I believe this matches what the distros do with mutable data, e.g. uninstalling Postgres doesn't nuke all the databases.

Upgrading the Nix version used by the daemon must be done by upgrading the distro package.
Installing a new version of Nix to the root's profile doesn't affect the daemon.
In fact, as on NixOS, both root's and regular users' profiles are empty by default and the default Nix on PATH is the one used for the daemon (`/opt/nix-multiuser/nix/bin`) just on NixOS the default Nix comes from `/run/current-system/sw/bin`.
