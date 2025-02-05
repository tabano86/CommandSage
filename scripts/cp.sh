#!/bin/bash
set -euo pipefail
SOURCE_DIR=$(dirname "$PWD")
declare -a EXCLUDE_FILES=()
MAX_CHARS=0
CODEBLOCK_LANG="powershell"
EXTENSIONS=(toc yml md lua bat)
while getopts "d:e:m:l:" opt; do
  case "$opt" in
    d) SOURCE_DIR="$OPTARG" ;;
    e) EXCLUDE_FILES+=("$OPTARG") ;;
    m) MAX_CHARS="$OPTARG" ;;
    l) CODEBLOCK_LANG="$OPTARG" ;;
  esac
done
SOURCE_DIR="${SOURCE_DIR%/}"
TMPFILE=$(mktemp)
find_expr=()
for ext in "${EXTENSIONS[@]}"; do
  find_expr+=( -iname "*.${ext}" -o )
done
unset 'find_expr[${#find_expr[@]}-1]'
mapfile -t files < <(find "$SOURCE_DIR" -type f \( "${find_expr[@]}" \) ! -path "*/Libs/*")
[ ${#files[@]} -eq 0 ] && { rm "$TMPFILE"; exit 0; }
for file in "${files[@]}"; do
  base=$(basename "$file")
  for pat in "${EXCLUDE_FILES[@]}"; do
    [[ "$base" == *"$pat"* ]] && continue 2
  done
  [[ "$file" == "$SOURCE_DIR/"* ]] && relativePath="${file#$SOURCE_DIR/}" || relativePath="$base"
  {
    echo "File: $relativePath"
    echo '```'"$CODEBLOCK_LANG"
    if (( MAX_CHARS > 0 )); then
      size=$(stat -c%s "$file")
      head -c "$MAX_CHARS" "$file"
      (( size > MAX_CHARS )) && echo && echo "[... truncated]"
    else
      cat "$file"
    fi
    echo '```'
    echo
  } >> "$TMPFILE"
done
if command -v clip.exe >/dev/null 2>&1; then
  cat "$TMPFILE" | clip.exe
elif command -v xclip >/dev/null 2>&1; then
  cat "$TMPFILE" | xclip -selection clipboard
elif command -v xsel >/dev/null 2>&1; then
  cat "$TMPFILE" | xsel --clipboard --input
else
  cat "$TMPFILE"
fi
rm "$TMPFILE"
