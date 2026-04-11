# tmux_alias

Short commands for managing tmux sessions, windows, and panes.

---

## What is tmux

A terminal multiplexer. Lets you run multiple terminals inside a single SSH connection, and keeps processes alive after disconnecting.

### Structure

```
Session
  └─ Window    ← like tabs
       └─ Pane  ← split screen
```

- **Session**: Independent workspace. Processes inside survive SSH disconnection.
- **Window**: A tab within a session. Named for easy identification (e.g. `train`, `debug`).
- **Pane**: A split area within a window. Each pane runs its own shell.

### Why use it

1. **SSH-disconnect safe.** Long-running jobs (training, synthesis) don't die when the connection drops.
2. **Parallel work.** Create a window per task and switch between them instantly.
3. **Shareable with agents.** An AI agent can inject commands into a pane while you watch the same pane in real time.

### Basic keybindings

**Window**

| Action | Key |
|--------|-----|
| New window | `Ctrl+b c` |
| Switch to window N | `Ctrl+b N` (0–9) |
| Close current window | `Ctrl+b &` (confirm with y) |

**Pane**

| Action | Key |
|--------|-----|
| Split vertically (left/right) | `Ctrl+b %` |
| Split horizontally (top/bottom) | `Ctrl+b "` |
| Move to adjacent pane | `Ctrl+b ←/→/↑/↓` |
| Rotate panes | `Ctrl+b Ctrl+o` |
| Show pane numbers | `Ctrl+b q` |
| Close current pane | `Ctrl+b x` (confirm with y) |
| Enter copy mode (scroll) | `Ctrl+b [` |

**Session**

| Action | Key |
|--------|-----|
| Detach (keep session alive) | `Ctrl+b d` |

### Recommended `~/.tmux.conf`

```bash
# Without this, TERM=screen (8-color) — TUIs like htop look poor
set -g default-terminal "tmux-256color"

# Enable remote clipboard copy via OSC 52
set -g set-clipboard on
# Required for GNOME-based terminals (GNOME Terminal, Terminator, etc.)
set -ag terminal-overrides "vte*:xt:ms=\\e]52;c;%p2%s\\7"

# Default is emacs bindings — vi is more comfortable for most
setw -g mode-keys vi
# v to select, y to copy (vim style)
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

# Mouse scroll and pane selection
set -g mouse on

# Default scrollback is 2000 lines — increase for log-heavy workloads
set-option -g history-limit 50000
```

---

## tmux_alias

Short commands that replace verbose tmux built-ins (`tmux new-session`, `tmux attach`, ...).

### Commands

| Command | Description |
|---------|-------------|
| `lst` | List sessions/windows/panes (hierarchical) |
| `pwt` | Print current pane address |
| `cdt` | Go to session/window (create if missing) |
| `mkt` | Create session/window/pane |
| `mvt` | Rename session / move or rename window/pane |
| `rmt` | Delete session/window/pane |
| `stt` | Show CPU/GPU memory per pane |

Windows are referenced by index (`0`, `1`, ...) or name (`train`, `main`, ...).
All session/window lookups use exact match (`=`) to prevent prefix collisions.

### Installation

```bash
git clone https://github.com/MiiKiyoshi/tmux-alias
cd tmux-alias
./install.sh
```

Creates symlinks in `~/.local/bin`. Prompts to add it to PATH if not already there.

### Uninstall

```bash
./uninstall.sh
```

### Usage

#### lst — list

```bash
lst        # compact (paths abbreviated)
lst -v     # full paths
```

Example output:
```
* t1
    * 0: bash
        * 0: vim ~/.bashrc    "~/tools"
          1: python           "~"
  t2
      0: main
          0: htop             "~"
```

`*` marks the current position.

#### pwt — current position

```bash
pwt        # → t1:0.0
```

#### cdt — go to / create

```bash
cdt t1           # attach to session (create if missing)
cdt t1:2         # go to window index 2 (create if missing)
cdt t1:train     # go to window named "train" (create if missing)
```

#### mkt — create

```bash
mkt t5              # create session
mkt t5:3            # create window at index 3
mkt t5:train        # create window named "train"
mkt t5:3.0          # split pane in window 3
mkt t5:train.0      # split pane in named window
mkt -p t5:train     # create session t5 if missing, then create window
mkt -v t5:3.0       # vertical split (top/bottom)
mkt -h t5:3.0       # horizontal split (left/right, default)
mkt t5:{a,b,c}      # create windows a, b, c at once (shell brace expansion)
```

#### mvt — move / rename

```bash
mvt t1 t5              # rename session
mvt t1:0 t5            # move window (auto-numbered)
mvt t1:0 t5:2          # move window to index 2
mvt t1:0 t1:train      # rename window within same session
mvt t1:0 t5:train      # move window and rename
mvt t1:train t5        # move named window
mvt t1:0.0 t5:2        # move pane
mvt -v t1:0.0 t5:2     # move pane (vertical split)
```

#### rmt — delete

```bash
rmt t1           # delete session
rmt t*           # delete by pattern
rmt t1:0         # delete window by index
rmt t1:train     # delete window by name
rmt t1:0.1       # delete pane
rmt t1:train.0   # delete pane in named window
```

Prompts for confirmation before deleting.

#### stt — memory stats

```bash
stt llm        # per-pane CPU/GPU memory
stt llm -t     # total only
stt llm -w     # watch mode (refresh every 5s)
stt llm -w -t  # watch total only
```

Example output:
```
llm
  0: ollama
    0: ollama  CPU 12.7 MiB     GPU 3.2 GiB

Total  CPU 12.7 MiB  GPU 3.2 GiB
```

## License

MIT
