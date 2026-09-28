#!/bin/sh

file=$(jq -r '.tool_input.file_path // .tool_response.filePath // empty')
case "$file" in
    *.swift) ;;
    *) exit 0 ;;
esac
[ -f "$file" ] || exit 0

cd "$(git -C "$(dirname "$file")" rev-parse --show-toplevel)" || exit 0

swiftlint_output=$(swiftlint lint --strict --quiet --force-exclude "$file" 2>&1)
swiftlint_status=$?
view_style_output=$(Tools/ViewStyleLint/lint.sh "$file" 2>&1)
view_style_status=$?

if [ $swiftlint_status -ne 0 ] || [ $view_style_status -ne 0 ]; then
    printf '%s\n%s\n' "$swiftlint_output" "$view_style_output" | sed '/^$/d' >&2
    exit 2
fi
