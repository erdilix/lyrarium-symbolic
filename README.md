# Lyrarium Symbolic
musical motif reference organizor.
This is a POC slop version, each directory is an islated implementation of each possible approach.

### Project Overview
There are currently 4 version of this project. you can try each of them by run `nix run` command inside each of them.

#### Quick Start
1. Install Nix: 
  - `curl -fsSL https://install.determinate.systems/nix | sh -s -- install`
2. Clone this project:
  - `git clone https://github.com/erdilix/lyrarium-symbolic.git`
3. Run: 
  - Change directory to any specific sub-project: `cd abc_midi_rofi`
  - Try it out with `nix run .`


### Keybinds 
#### rofi application launcher, customizable
- **`Enter`**: Play selected song 
- **`Ctrl + s`**: 
- **`Ctrl + t`**:
- **`Ctrl + r`**:
- **`Ctrl + x`**:

**remarks**: Depends on your rofi configuration, this can conflict with rofi naive keybinds. 

#### TUI (WIP)
...

### TODO 
(unfinished roadmap)
- [x] make MML, ABC syntax functionable 
- [ ] better query: features CRUD.
- [ ] better query: sorted by features.
- [ ] better query: files clustering.
- [ ] refactor: make it minimal, get rid of unnecessary bloated logics.
- [ ] TUI mode: keybinds.
- [ ] TUI mode: no more than 1 terminal needed.
- [ ] TUI mode: make it run in termux.
author: erdilix
