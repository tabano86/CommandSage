#!/bin/bash
set -euo pipefail

# Usage:
#   ./process_files.sh [source_directory] [exclude1] [exclude2] ...
#
# If no source_directory is provided, the current working directory is used.
SOURCE_DIR="${1:-$(pwd)}"
shift || true
EXCLUDE_FILES=("$@")  # Additional patterns to exclude (partial or full file names)

clipboardContent=""

# Find files with the desired extensions (case-insensitive) while excluding paths that include "Libs"
mapfile -t files < <(find "$SOURCE_DIR" -type f \( -iname "*.toc" -o -iname "*.yml" -o -iname "*.md" -o -iname "*.lua" -o -iname "*.bat" \) \
    ! -path "*/Libs/*")

if [ "${#files[@]}" -eq 0 ]; then
    echo "No content found to copy. No .toc, .yml, .bat, .md, or .lua files (outside Libs folders) in $SOURCE_DIR."
    exit 0
fi

for file in "${files[@]}"; do
    base="$(basename "$file")"
    skip=false
    for pattern in "${EXCLUDE_FILES[@]}"; do
        if [[ "$base" == *"$pattern"* ]]; then
            skip=true
            break
        fi
    done
    if $skip; then
        continue
    fi

    # Compute the relative path of the file
    relativePath="${file#$SOURCE_DIR/}"
    if [[ -z "$relativePath" ]]; then
        relativePath="$base"
    fi

    # Append a header with the file path
    clipboardContent+="File: $relativePath"$'\n'

    # Attempt to read the file; wrap its content in a code block using "```powershell" markers.
    if content=$(<"$file"); then
        clipboardContent+="\`\`\`powershell"$'\n'
        clipboardContent+="$content"$'\n'
        clipboardContent+="\`\`\`"$'\n'
    else
        clipboardContent+="Error reading file: could not read $file"$'\n'
    fi
done

# If content was gathered, attempt to copy it to the clipboard using xclip or xsel.
if [[ -n "$clipboardContent" ]]; then
    if command -v xclip >/dev/null 2>&1; then
        echo "$clipboardContent" | xclip -selection clipboard
        echo "All relevant files have been processed, and their contents have been copied to your clipboard."
    elif command -v xsel >/dev/null 2>&1; then
        echo "$clipboardContent" | xsel --clipboard --input
        echo "All relevant files have been processed, and their contents have been copied to your clipboard."
    else
        echo "No clipboard utility found (please install xclip or xsel)."
        echo "Outputting content to terminal:"
        echo "$clipboardContent"
    fi
else
    echo "No content found to copy after processing. Check your exclusion rules."
fi
