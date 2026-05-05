#!/bin/bash
set -e

ROS_IMAGE="docker.io/dannykcw/cyclone-ros:latest"
MATLAB_IMAGE="docker.io/dannykcw/cyclone-matlab:latest"

# QT_SCALE_FACTOR is per-machine — check display settings:
# 100%->1.0, 125%->1.6, 133%->1.5, 150%->1.33, 166%->1.2, 200%->2.0
SCALE_FACTOR="${QT_SCALE_FACTOR:-1.0}"

pull_or_build() {
    local image="$1"
    local dockerfile="$2"

    if docker pull "$image" 2>/dev/null; then
        echo "Using pre-built image: $image"
    else
        echo "Registry unavailable. Building $image from $dockerfile..."
        docker build -t "$image" -f "$dockerfile" .
    fi
}

create_ros() {
    pull_or_build "$ROS_IMAGE" "Dockerfile.ros"
    distrobox create \
        --image "$ROS_IMAGE" \
        --name ubuntu-ros \
        --hostname ubuntu-ros
}

create_matlab() {
    pull_or_build "$MATLAB_IMAGE" "Dockerfile.matlab"
    distrobox create \
        --image "$MATLAB_IMAGE" \
        --name ubuntu-matlab \
        --hostname ubuntu-matlab \
        --additional-flags "--env QT_FONT_DPI=96 --env QT_SCALE_FACTOR=${SCALE_FACTOR}"
}

case "${1:-all}" in
    ros)    create_ros ;;
    matlab) create_matlab ;;
    all)    create_ros && create_matlab ;;
    *)      echo "Usage: $0 [ros|matlab|all]"; exit 1 ;;
esac