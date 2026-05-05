#!/bin/bash
set -e

INI_FILE="${1:?Usage: ./assemble.sh <ini-file>}"

# Parse image= and fallback_image= from the INI
CONFIGURED_IMAGE=$(grep -m1 '^image=' "$INI_FILE" | cut -d= -f2-)
FALLBACK_IMAGE=$(grep -m1 '^# fallback_image=' "$INI_FILE" | cut -d= -f2-)

if [[ -z "$CONFIGURED_IMAGE" ]]; then
    echo "Error: No image= found in $INI_FILE"
    exit 1
fi

# Try to pull the pre-built image
echo "Attempting to pull $CONFIGURED_IMAGE..."
if docker pull "$CONFIGURED_IMAGE" 2>/dev/null; then
    echo "Using pre-built image: $CONFIGURED_IMAGE"
    distrobox-assemble create --file "$INI_FILE"
elif [[ -n "$FALLBACK_IMAGE" ]]; then
    echo "Registry unavailable. Falling back to: $FALLBACK_IMAGE"
    TEMP_INI=$(mktemp /tmp/distrobox-fallback-XXXX.ini)
    sed "s|^image=.*|image=$FALLBACK_IMAGE|" "$INI_FILE" > "$TEMP_INI"
    distrobox-assemble create --file "$TEMP_INI"
    rm -f "$TEMP_INI"
else
    echo "Error: Registry unavailable and no fallback_image= defined in $INI_FILE"
    exit 1
fi