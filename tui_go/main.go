package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"sort"
	"strings"
	"syscall"

	"github.com/charmbracelet/bubbles/list"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

var docStyle = lipgloss.NewStyle().Margin(1, 2)

type item string

func (i item) Title() string       { return string(i) }
func (i item) Description() string { return "ABC File" }
func (i item) FilterValue() string { return string(i) }

type model struct {
	list          list.Model
	abcDir        string
	playerProcess *exec.Cmd
	status        string
}

func (m *model) Init() tea.Cmd {
	return nil
}

func (m *model) killCurrentPlayer() {
	if m.playerProcess != nil && m.playerProcess.Process != nil {
		// Kill the whole process group
		pgid, err := syscall.Getpgid(m.playerProcess.Process.Pid)
		if err == nil {
			syscall.Kill(-pgid, syscall.SIGTERM)
		}
	}
	m.playerProcess = nil
}

func (m *model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.KeyMsg:
		switch msg.String() {
		case "ctrl+c", "q":
			m.killCurrentPlayer()
			return m, tea.Quit

		case "enter":
			i, ok := m.list.SelectedItem().(item)
			if ok {
				filename := string(i)
				m.killCurrentPlayer()
				m.status = fmt.Sprintf("Now Playing: %s", filename)

				// Use compile-abc command
				m.playerProcess = exec.Command("bash", "-c", fmt.Sprintf("cd '%s' && compile-abc '%s'", m.abcDir, filename))
				m.playerProcess.SysProcAttr = &syscall.SysProcAttr{Setpgid: true}
				_ = m.playerProcess.Start()
			}

		case "e":
			i, ok := m.list.SelectedItem().(item)
			if ok {
				filename := string(i)
				m.killCurrentPlayer()
				m.status = fmt.Sprintf("Editing: %s", filename)

				// Start watcher in background
				watchCmd := exec.Command("ghostty", "-e", "bash", "-c", fmt.Sprintf("cd '%s' && watch-abc '%s'", m.abcDir, filename))
				_ = watchCmd.Start()

				// Open editor and suspend TUI
				editor := os.Getenv("EDITOR")
				if editor == "" {
					editor = "nvim"
				}
				filepath := filepath.Join(m.abcDir, filename)
				
				return m, tea.ExecProcess(exec.Command(editor, filepath), func(err error) tea.Msg {
					return nil // Refresh might be needed here
				})
			}
		}

	case tea.WindowSizeMsg:
		h, v := docStyle.GetFrameSize()
		m.list.SetSize(msg.Width-h, msg.Height-v-2)
	}

	var cmd tea.Cmd
	m.list, cmd = m.list.Update(msg)
	return m, cmd
}

func (m model) View() string {
	sidebar := docStyle.Render(m.list.View())
	status := lipgloss.NewStyle().
		Foreground(lipgloss.Color("14")).
		Bold(true).
		Padding(0, 1).
		Render(m.status)
	
	footer := lipgloss.NewStyle().
		Foreground(lipgloss.Color("240")).
		Render("\n  Enter: Play | e: Live Edit | q: Quit")

	return lipgloss.JoinVertical(lipgloss.Left, sidebar, status, footer)
}

func main() {
	cwd, _ := os.Getwd()
	abcDir := filepath.Join(cwd, "abc_files")
	if _, err := os.Stat(abcDir); os.IsNotExist(err) {
		os.Mkdir(abcDir, 0755)
	}

	files, _ := os.ReadDir(abcDir)
	var items []list.Item
	for _, f := range files {
		if !f.IsDir() && strings.HasSuffix(f.Name(), ".abc") {
			items = append(items, item(f.Name()))
		}
	}
	
	// Ensure list is sorted
	sort.Slice(items, func(i, j int) bool {
		return items[i].FilterValue() < items[j].FilterValue()
	})

	l := list.New(items, list.NewDefaultDelegate(), 0, 0)
	l.Title = "ABC Station TUI (Go)"

	m := model{
		list:   l,
		abcDir: abcDir,
		status: "Welcome! Select a file and press Enter.",
	}

	if _, err := tea.NewProgram(&m, tea.WithAltScreen()).Run(); err != nil {
		fmt.Println("Error running program:", err)
		os.Exit(1)
	}
}
