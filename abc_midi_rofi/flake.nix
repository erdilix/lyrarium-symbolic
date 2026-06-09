{
  description = "CLI Text-to-MIDI Synthesis Pipeline";

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
          echo "[ABC] Compiling ''${file_no_path}..."
          ${pkgs.abcmidi}/bin/abc2midi "$file_no_path" -o "''${raw_name}.mid"
          echo "[ABC] Synthesizing MIDI..."
          ${pkgs.fluidsynth}/bin/fluidsynth -n -i -T wav -F "''${raw_name}.wav" "$SOUNDFONT" "''${raw_name}.mid"
          echo "[ABC] Playing audio..."
          ${pkgs.pulseaudio}/bin/paplay "''${raw_name}.wav"
          rm -f "''${raw_name}.wav" "''${raw_name}.mid"
        '';

        # IMPROVED WATCHER: Handles Neovim atomic saves
        watchABC = pkgs.writeShellScriptBin "watch-abc" ''
          file=$1
          [ -z "$file" ] && exit 1
          echo "=== ABC Live Watcher Active: $file ==="
          while true; do
            # -d: ensures we re-arm even if Neovim replaces the file (inode change)
            echo "$file" | ${pkgs.entr}/bin/entr -prd ${compileABC}/bin/compile-abc "$file"
            sleep 0.1
          done
        '';

        abc-station = pkgs.writeShellScriptBin "abc-station" ''
          export SOUNDFONT="${pkgs.soundfont-fluid}/share/soundfonts/FluidR3_GM2-2.sf2"
          export PATH="${pkgs.lib.makeBinPath [
            pkgs.abcmidi pkgs.fluidsynth pkgs.soundfont-fluid pkgs.entr pkgs.rofi pkgs.neovim pkgs.coreutils pkgs.findutils pkgs.procps pkgs.pulseaudio
            compileABC watchABC
          ]}:$PATH"
          export EDITOR="${pkgs.neovim}/bin/nvim"
          export ABC_WATCH_BIN="${watchABC}/bin/watch-abc"
          export ABC_COMPILE_BIN="${compileABC}/bin/compile-abc"
          ${builtins.readFile ./abc-station.sh}
        '';
      in
      {
        packages.default = abc-station;
        apps.default = { type = "app"; program = "${abc-station}/bin/abc-station"; };
        devShells.default = pkgs.mkShell {
          buildInputs = [ pkgs.abcmidi pkgs.fluidsynth pkgs.soundfont-fluid pkgs.entr pkgs.rofi pkgs.neovim pkgs.coreutils pkgs.findutils pkgs.procps pkgs.pulseaudio compileABC watchABC ];
          SOUNDFONT = "${pkgs.soundfont-fluid}/share/soundfonts/FluidR3_GM2-2.sf2";
          shellHook = "export EDITOR=nvim";
        };
      });
}
