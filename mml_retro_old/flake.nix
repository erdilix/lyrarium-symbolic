{
  description = "MML Development Environment (Classic Station)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        ppmck = pkgs.stdenv.mkDerivation rec {
          pname = "ppmck";
          version = "0.10";
          src = pkgs.fetchFromGitHub {
            owner = "munshkr";
            repo = "ppmck";
            rev = "master";
            sha256 = "sha256-WYbUcO81Fl4ugoCfb2ND4AmAklNmQDI0kCRDcSm86b8="; 
          };
          nativeBuildInputs = [ pkgs.gcc pkgs.gnumake ];
          NIX_CFLAGS_COMPILE = "-Wno-error=int-conversion -Wno-error=implicit-function-declaration";
          buildPhase = "make";
          installPhase = ''
            mkdir -p $out/bin $out/nes_include
            cp bin/ppmckc bin/nesasm $out/bin/
            cp -r nes_include/* $out/nes_include/
          '';
        };

        compileMML = pkgs.writeShellScriptBin "compile-mml" ''
          file_no_path=$1
          [ -z "$file_no_path" ] && exit 1
          raw_name="''${file_no_path%.mml}"
          base_name="''${raw_name,,}"
          INCLUDE_DIR="${ppmck}/nes_include"
          ${ppmck}/bin/ppmckc "$file_no_path" >/dev/null 2>&1
          echo " .include \"ppmck.asm\"" > local_master.asm
          echo " .include \"''${base_name}.h\"" >> local_master.asm
          rm -rf ./ppmck.asm ./ppmck
          ln -sf "$INCLUDE_DIR/ppmck.asm" ./ppmck.asm
          ln -sf "$INCLUDE_DIR/ppmck" ./ppmck
          ${ppmck}/bin/nesasm -sn -raw ./local_master.asm >/dev/null 2>&1
          rm -f local_master.asm ./ppmck.asm ./ppmck
          if [ -f "local_master.nes" ]; then
              mv "local_master.nes" "''${base_name}.nsf"
              ${pkgs.zxtune}/bin/zxtune123 --paudio --file "''${base_name}.nsf" >/dev/null 2>&1
          fi
        '';

        watchMML = pkgs.writeShellScriptBin "watch-mml" ''
          file=$1
          [ -z "$file" ] && exit 1
          echo "$file" | ${pkgs.entr}/bin/entr -rc ${compileMML}/bin/compile-mml "$file" >/dev/null 2>&1
        '';

        mml-station = pkgs.writeShellScriptBin "mml-station" ''
          export PATH="${pkgs.lib.makeBinPath [ 
            ppmck pkgs.rofi pkgs.zxtune pkgs.entr pkgs.coreutils pkgs.findutils pkgs.procps pkgs.neovim
            compileMML watchMML 
          ]}:$PATH"
          export EDITOR=nvim
          export MML_WATCH_BIN=${watchMML}/bin/watch-mml
          export MML_COMPILE_BIN=${compileMML}/bin/compile-mml
          ${builtins.readFile ./mml-station.sh}
        '';
      in
      {
        packages.default = mml-station;
        apps.default = { type = "app"; program = "${mml-station}/bin/mml-station"; };
      });
}
