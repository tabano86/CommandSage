param(
    [string]$SourceDirectory = (Get-Location).Path,
    [string[]]$ExcludeFiles = @()  # Provide partial or full names of files to exclude if desired
)

# This variable will store the final text that we place on the clipboard.
$clipboardContent = ""

try {
    # Recursively get files matching the specified extensions,
    # excluding any files in "Libs" folders.
    $files = Get-ChildItem -Path $SourceDirectory -Recurse -Include *.toc, *.md, *.lua -File |
            Where-Object {
                $_.FullName -notmatch '(\\|/)Libs(\\|/)' -and
                        $ExcludeFiles -notcontains $_.Name
            }

    if (-not $files) {
        Write-Host "No content found to copy. No .toc, .md, or .lua files (outside Libs folders) in $SourceDirectory."
        return
    }

    foreach ($file in $files) {
        # Build a relative path by stripping out the source directory path.
        $relativePath = $file.FullName.Substring($SourceDirectory.Length).TrimStart('\','/')
        if ([string]::IsNullOrWhiteSpace($relativePath)) {
            $relativePath = $file.Name
        }

        # Append file header
        $clipboardContent += "File: $relativePath" + [Environment]::NewLine

        # Read file content safely, placing content in a code block
        try {
            $content = Get-Content -Path $file.FullName -Raw
            $clipboardContent += '```powershell' + [Environment]::NewLine
            $clipboardContent += $content + [Environment]::NewLine
            $clipboardContent += '```' + [Environment]::NewLine
        }
        catch {
            $clipboardContent += "Error reading file: $($_.Exception.Message)" + [Environment]::NewLine
        }
    }

    # Only set clipboard if we have something to copy
    if (-not [string]::IsNullOrWhiteSpace($clipboardContent)) {
        Set-Clipboard -Value $clipboardContent
        Write-Host "All relevant files (excluding 'Libs' folder) have been processed, and their contents have been copied to your clipboard."
    } else {
        Write-Host "No content found to copy after processing. Exclusion rules may have filtered out all files."
    }
}
catch {
    Write-Host "An unexpected error occurred: $($_.Exception.Message)"
}
