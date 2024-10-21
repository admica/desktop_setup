#!/bin/bash
# Install customized starship prompt

# Fetch from the mothership
if ! command -v starship &> /dev/null; then
    echo "Installing Starship."
    curl -sS https://starship.rs/install.sh | sh
else
    echo "Starship is already installed."
fi

# Copy custom config
if [ -f ~/.config/starship.toml ]; then
    echo "~/.config/starship.toml found. Not overwriting."
else
    echo "Copying starship.toml configuration."
    cp starship.toml ~/.config/starship.toml
    echo "New configuration file created at ~/.config/starship.toml.new"
fi

# Make sure its in ~.bashrc
if ! grep -q "starship init bash" ~/.bashrc; then
    echo 'eval "$(starship init bash)"' >> ~/.bashrc
else
    echo "starship already in .bashrc, skipping."
fi

# Ensure it's loaded
source ~/.bashrc
