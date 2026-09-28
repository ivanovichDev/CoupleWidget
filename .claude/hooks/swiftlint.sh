#!/bin/sh

file=$(jq -r '.tool_input.file_path // .tool_response.filePath // empty')
case "$file" in
    *.swift) ;;
    *) exit 0 ;;
esac
[ -f "$file" ] || exit 0

cd "$(git -C "$(dirname "$file")" rev-parse --show-toplevel)" || exit 0

output=$(swiftlint lint --strict --quiet --force-exclude "$file" 2>&1)
if [ $? -ne 0 ]; then
    echo "$output" >&2
    exit 2
fi
