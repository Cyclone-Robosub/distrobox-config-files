#!/bin/bash
# Build container images locally instead of pulling from the registry.
# Usage: ./build-local.sh [ros|ros-multiarch|matlab|all]
set -e

ROS_IMAGE="docker.io/crsaggies/cyclone-ros:latest"
MATLAB_IMAGE="docker.io/crsaggies/cyclone-matlab:latest"

# Detect container runtime: prefer podman, fall back to docker.
# Override with: CONTAINER_RUNTIME=docker ./build-local.sh
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

build_ros() {
    "$RUNTIME" build -t "$ROS_IMAGE" -f Dockerfile.ros .
}

build_ros_multiarch() {
    # Two prerequisites:
    #   1. Registry access: run `$RUNTIME login docker.io` first.
    #   2. QEMU binfmt support: see README for setup.
    "$RUNTIME" buildx build \
        --platform linux/amd64,linux/arm64 \
        --tag "$ROS_IMAGE" \
        --file Dockerfile.ros \
        --push \
        .
}

build_matlab() {
    "$RUNTIME" build --platform linux/amd64 -t "$MATLAB_IMAGE" -f Dockerfile.matlab .
}

print_help() {
    cat <<EOF
Usage: $0 [COMMAND]

Commands:
  ros            Build the ROS image for the host's native architecture
  ros-multiarch  Build the ROS image for both linux/amd64 and linux/arm64
                 Pushes directly to the registry — log in with
                 'docker login docker.io' before running.
                 Requires buildx + QEMU; see README for setup.
  matlab         Build the MATLAB image for linux/amd64 (amd64-only)
  all            Build both ros (native) and matlab
  help           Show this message

EOF
}

case "${1:-help}" in
    ros)           build_ros ;;
    ros-multiarch) build_ros_multiarch ;;
    matlab)        build_matlab ;;
    all)           build_ros && build_matlab ;;
    help)          print_help ;;
    *)             echo "Unknown command: $1"; print_help; exit 1 ;;
esac
