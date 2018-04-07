let
  pkgs = import <nixpkgs> {};
  nix = (import ./nix/release.nix {}).build.x86_64-linux;
  tarball = (import ./nix/release.nix {}).binaryTarball.x86_64-linux;
  closureInfo = pkgs.closureInfo { rootPaths = [ nix ]; };

  # Profile script installed to /etc/profile.d
  profileScript = pkgs.writeText "nix.sh" ''
    if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then
      source $HOME/.nix-profile/etc/profile.d/nix.sh
      export PATH="$PATH:/opt/nix-multiuser/nix/bin"
    elif [ -e /opt/nix-multiuser/nix/etc/profile.d/nix.sh ]; then
      source /opt/nix-multiuser/nix/etc/profile.d/nix.sh
      export PATH="$PATH:/opt/nix-multiuser/nix/bin"
    else
      # Generally, this should never happen, but be defensive just in case we somehow
      # end up with the package installed without running the post-install script.
      echo "nix-multiuser: warning: couldn't locate a Nix profile script to source." >&2
    fi
  '';

  daemonStartupScript = pkgs.writeScript "start-daemon.sh" ''
    #!/bin/sh
    if [ -e /etc/ssl/certs/ca-certificates.crt ]; then # NixOS, Ubuntu, Debian, Gentoo, Arch
      export NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
    elif [ -e /etc/ssl/ca-bundle.pem ]; then # openSUSE Tumbleweed
      export NIX_SSL_CERT_FILE=/etc/ssl/ca-bundle.pem
    elif [ -e /etc/ssl/certs/ca-bundle.crt ]; then # Old NixOS
      export NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt
    elif [ -e /etc/pki/tls/certs/ca-bundle.crt ]; then # Fedora, CentOS
      export NIX_SSL_CERT_FILE=/etc/pki/tls/certs/ca-bundle.crt
    fi

    exec ${nix}/bin/nix-daemon --daemon
  '';

  buildFor = types: pkgs.stdenv.mkDerivation {
    name = "nix-fpm-multiuser";

    nativeBuildInputs = with pkgs; [ dpkg fpm rpm ];

    packageDescription = ''
      The Nix software deployment system
      Nix is a purely functional package manager. It allows multiple
      versions of a package to be installed side-by-side, ensures that
      dependency specifications are complete, supports atomic upgrades and
      rollbacks, allows non-root users to install software, and has many
      other features. It is the basis of the NixOS Linux distribution, but
      it can be used equally well under other Unix systems.
    '';

    inherit types;

    buildCommand = ''
      pathsToCopy=""

      ln -s ${nix} nix
      cp ${nix}/lib/systemd/system/nix-daemon.* .
      sed -i nix-daemon.service -e 's|ExecStart=.*|ExecStart=/opt/nix-multiuser/start-daemon.sh|'

      pathsToCopy+=" nix=/opt/nix-multiuser/nix"
      pathsToCopy+=" nix-daemon.service=/lib/systemd/system/nix-daemon.service"
      pathsToCopy+=" nix-daemon.socket=/lib/systemd/system/nix-daemon.socket"
      pathsToCopy+=" ${closureInfo}/registration=/opt/nix-multiuser/reginfo"
      pathsToCopy+=" ${daemonStartupScript}=/opt/nix-multiuser/start-daemon.sh"
      pathsToCopy+=" ${profileScript}=/etc/profile.d/nix.sh"

      for f in $(cat ${closureInfo}/store-paths); do
        # XXX: fpm can't recreate a directory hierarchy if the directories lack write permission.
        # So make a local copy with +w added to directories, include that, and fixup in post-install script.
        cp -r $f .
        find $(basename $f) -type d -exec chmod +w {} \;

        pathsToCopy+=" $(basename $f)=/opt/nix-multiuser/bootstrap-store"
      done

      # --verbose 
      # --debug 
      # --debug-workspace

      # TODO:
      # Make description + summary look sane in both RPM and Deb
      # --config-files /etc/nix - deb backend doesn't like if the directory doesn't exist
      # --directories /nix - rpm backend doesn't like if the directory doesn't exist
      # Vcs-Browser:, Vcs-Git:

      for type in $types; do
        fpm \
          --input-type dir \
          --output-type $type \
          --name nix \
          --version 42-FIXME \
          --maintainer "Eelco Dolstra <eelco.dolstra@logicblox.com>" \
          --vendor NixOS \
          --url https://nixos.org/nix/ \
          --description "$packageDescription" \
          --license 'LGPLv2+' \
          --deb-no-default-config-files \
          --rpm-rpmbuild-define '_build_id_links none' \
          --after-install ${./after-install-linux.sh} \
          --before-remove ${./before-remove-linux.sh} \
          --after-remove ${./after-remove-linux.sh} \
          $pathsToCopy

        case "$type" in
          rpm)
            echo "File list:"
            rpm -qlp *.rpm
            echo
            echo "Package metadata:"
            rpm -qip *.rpm
            ;;
          deb)
            echo "File list:"
            dpkg -c *.deb
            echo
            echo "Package metadata:"
            dpkg -I *.deb
            ;;
          pacman)
            # pacman does provide some commands to list metadata, but they don't work without a pacman database set up :(
            echo "File list:"
            tar tvf *.pkg.tar.*
            echo
            echo "Package metadata:"
            tar xf *.pkg.tar.* .PKGINFO
            cat .PKGINFO
            ;;
          *)
            echo "wtf: $type"
            ;;
        esac
      done

      mkdir -p $out
      cp *.deb *.rpm *.pkg.tar.* $out/
    '';
  };

in rec {
  all = buildFor ["deb" "pacman" "rpm"];

  deb = buildFor ["deb"];
  pacman = buildFor ["pacman"];
  rpm = buildFor ["rpm"];
}
