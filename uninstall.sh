#!/usr/bin/env bash
# tmux_alias 삭제 스크립트

BIN_DIR="$HOME/.local/bin"
COMMANDS=(cdt lst mkt mvt pwt rmt)

for cmd in "${COMMANDS[@]}"; do
    dst="$BIN_DIR/$cmd"
    if [ -L "$dst" ]; then
        rm "$dst"
        echo "Removed: $cmd"
    elif [ -e "$dst" ]; then
        echo "Skipped: $dst (not a symlink)"
    fi
done

echo "Done."
