# --- Run this script as Administrator ---

# 1. Uninstall existing Lua and LuaRocks via Chocolatey
choco uninstall lua -y --force
choco uninstall luarocks -y --force

# 2. Remove Lua‑related environment variables and clean PATH entries (both User and Machine)
foreach ($scope in @("User","Machine")) {
    [Environment]::SetEnvironmentVariable("LUA_PATH", $null, $scope)
    [Environment]::SetEnvironmentVariable("LUA_CPATH", $null, $scope)
    $current = [Environment]::GetEnvironmentVariable("Path", $scope)
    if ($current) {
        $filtered = ($current -split ';' | Where-Object { ($_ -notmatch '(?i)lua') -and ($_ -notmatch '(?i)luarocks') }) -join ';'
        [Environment]::SetEnvironmentVariable("Path", $filtered, $scope)
    }
}

# 3. Remove leftover Lua directories (adjust paths if necessary)
foreach ($dir in @("C:\Lua", "C:\LuaRocks")) {
    if (Test-Path $dir) { Remove-Item $dir -Recurse -Force -ErrorAction SilentlyContinue }
}

# 4. Reinstall Lua and LuaRocks via Chocolatey
choco install lua -y
choco install luarocks -y

# 5. Remove Chocolatey shims for LuaRocks to avoid broken paths
foreach ($shim in @("luarocks.exe", "luarocks-admin.exe", "luarocksw.exe")) {
    $shimPath = Join-Path "C:\ProgramData\chocolatey\bin" $shim
    if (Test-Path $shimPath) { Remove-Item $shimPath -Force -ErrorAction SilentlyContinue }
}

# 6. Append LuaRocks installation folder to the User PATH
# (Assuming default Chocolatey install location for LuaRocks)
$luarocksDir = "C:\Program Files (x86)\Lua\5.1\rocks\luarocks"
if (Test-Path $luarocksDir) {
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($userPath -notmatch [regex]::Escape($luarocksDir)) {
        [Environment]::SetEnvironmentVariable("Path", "$userPath;$luarocksDir", "User")
    }
}

# 7. Ensure the MSVC Build Tools (Desktop development with C++) are installed by checking for cl.exe.
if (-not (Get-Command cl.exe -ErrorAction SilentlyContinue)) {
    Write-Host "cl.exe not found. Installing VS2022 Build Tools with 'Desktop development with C++' workload via winget..."
    winget install Microsoft.VisualStudio.2022.BuildTools --force --override "--wait --passive --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows11SDK.22621"
    Start-Sleep -Seconds 30
    if (-not (Get-Command cl.exe -ErrorAction SilentlyContinue)) {
        Write-Error "cl.exe still not found. Please manually install the 'Desktop development with C++' workload using the VS Installer."
        exit 1
    }
}

# 8. Auto-detect the VS Build Tools installation using vswhere.exe and import the MSVC environment.
$vswhere = "$env:ProgramFiles(x86)\Microsoft Visual Studio\Installer\vswhere.exe"
if (-not (Test-Path $vswhere)) {
    Write-Error "vswhere.exe not found. Please ensure Visual Studio Installer is installed."
    exit 1
}
$vsPath = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
if (-not $vsPath) {
    Write-Error "No Visual Studio installation with the required VC tools was found. Please install 'Desktop development with C++' workload."
    exit 1
}
$vcvars = Join-Path $vsPath "VC\Auxiliary\Build\vcvarsall.bat"
if (-not (Test-Path $vcvars)) {
    Write-Error "vcvarsall.bat not found at $vcvars"
    exit 1
}
Write-Host "Importing MSVC environment from $vcvars..."
$envOutput = cmd /c "`"$vcvars`" x86 && set"
$envOutput -split "`r?`n" | ForEach-Object {
    if ($_ -match "^(.*?)=(.*)$") {
        [Environment]::SetEnvironmentVariable($matches[1], $matches[2], "Process")
    }
}
Write-Host "MSVC environment imported."

# 9. Upgrade LuaRocks to a newer version (e.g., 3.10.3)
Invoke-WebRequest -Uri "https://luarocks.github.io/luarocks/releases/luarocks-3.10.3-windows.zip" -OutFile "$env:USERPROFILE\Downloads\luarocks.zip"
Expand-Archive -Path "$env:USERPROFILE\Downloads\luarocks.zip" -DestinationPath "$env:USERPROFILE\Downloads\luarocks"
Set-Location "$env:USERPROFILE\Downloads\luarocks\luarocks-3.10.3"
.\install.bat
luarocks --version

# 10. Install busted using the upgraded LuaRocks
luarocks install busted

Write-Host "Lua environment reset and busted installation complete. Please restart your shell for PATH changes to take effect."
