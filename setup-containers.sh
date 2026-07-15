#!/bin/bash
# Pull (or build as fallback) images and create distrobox containers.
# Usage: ./setup-containers.sh [ros|matlab|all]
set -e

ROS_IMAGE="docker.io/crsaggies/cyclone-ros:latest"
MATLAB_IMAGE="docker.io/crsaggies/cyclone-matlab:latest"

# QT_SCALE_FACTOR is per-machine — check display settings:
# 100%->1.0, 125%->1.6, 133%->1.5, 150%->1.33, 166%->1.2, 200%->2.0
SCALE_FACTOR="${QT_SCALE_FACTOR:-1.0}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect container runtime: prefer podman, fall back to docker.
# Override with: CONTAINER_RUNTIME=docker ./setup-containers.sh
if [ -n "${CONTAINER_RUNTIME:-}" ]; then
    RUNTIME="$CONTAINER_RUNTIME"
elif command -v podman &>/dev/null; then
    RUNTIME=podman
elif command -v docker &>/dev/null; then
    RUNTIME=docker
else
    echo "Error: neither podman nor docker found in PATH" >&2
    exit 1
fi
export CONTAINER_RUNTIME="$RUNTIME"  # propagate to build-local.sh if invoked
trap 'echo; echo "Aborted." >&2; exit 130' INT

POSITIONALS=()
USE_LOCAL=false
RECREATE=false

for arg in "$@"; do
    case "$arg" in
        --local)
            USE_LOCAL=true
            ;;
        --recreate)
            RECREATE=true
            ;;
        *)
            POSITIONALS+=("$arg")
            ;;
    esac
done
set -- "${POSITIONALS[@]}"

pull_or_build() {
    local image="$1"
    local build_target="$2"  # ros or matlab — forwarded to build-local.sh
    local platform="${3:-}"

    local platform_flag=""
    [ -n "$platform" ] && platform_flag="--platform $platform"

    if [ "$USE_LOCAL" = "true" ]; then
        echo "Forcing local build..."
        "$SCRIPT_DIR/build-local.sh" "$build_target"
    elif "$RUNTIME" pull ${platform_flag} "$image"; then
        echo "Using pre-built image: $image"
    else
        echo "Pull failed, falling back to local build..." >&2
        "$SCRIPT_DIR/build-local.sh" "$build_target"
    fi
}

create_ros() {
    if [ "$RECREATE" = "true" ]; then
        if distrobox list | grep -q "ubuntu-ros"; then
            echo "Removing existing container 'ubuntu-ros'..."
            distrobox rm -f ubuntu-ros
        fi
    fi

    pull_or_build "$ROS_IMAGE" "ros"
    DBX_CONTAINER_ALWAYS_PULL=0 distrobox create \
        --image "$ROS_IMAGE" \
        --name ubuntu-ros \
        --hostname ubuntu-ros 
        # --init-hooks "/start-microros-agent.sh"
}

create_matlab() {
    if [ "$RECREATE" = "true" ]; then
        if distrobox list | grep -q "ubuntu-matlab"; then
            echo "Removing existing container 'ubuntu-matlab'..."
            distrobox rm -f ubuntu-matlab
        fi
    fi

    pull_or_build "$MATLAB_IMAGE" "matlab" "linux/amd64"
    DBX_CONTAINER_ALWAYS_PULL=0 distrobox create \
        --image "$MATLAB_IMAGE" \
        --name ubuntu-matlab \
        --hostname ubuntu-matlab \
        --additional-flags "--env QT_FONT_DPI=96 --env QT_SCALE_FACTOR=${SCALE_FACTOR}"
}

print_help() {
    cat <<EOF
Usage: $0 [COMMAND] [OPTIONS]

Commands:
  ros     Pull (or build) the ROS image and create the ubuntu-ros distrobox container
  matlab  Pull (or build) the MATLAB image and create the ubuntu-matlab distrobox container
          Applies QT_FONT_DPI and QT_SCALE_FACTOR for correct display scaling
  all     Create both ros and matlab containers
  help    Show this message

Options:
  --local     Force building the image locally instead of pulling from registry
  --recreate  Delete the container if it already exists before creating it

To build images explicitly without creating containers, use build-local.sh.
EOF
}

./.configure-shellrc.sh

case "${1:-help}" in
    ros)    create_ros ;;
    matlab) create_matlab ;;
    all)    create_ros && create_matlab ;;
    help)   print_help ;;
    *)      echo "Unknown command: $1"; print_help; exit 1 ;;
esac
