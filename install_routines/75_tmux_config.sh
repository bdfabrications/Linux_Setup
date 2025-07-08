#!/bin/bash

echo "Setting up tmux configuration..."

TMUX_CONF_PATH="$HOME/.tmux.conf"
NEW_TMUX_CONF_SOURCE="$DOTFILES_PATH/tmux_config/tmux.conf"

if [ -f "$TMUX_CONF_PATH" ]; then
    echo "Existing ~/.tmux.conf found."
    echo "The new tmux configuration includes:"
    echo "  - General settings (history limit, detach behavior, default shell)"
    echo "  - Keybindings (prefix, mouse support, pane splitting)"
    echo "  - Appearance & Status Bar (colors, intervals, content)"
    echo "  - Plugin management (tpm, tmux-resurrect)"
    echo ""
    read -p "Do you want to (o)verwrite, (a)dd alongside as .tmux.conf.new, or (s)kip? [o/a/s]: " choice
    case "$choice" in
        o|O)
            echo "Overwriting existing ~/.tmux.conf..."
            ln -sf "$NEW_TMUX_CONF_SOURCE" "$TMUX_CONF_PATH"
            echo "tmux configuration updated."
            ;;
        a|A)
            echo "Adding new configuration as ~/.tmux.conf.new..."
            cp "$NEW_TMUX_CONF_SOURCE" "$HOME/.tmux.conf.new"
            echo "New configuration saved to ~/.tmux.conf.new."
            ;;
        s|S)
            echo "Skipping tmux configuration setup."
            ;;
        *)
            echo "Invalid choice. Skipping tmux configuration setup."
            ;;
    esac
else
    echo "No existing ~/.tmux.conf found. Creating symlink..."
    ln -sf "$NEW_TMUX_CONF_SOURCE" "$TMUX_CONF_PATH"
    echo "tmux configuration setup complete."
fi
