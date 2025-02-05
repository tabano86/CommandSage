@echo off
where wsl >nul 2>&1
if %errorlevel%==0 (
    wsl bash ./cp.sh -d ".." %*
) else (
    echo WSL not found.
)
