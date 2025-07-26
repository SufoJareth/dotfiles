#!/bin/bash

DOTFILES_DIR="$HOME/git/dotfiles"
GIT_REMOTE="origin"
GIT_BRANCH="master"

INCLUDE=(
    "$HOME/.bashrc"
    "$HOME/.local/bin"
    "$HOME/Scripts"
    "$HOME/.config/pipewire"
    "$HOME/.config/wireplumber"
    "$HOME/.config/systemd/user"
    "$HOME/.config/easyeffects"
    "$HOME/.var/app/com.obsproject.Studio/config/obs-studio"
)

mkdir -p "$DOTFILES_DIR"

echo "🔁 Syncing tracked files to $DOTFILES_DIR..."

for ITEM in "${INCLUDE[@]}"; do
    if [[ -e "$ITEM" ]]; then
        echo "→ Copying $ITEM"
        cp --parents -r "$ITEM" "$DOTFILES_DIR"
    else
        echo "⚠️ Warning: $ITEM not found, skipping"
    fi
done

# Backup user crontab
echo "📋 Backing up crontab to cron-backup.txt"
crontab -l > "$DOTFILES_DIR/cron-backup.txt" 2>/dev/null

cd "$DOTFILES_DIR" || exit 1

if [[ -n $(git status --porcelain) ]]; then
    echo "📝 Changes detected, committing..."
    git add .
    git commit -m "Auto-backup on $(date '+%Y-%m-%d %H:%M:%S')"
    git push "$GIT_REMOTE" "$GIT_BRANCH"
    echo "✅ Dotfiles synced and pushed."
else
    echo "✅ No changes to sync."
fi
