@echo off
rem Adjust the path below so that it correctly points to cp.sh in your WSL file system if needed.
where wsl
if %errorlevel%==0 (
    wsl bash ./cp.sh ../ %*
) else (
    echo "WSL not found. Exiting or handle fallback logic."
)
pause
