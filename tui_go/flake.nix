{
  description = "ABC Station TUI (Go Version)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        compileABC = pkgs.writeShellScriptBin "compile-abc" ''
          file_no_path=$1
          [ -z "$file_no_path" ] && exit 1
          raw_name="''${file_no_path%.abc}"
          ${pkgs.abcmidi}/bin/abc2midi "$file_no_path" -o "''${raw_name}.mid"
          ${pkgs.fluidsynth}/bin/fluidsynth -i "$SOUNDFONT" "''${raw_name}.mid"
        '';

        watchABC = pkgs.writeShellScriptBin "watch-abc" ''
          file=$1
          [ -z "$file" ] && exit 1
          echo "Watching $file for changes..."
          echo "$file" | ${pkgs.entr}/bin/entr -rc ${compileABC}/bin/compile-abc "$file"
        '';

        abc-tui-go = pkgs.buildGoModule {
          pname = "abc-tui-go";
          version = "0.1.0";
          src = ./.;
          vendorHash = "sha256-QRerFLMktDxralEuNnmKzkPch+fcIJOwb3lRp8fRCXY="; 
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postInstall = ''
            wrapProgram $out/bin/tui_go \
              --set SOUNDFONT "${pkgs.soundfont-fluid}/share/soundfonts/FluidR3_GM2-2.sf2" \
              --set EDITOR "nvim" \
              --set ABC_WATCH_BIN "${watchABC}/bin/watch-abc" \
              --set ABC_COMPILE_BIN "${compileABC}/bin/compile-abc" \
              --prefix PATH : "${pkgs.lib.makeBinPath [
                pkgs.abcmidi pkgs.fluidsynth pkgs.soundfont-fluid pkgs.entr pkgs.ghostty pkgs.neovim pkgs.coreutils pkgs.bash
                compileABC watchABC
              ]}"
          '';
        };
      in
      {
        packages.default = abc-tui-go;
        apps.default = { type = "app"; program = "${abc-tui-go}/bin/tui_go"; };
        devShells.default = pkgs.mkShell {
          buildInputs = [ pkgs.go pkgs.abcmidi pkgs.fluidsynth pkgs.soundfont-fluid pkgs.entr pkgs.ghostty pkgs.neovim compileABC watchABC ];
          SOUNDFONT = "${pkgs.soundfont-fluid}/share/soundfonts/FluidR3_GM2-2.sf2";
          shellHook = "export EDITOR=nvim";
        };
      });
}
