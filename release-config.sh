#!/usr/bin/env bash

set -e

MESSAGE="$1"

if [[ -z "$MESSAGE" ]]; then
  echo "Usage: ./release-config.sh \"message\""
  exit 1
fi

REPO_DIR="$(pwd)"

CONFIGS=("hypr" "waybar" "kitty" "fuzzel" "wallust" "swaync")

echo "Detecting changes..."

CHANGED_FILES=$(git diff --name-only HEAD)

if [[ -z "$CHANGED_FILES" ]]; then
  echo "No changes detected"
  exit 0
fi

for cfg in "${CONFIGS[@]}"; do
  CHANGES=$(echo "$CHANGED_FILES" | grep "^$cfg/" || true)

  if [[ -z "$CHANGES" ]]; then
    continue
  fi

  VERSION_FILE="$cfg/.version"
  MANIFEST_FILE="$cfg/.manifest.json"

  OLD_VERSION=$(jq -r '.version' "$VERSION_FILE")
  NEW_VERSION=$((OLD_VERSION + 1))

  echo "Updating $cfg -> v$NEW_VERSION"

  FILES_JSON=$(echo "$CHANGES" | jq -R . | jq -s .)

  jq -n \
    --argjson version "$NEW_VERSION" \
    --arg message "$MESSAGE" \
    --argjson files "$FILES_JSON" \
    '{
      version: $version,
      message: $message,
      files: $files
    }' > "$MANIFEST_FILE"

  echo "{\"version\": $NEW_VERSION}" > "$VERSION_FILE"

done

git add .
git commit -m "release: $MESSAGE"
git push

echo "Release complete"