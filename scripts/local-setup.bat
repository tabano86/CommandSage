@echo off
where wsl
if %errorlevel%==0 (
    wsl bash local-setup.sh
) else (
    echo "WSL not found. Please manually install Lua and Busted.
          Or run local-setup.sh in a suitable environment."
)
pause
