#!/bin/sh

package=$(cd "$(dirname "$0")" && pwd)

if ! build_output=$(swift build -c release --package-path "$package" 2>&1); then
    echo "$build_output" >&2
    exit 1
fi

"$package/.build/release/view-style-lint" "$@"
