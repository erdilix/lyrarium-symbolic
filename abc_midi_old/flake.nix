{
  description = "CLI Text-to-MIDI (Classic Station)";

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
          ${pkgs.abcmidi}/bin/abc2midi "$file_no_path" -o "''${raw_name}.mid" >/dev/null 2>&1
          ${pkgs.fluidsynth}/bin/fluidsynth -n -i -T wav -F "''${raw_name}.wav" "$SOUNDFONT" "''${raw_name}.mid" >/dev/null 2>&1
          ${pkgs.pulseaudio}/bin/paplay "''${raw_name}.wav" >/dev/null 2>&1
          rm -f "''${raw_name}.wav" "''${raw_name}.mid"
        '';

        watchABC = pkgs.writeShellScriptBin "watch-abc" ''
          file=$1
          [ -z "$file" ] && exit 1
          echo "$file" | ${pkgs.entr}/bin/entr -rc ${compileABC}/bin/compile-abc "$file" >/dev/null 2>&1
        '';

        abc-station = pkgs.writeShellScriptBin "abc-station" ''
          export SOUNDFONT="${pkgs.soundfont-fluid}/share/soundfonts/FluidR3_GM2-2.sf2"
          export PATH="${pkgs.lib.makeBinPath [
            pkgs.abcmidi pkgs.fluidsynth pkgs.soundfont-fluid pkgs.entr pkgs.rofi pkgs.neovim pkgs.coreutils pkgs.findutils pkgs.procps pkgs.pulseaudio
            compileABC watchABC
          ]}:$PATH"
          export EDITOR=nvim
          export ABC_WATCH_BIN=${watchABC}/bin/watch-abc
          export ABC_COMPILE_BIN=${compileABC}/bin/compile-abc
          ${builtins.readFile ./abc-station.sh}
        '';
      in
      {
        packages.default = abc-station;
        apps.default = { type = "app"; program = "${abc-station}/bin/abc-station"; };
      });
}
