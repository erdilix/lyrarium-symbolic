import os
import subprocess
import signal
from textual.app import App, ComposeResult
from textual.widgets import Header, Footer, ListView, ListItem, Label
from textual.containers import Container, Horizontal, Vertical
from textual.binding import Binding

ABC_DIR = os.path.join(os.getcwd(), "abc_files")

class FileItem(ListItem):
    def __init__(self, filename: str) -> None:
        super().__init__()
        self.filename = filename

    def compose(self) -> ComposeResult:
        yield Label(f"🎹 {self.filename}")

class ABCPlayerApp(App):
    TITLE = "ABC Station TUI (Python)"
    CSS = """
    Screen {
        background: #1a1b26;
    }
    #sidebar {
        width: 30%;
        border-right: tall #3b4261;
        background: #16161e;
    }
    #main {
        width: 70%;
        align: center middle;
    }
    ListView {
        background: transparent;
    }
    ListItem:focus {
        background: #414868;
        color: #c0caf5;
        text-style: bold;
    }
    Label {
        padding: 1;
    }
    """

    BINDINGS = [
        Binding("q", "quit", "Quit", show=True),
        Binding("enter", "play", "Play", show=True),
        Binding("e", "edit", "Live Edit", show=True),
    ]

    def __init__(self):
        super().__init__()
        self.player_process = None
        if not os.path.exists(ABC_DIR):
            os.makedirs(ABC_DIR)

    def compose(self) -> ComposeResult:
        yield Header()
        with Horizontal():
            with Vertical(id="sidebar"):
                yield Label("[bold]Library[/bold]", id="lib-label")
                self.file_list = ListView(id="file-list")
                yield self.file_list
            with Vertical(id="main"):
                self.status_label = Label("Welcome to ABC Station\n\nSelect a file and press Enter to play,\nor 'e' to edit.")
                yield self.status_label
        yield Footer()

    def on_mount(self) -> None:
        self.refresh_files()

    def refresh_files(self) -> None:
        self.file_list.clear()
        files = [f for f in os.listdir(ABC_DIR) if f.endswith(".abc")]
        for f in sorted(files):
            self.file_list.append(FileItem(f))

    def kill_current_player(self):
        if self.player_process:
            try:
                # Kill the whole process group
                os.killpg(os.getpgid(self.player_process.pid), signal.SIGTERM)
            except:
                pass
            self.player_process = None

    def action_play(self) -> None:
        selected = self.file_list.highlighted_child
        if selected:
            filename = selected.filename
            self.kill_current_player()
            
            self.status_label.update(f"Now Playing: [bold cyan]{filename}[/bold cyan]")
            
            # Use compile-abc command provided by the flake
            cmd = f"cd '{ABC_DIR}' && compile-abc '{filename}'"
            self.player_process = subprocess.Popen(
                cmd, 
                shell=True, 
                preexec_fn=os.setsid,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL
            )

    def action_edit(self) -> None:
        selected = self.file_list.highlighted_child
        if selected:
            filename = selected.filename
            self.kill_current_player()
            
            # Start watcher in background
            watch_cmd = f"ghostty -e bash -c \"cd '{ABC_DIR}' && watch-abc '{filename}'\""
            subprocess.Popen(watch_cmd, shell=True)
            
            # Open editor in foreground (suspend TUI)
            self.suspend_tui_and_run_editor(filename)

    def suspend_tui_and_run_editor(self, filename: str):
        editor = os.environ.get("EDITOR", "nvim")
        filepath = os.path.join(ABC_DIR, filename)
        
        with self.suspend():
            subprocess.run([editor, filepath])
        
        self.status_label.update(f"Finished editing {filename}")
        self.refresh_files()

if __name__ == "__main__":
    app = ABCPlayerApp()
    app.run()
