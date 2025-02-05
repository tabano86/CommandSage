#!/bin/bash
set -euo pipefail

echo "Updating package lists and installing Lua and development files..."
sudo apt-get update
sudo apt-get install -y lua5.3 liblua5.3-dev

echo "Installing busted locally using LuaRocks..."
luarocks --local install busted

echo "Setting up LuaRocks environment variables for local installations..."
# This command prints out shell commands to set LUA_PATH, LUA_CPATH, and PATH.
eval "$(luarocks path --bin)"

# Optionally, append the environment setup to your ~/.bashrc so it's loaded on each new shell.
if ! grep -q 'luarocks path --bin' ~/.bashrc; then
		echo "eval \"\$(luarocks path --bin)\"" >> ~/.bashrc
    echo "Appended LuaRocks environment settings to ~/.bashrc. Please run 'source ~/.bashrc' to apply them."
fi

echo "Verifying busted installation..."
busted --version

echo "Local Lua environment setup is complete!"
