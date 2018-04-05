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
      storePaths=""

      for f in $(cat ${closureInfo}/store-paths     | head -n9999       ); do
        # Argh, fpm can't recreate a directory hierarchy if the directories lack write permission
        cp -r $f .
        find $(basename $f) -type d -exec chmod +w {} \;

        storePaths+=" $(basename $f)=/opt/nix-multiuser/bootstrap-store"
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
        ${closureInfo}/registration=/opt/nix-multiuser/reginfo \
        $storePaths

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
