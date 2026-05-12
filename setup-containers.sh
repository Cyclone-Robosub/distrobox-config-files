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

pull_or_build() {
    local image="$1"
    local build_target="$2"  # ros or matlab — forwarded to build-local.sh
    local platform="${3:-}"

    local platform_flag=""
    [ -n "$platform" ] && platform_flag="--platform $platform"

    if docker pull ${platform_flag} "$image" 2>/dev/null; then
        echo "Using pre-built image: $image"
    else
        echo "Registry unavailable. Building $image locally..."
        "$SCRIPT_DIR/build-local.sh" "$build_target"
    fi
}

create_ros() {
    pull_or_build "$ROS_IMAGE" "ros"
    DBX_CONTAINER_ALWAYS_PULL=0 distrobox create \
        --image "$ROS_IMAGE" \
        --name ubuntu-ros \
        --hostname ubuntu-ros
}

create_matlab() {
    pull_or_build "$MATLAB_IMAGE" "matlab" "linux/amd64"
    DBX_CONTAINER_ALWAYS_PULL=0 distrobox create \
        --image "$MATLAB_IMAGE" \
        --name ubuntu-matlab \
        --hostname ubuntu-matlab \
        --additional-flags "--env QT_FONT_DPI=96 --env QT_SCALE_FACTOR=${SCALE_FACTOR}"
}

print_help() {
    cat <<EOF
Usage: $0 [COMMAND]

Commands:
  ros     Pull (or build) the ROS image and create the ubuntu-ros distrobox container
  matlab  Pull (or build) the MATLAB image and create the ubuntu-matlab distrobox container
          Applies QT_FONT_DPI and QT_SCALE_FACTOR for correct display scaling
  all     Create both ros and matlab containers
  help    Show this message

To build images explicitly without creating containers, use build-local.sh.
EOF
}

case "${1:-help}" in
    ros)    create_ros ;;
    matlab) create_matlab ;;
    all)    create_ros && create_matlab ;;
    help)   print_help ;;
    *)      echo "Unknown command: $1"; print_help; exit 1 ;;
esac
