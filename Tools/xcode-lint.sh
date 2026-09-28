#!/bin/sh

cd "$SRCROOT" || exit 1
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

if ! command -v swiftlint >/dev/null 2>&1; then
    echo "error: SwiftLint is not installed. Install it with: brew install swiftlint"
    exit 1
fi

swiftlint lint --quiet
swiftlint_status=$?

git ls-files -co --exclude-standard -- '*.swift' \
    | grep -v '^Tools/' \
    | tr '\n' '\0' \
    | xargs -0 env -i HOME="$HOME" PATH="$PATH" Tools/ViewStyleLint/lint.sh
view_style_status=$?

[ $swiftlint_status -eq 0 ] && [ $view_style_status -eq 0 ]
