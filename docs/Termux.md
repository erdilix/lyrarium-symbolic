# 📱 Termux & ARM Compatibility Guide

The Music Development Suite is designed with Nix, which supports `aarch64-linux` (ARM64), the architecture used by modern Android devices running Termux.

## ✅ What Works (CLI Mode)
The following components are highly compatible with Termux (even without a GUI):
*   **Python TUI (`tui_python`)**: Works perfectly in the terminal.
*   **Go TUI (`tui_go`)**: High performance, works perfectly.
*   **Compilers**: `abcmidi`, `ppmckc`, and `nesasm` all compile and run on ARM.
*   **Headless Playback**: `fluidsynth` and `zxtune123` can output sound via PulseAudio in Termux.

## ⚠️ What Requires Extra Setup (GUI Mode)
The **Rofi-based stations** (`mml_retro_rofi`, `abc_midi_rofi`) require a graphical environment to function:
*   **X11/Wayland**: You must run these inside a Termux-X11 session or via VNC.
*   **Window Manager**: A lightweight window manager like `i3` or `openbox` is recommended.

## 🚀 How to Run on Termux
1.  **Install Nix**: Use the [Nix-on-Termux](https://github.com/nix-community/nix-on-termux) app or a `proot-distro` (like Ubuntu).
2.  **Clone the Repo**:
    ```bash
    git clone <your-repo>
    cd mmlplayer
    ```
3.  **Launch a TUI**:
    ```bash
    cd tui_python
    nix run .
    ```

## 🔊 Sound in Termux
To hear music, ensure you have the `pulseaudio` package installed in Termux and the server is running:
```bash
pkg install pulseaudio
pulseaudio --start --exit-idle-time=-1
pacmd load-module module-native-protocol-unix auth-anonymous=1 socket=/tmp/pulse-socket
```
Then, inside your Nix shell, point to that socket.
