<#
.SYNOPSIS
  Completely reset your Lua environment by uninstalling Lua/LuaRocks,
  cleaning environment variables and PATH entries, reinstalling via Chocolatey,
  ensuring the MSVC build tools are installed (via winget if necessary), and then
  importing the MSVC environment so that compiling Lua modules (e.g. busted) works.

.DESCRIPTION
  This script does the following:
    1. Uninstalls any Chocolatey packages with "lua" or "luarocks" in their names.
    2. Removes leftover directories and Lua‑related environment variables (including PATH entries).
    3. Reinstalls Lua and LuaRocks via Chocolatey.
    4. Removes Chocolatey shims for LuaRocks (to avoid broken relative paths).
    5. Detects the actual LuaRocks installation folder by looking for subdirectories named "luarocks-*".
    6. Appends the LuaRocks install folder (and, if found, the local user rocktree bin folder) to the User PATH.
    7. Checks for cl.exe; if it’s not found, installs VS2022 Build Tools via winget with the override:
         --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64
         --add Microsoft.VisualStudio.Component.Windows11SDK.22621
    8. Imports the MSVC environment into the current PowerShell session by running vcvarsall.bat.
    9. Installs the busted rock via LuaRocks.

.NOTES
  • This script assumes you want a 32-bit Lua installation (Chocolatey’s lua 5.1.5.52 is deployed to C:\Program Files (x86)\Lua\5.1\).
  • Adjust the $vcvarsPath and $arch variable if your build tools are installed elsewhere or if you need a different target.
  • After running this script, you may need to restart your shell (or log off and back on) for User PATH changes to take effect.
  • Run this script as Administrator.
#>

# -------------------------------
# Helper Functions
# -------------------------------

function Uninstall-ChocoPackage {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageName
    )
    Write-Host "Checking for package '$PackageName'..."
    $pkgList = choco list --local-only $PackageName 2>&1
    if ($pkgList -match $PackageName) {
        Write-Host "Uninstalling $PackageName..."
        choco uninstall $PackageName -y --force
    }
    else {
        Write-Host "Package '$PackageName' not found, skipping."
    }
}

function Remove-FromPath {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("User", "Machine")]
        [string]$Scope
    )
    $currentPath = [Environment]::GetEnvironmentVariable("Path", $Scope)
    if ($currentPath) {
        $filtered = ($currentPath -split ';' | Where-Object {
            ($_ -notmatch '(?i)lua') -and ($_ -notmatch '(?i)luarocks')
        }) -join ';'
        [Environment]::SetEnvironmentVariable("Path", $filtered, $Scope)
        Write-Host "Updated $Scope PATH variable."
    }
}

function Remove-ChocoShim {
    param(
        [string]$ShimName
    )
    $shimPath = Join-Path "C:\ProgramData\chocolatey\bin" $ShimName
    if (Test-Path $shimPath) {
        Write-Host "Removing shim: $shimPath"
        Remove-Item $shimPath -Force -ErrorAction SilentlyContinue
    }
    else {
        Write-Host "Shim $ShimName not found, skipping."
    }
}

function Append-ToUserPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$NewDir
    )
    $currentUserPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentUserPath -notmatch [regex]::Escape($NewDir)) {
        $newPath = $currentUserPath + ";" + $NewDir
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        Write-Host "Appended '$NewDir' to User PATH."
    }
    else {
        Write-Host "'$NewDir' is already in the User PATH."
    }
}

# Import the MSVC environment variables from vcvarsall.bat into the current PowerShell session.
function Import-VSDevEnv {
    param(
        [string]$vcvarsPath,
        [string]$arch = "x86"  # Use "x86" for 32-bit or "x86_amd64" for cross-compiling.
    )
    if (-not (Test-Path $vcvarsPath)) {
        Write-Error "VCVars script not found at: $vcvarsPath. Please ensure MSVC Build Tools are installed."
        exit 1
    }
    Write-Host "Importing MSVC environment ($arch) from $vcvarsPath..."
    # Run vcvarsall.bat in a CMD shell and capture environment variables.
    $envOutput = cmd /c "`"$vcvarsPath`" $arch && set"
    $envOutput -split "`r?`n" | ForEach-Object {
        if ($_ -match "^(.*?)=(.*)$") {
            $name = $matches[1]
            $value = $matches[2]
            [Environment]::SetEnvironmentVariable($name, $value, "Process")
        }
    }
    Write-Host "MSVC environment imported."
}

# -------------------------------
# 1. Uninstall Lua-related packages
# -------------------------------
Uninstall-ChocoPackage -PackageName "lua"
Uninstall-ChocoPackage -PackageName "luarocks"

# -------------------------------
# 2. Remove leftover Chocolatey directories
# -------------------------------
$chocoLib = "C:\ProgramData\chocolatey\lib"
foreach ($name in @("lua", "luarocks")) {
    $dir = Join-Path $chocoLib $name
    if (Test-Path $dir) {
        Write-Host "Removing directory: $dir"
        Remove-Item $dir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# -------------------------------
# 3. Remove common Lua environment variables
# -------------------------------
$luaEnvVars = @("LUA_PATH", "LUA_CPATH")
foreach ($envVar in $luaEnvVars) {
    foreach ($scope in @("User", "Machine")) {
        if ([Environment]::GetEnvironmentVariable($envVar, $scope)) {
            Write-Host "Removing $envVar from $scope..."
            [Environment]::SetEnvironmentVariable($envVar, $null, $scope)
        }
    }
}

# -------------------------------
# 4. Remove any PATH entries that mention "lua" or "luarocks"
# -------------------------------
Remove-FromPath -Scope "User"
Remove-FromPath -Scope "Machine"

# -------------------------------
# 5. (Optional) Remove known Lua installation directories (adjust as needed)
# -------------------------------
$dirsToRemove = @("C:\Lua", "C:\LuaRocks")
foreach ($dir in $dirsToRemove) {
    if (Test-Path $dir) {
        Write-Host "Removing directory: $dir"
        Remove-Item $dir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# -------------------------------
# 6. Reinstall Lua and LuaRocks via Chocolatey
# -------------------------------
Write-Host "Reinstalling Lua and LuaRocks via Chocolatey..."
choco install lua -y
choco install luarocks -y

# -------------------------------
# 7. Remove Chocolatey shims for LuaRocks to avoid broken relative paths
# -------------------------------
foreach ($shim in @("luarocks.exe", "luarocks-admin.exe", "luarocksw.exe")) {
    Remove-ChocoShim -ShimName $shim
}

# -------------------------------
# 8. Detect the LuaRocks installation folder from Chocolatey
# -------------------------------
$luarocksBase = Join-Path $chocoLib "luarocks"
if (Test-Path $luarocksBase) {
    # Only select subdirectories whose name begins with "luarocks-"
    $subdirs = Get-ChildItem $luarocksBase -Directory | Where-Object { $_.Name -match "^luarocks-" } | Sort-Object Name -Descending
    if ($subdirs.Count -gt 0) {
        $luarocksInstallDir = $subdirs[0].FullName
        $luarocksBat = Join-Path $luarocksInstallDir "luarocks.bat"
        if (-not (Test-Path $luarocksBat)) {
            Write-Error "ERROR: '$luarocksBat' was not found. Installation may be corrupted."
            exit 1
        }
        Write-Host "Found luarocks.bat at: $luarocksBat"
    }
    else {
        Write-Error "No subdirectory starting with 'luarocks-' found under $luarocksBase. LuaRocks installation may have failed."
        exit 1
    }
}
else {
    Write-Error "$luarocksBase not found. LuaRocks installation did not complete correctly."
    exit 1
}

# -------------------------------
# 9. Append LuaRocks install folder and local rocktree bin to the User PATH
# -------------------------------
Append-ToUserPath -NewDir $luarocksInstallDir
$localRocksBin = Join-Path ([Environment]::GetFolderPath("ApplicationData")) "LuaRocks\bin"
if (Test-Path $localRocksBin) {
    Append-ToUserPath -NewDir $localRocksBin
}
else {
    Write-Host "Local rocktree bin folder '$localRocksBin' not found; skipping PATH append."
}

# -------------------------------
# 10. Ensure MSVC Build Tools are installed
# -------------------------------
# Check if cl.exe is available. If not, run winget to install VS2022 Build Tools with required components.
if (-not (Get-Command cl.exe -ErrorAction SilentlyContinue)) {
    Write-Host "cl.exe not found. Installing VS2022 Build Tools via winget..."
    $wingetCmd = 'winget install Microsoft.VisualStudio.2022.BuildTools --force --override "--wait --passive --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows11SDK.22621"'
    Write-Host "Executing: $wingetCmd"
    Invoke-Expression $wingetCmd
    # Wait a bit for installation to complete.
    Write-Host "Waiting 30 seconds for installation to settle..."
    Start-Sleep -Seconds 30
    # Recheck cl.exe availability:
    if (-not (Get-Command cl.exe -ErrorAction SilentlyContinue)) {
        Write-Error "cl.exe still not found. Please verify the installation of VS Build Tools manually."
        exit 1
    }
    else {
        Write-Host "cl.exe now available."
    }
}
else {
    Write-Host "cl.exe is already available."
}

# -------------------------------
# 11. Import MSVC environment so that 'cl' is available in this session.
# -------------------------------
# Use the vcvars script from the BuildTools install.
$vcvarsPath = "C:\Program Files\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars32.bat"
if (-not (Test-Path $vcvarsPath)) {
    # Fallback: try vcvarsall.bat
    $vcvarsPath = "C:\Program Files\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvarsall.bat"
}
$arch = "x86"  # Using x86 because Lua 5.1 was installed as 32-bit.
Import-VSDevEnv -vcvarsPath $vcvarsPath -arch $arch

# -------------------------------
# 12. Install busted via LuaRocks using the detected luarocks.bat
# -------------------------------
Write-Host "Installing busted using LuaRocks..."
& $luarocksBat install busted
if ($LASTEXITCODE -ne 0) {
    Write-Error "Error installing busted. Please review the output above."
    exit $LASTEXITCODE
}
else {
    Write-Host "Successfully installed busted."
}

# -------------------------------
# 13. Final message
# -------------------------------
Write-Host "Lua environment cleanup and reinstallation complete."
Write-Host "LuaRocks installation folder: $luarocksInstallDir"
Write-Host "Local rocktree bin (if any): $localRocksBin"
Write-Host "MSVC environment has been imported; 'cl' should now be available in this session."
Write-Host "Please restart your shell (or run 'refreshenv' if available) for User PATH changes to take effect."
