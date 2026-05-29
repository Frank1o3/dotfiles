#!/usr/bin/env bash

set -euo pipefail

VERSION="${1:-}"
MESSAGE="${2:-}"

if [[ -z "$VERSION" || -z "$MESSAGE" ]]; then
echo "Usage:"
echo "  ./release.sh <version> <release message>"
exit 1
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
echo "Error: not inside a git repository"
exit 1
fi

BRANCH=$(git branch --show-current)

if [[ "$BRANCH" != "main" ]]; then
echo "Error: current branch is '$BRANCH'"
echo "Switch to main before releasing."
exit 1
fi

DATE=$(date +%F)

cat > .version <<EOF
version=${VERSION}
release_date=${DATE}
release_message=${MESSAGE}
EOF

echo "Updated .version"

git add .

git commit -m "release: v${VERSION} - ${MESSAGE}"

git push origin main

echo
echo "Release completed"
echo "Version: ${VERSION}"
echo "Message: ${MESSAGE}"
