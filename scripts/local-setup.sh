#!/bin/bash
set -euo pipefail

echo "Updating package lists and installing Lua + dev files..."
sudo apt-get update
sudo apt-get install -y lua5.3 liblua5.3-dev

echo "Installing busted locally using LuaRocks..."
luarocks --local install busted

echo "Setting up LuaRocks environment variables for local installations..."
eval "$(luarocks path --bin)"

if ! grep -q 'luarocks path --bin' ~/.bashrc; then
    echo "eval \"\$(luarocks path --bin)\"" >> ~/.bashrc
    echo "Appended LuaRocks environment settings to ~/.bashrc. Run 'source ~/.bashrc' to apply."
fi

echo "Verifying busted installation..."
busted --version

echo "Local Lua environment setup is complete!"
