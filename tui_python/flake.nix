{
  description = "ABC Station TUI (Python Version)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        pythonEnv = pkgs.python3.withPackages (ps: [ ps.textual ]);

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

        abc-tui-py = pkgs.writeShellScriptBin "abc-tui-py" ''
          export SOUNDFONT="${pkgs.soundfont-fluid}/share/soundfonts/FluidR3_GM2-2.sf2"
          export PATH="${pkgs.lib.makeBinPath [
            pkgs.abcmidi pkgs.fluidsynth pkgs.soundfont-fluid pkgs.entr pkgs.ghostty pkgs.neovim pkgs.coreutils pkgs.bash
            compileABC watchABC
          ]}:$PATH"
          export EDITOR=nvim
          export ABC_WATCH_BIN=${watchABC}/bin/watch-abc
          export ABC_COMPILE_BIN=${compileABC}/bin/compile-abc
          ${pythonEnv}/bin/python3 ${./app.py}
        '';
      in
      {
        packages.default = abc-tui-py;
        apps.default = { type = "app"; program = "${abc-tui-py}/bin/abc-tui-py"; };
        devShells.default = pkgs.mkShell {
          buildInputs = [ pythonEnv pkgs.abcmidi pkgs.fluidsynth pkgs.soundfont-fluid pkgs.entr pkgs.ghostty pkgs.neovim compileABC watchABC ];
          SOUNDFONT = "${pkgs.soundfont-fluid}/share/soundfonts/FluidR3_GM2-2.sf2";
          shellHook = "export EDITOR=nvim";
        };
      });
}
