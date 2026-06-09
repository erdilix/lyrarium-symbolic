{
  description = "MML Development Environment for Retro Soundchips";

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
          echo "[MML] Compiling ''${file_no_path}..."
          ${ppmck}/bin/ppmckc "$file_no_path"
          echo " .include \"ppmck.asm\"" > local_master.asm
          echo " .include \"''${base_name}.h\"" >> local_master.asm
          rm -rf ./ppmck.asm ./ppmck
          ln -sf "$INCLUDE_DIR/ppmck.asm" ./ppmck.asm
          ln -sf "$INCLUDE_DIR/ppmck" ./ppmck
          echo "[MML] Assembling NES binary..."
          ${ppmck}/bin/nesasm -sn -raw ./local_master.asm
          rm -f local_master.asm ./ppmck.asm ./ppmck
          if [ -f "local_master.nes" ]; then
              mv "local_master.nes" "''${base_name}.nsf"
              echo "[MML] Playing ''${base_name}.nsf..."
              ${pkgs.zxtune}/bin/zxtune123 --paudio --file "''${base_name}.nsf"
          fi
        '';

        # IMPROVED WATCHER: Handles Neovim atomic saves
        watchMML = pkgs.writeShellScriptBin "watch-mml" ''
          file=$1
          [ -z "$file" ] && exit 1
          echo "=== MML Live Watcher Active: $file ==="
          while true; do
            # -d: exit if a new file is created/deleted in the directory (atomic save support)
            # -r: restart child process
            echo "$file" | ${pkgs.entr}/bin/entr -prd ${compileMML}/bin/compile-mml "$file"
            sleep 0.1
          done
        '';

        mml-station = pkgs.writeShellScriptBin "mml-station" ''
          export PATH="${pkgs.lib.makeBinPath [ 
            ppmck pkgs.rofi pkgs.zxtune pkgs.entr pkgs.furnace pkgs.coreutils pkgs.findutils pkgs.procps pkgs.neovim
            compileMML watchMML 
          ]}:$PATH"
          export NIX_EDITOR="${pkgs.neovim}/bin/nvim"
          export MML_WATCH_BIN="${watchMML}/bin/watch-mml"
          export MML_COMPILE_BIN="${compileMML}/bin/compile-mml"
          ${builtins.readFile ./mml-station.sh}
        '';
      in
      {
        packages.default = mml-station;
        apps.default = { type = "app"; program = "${mml-station}/bin/mml-station"; };
        devShells.default = pkgs.mkShell {
          buildInputs = [ ppmck pkgs.rofi pkgs.zxtune pkgs.entr pkgs.furnace pkgs.coreutils pkgs.findutils pkgs.procps pkgs.neovim compileMML watchMML ];
          shellHook = "export EDITOR=nvim";
        };
      });
}
