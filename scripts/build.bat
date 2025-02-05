@echo off
REM Attempt a bash build if WSL is present, else do a fallback.
where wsl
if %errorlevel%==0 (
    wsl bash build.sh
) else (
    echo "WSL not found, performing fallback zip build..."
    if exist dist rmdir /s /q dist
    mkdir dist
    powershell -Command "Compress-Archive -Path * -DestinationPath dist\CommandSage-1.0.zip -Force"
)
pause
