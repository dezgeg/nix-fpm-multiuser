let
  pkgs = import <nixpkgs> {};
  nix = (import ../nix/release.nix {}).build.x86_64-linux;
  tarball = (import ../nix/release.nix {}).binaryTarball.x86_64-linux;
  closureInfo = pkgs.closureInfo { rootPaths = [ nix ]; };
in rec {
  foo = pkgs.stdenv.mkDerivation {
    name = "nix-fpm-multiuser";

    nativeBuildInputs = with pkgs; [ fpm tree ];

    buildCommand = ''
      pathsToCopy=""

      ln -s ${nix} nix
      pathsToCopy+=" nix=/opt/nix-multiuser/nix"

      pathsToCopy+=" ${closureInfo}/registration=/opt/nix-multiuser/reginfo"
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
      # --config-files /etc/nix

      fpm \
        --input-type dir \
        --output-type deb \
        --name nix \
        --version 42-FIXME \
        --maintainer "Eelco Dolstra <eelco.dolstra@logicblox.com>" \
        --url https://nixos.org/nix/ \
        --description 'The Nix software deployment system' \
        --license 'LGPLv2+' \
        --directories /nix \
        $pathsToCopy

      ar x *.deb
      mkdir -p unpack
      (cd unpack && tar xf ../data.tar.gz)
      (cd unpack && tree)

      echo
      ls -lah

      mkdir -p $out
      cp *.deb $out/
    '';
  };
}
