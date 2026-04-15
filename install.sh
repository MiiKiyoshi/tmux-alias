#!/usr/bin/env bash
# tmux_alias 설치 스크립트

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="$HOME/.local/bin"
COMMANDS=(cdt lst mkt mvt pwt rmt stt)

# ~/.local/bin 생성
mkdir -p "$BIN_DIR"

# 심볼릭 링크 생성
for cmd in "${COMMANDS[@]}"; do
    src="$SCRIPT_DIR/$cmd"
    dst="$BIN_DIR/$cmd"
    if [ -L "$dst" ]; then
        rm "$dst"
    elif [ -e "$dst" ]; then
        echo "Warning: $dst exists and is not a symlink, skipping"
        continue
    fi
    ln -s "$src" "$dst"
    echo "Linked: $cmd"
done

# PATH 확인
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo ""
    echo "~/.local/bin is not in PATH."
    echo "Add this line to your shell config (~/.bashrc or ~/.zshrc):"
    echo ""
    echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
fi

echo "Done."
