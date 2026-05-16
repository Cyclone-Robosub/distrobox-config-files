# distrobox-config-files
Config files for generating distrobox containers for use with Cyclone Robosub. Currently supports ROS2 Jazzy and MATLAB R2025b.

## Setup
For Linux:

- Install `docker` or `podman`, and install `distrobox`
    - If you are on Ubuntu 24.04 or older, the `apt` version **will not work!** Instead, install it from [distrobox's GitHub page](https://github.com/89luca89/distrobox#installation). I recommend running `curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sudo sh`
- Install `flatpak`
    - Distobox uses this for `distrobox-host-exec`
- If you are running with scaling other than 100% and plan to use MATLAB, uncomment the indicated line in `setup-containers.sh`
    - You can check this in your computer's display settings. If you see 100%, you're fine.

## Local Image Builds

If you cannot pull from the registry (no access, or you want to test local changes), use `build-local.sh` to build images yourself.

### Prerequisites

- **Docker or Podman** — the scripts auto-detect which is available (podman preferred when both are installed). Override with `CONTAINER_RUNTIME=docker` or `CONTAINER_RUNTIME=podman`.
- **For `ros-multiarch` only:** One-time setup (QEMU + registry login):

  **Docker:**
  ```bash
  docker run --privileged --rm tonistiigi/binfmt --install all
  docker buildx create --name multiarch --driver docker-container --use
  docker buildx inspect --bootstrap
  docker login docker.io
  ```
  **Podman** (no `buildx create` needed — podman's buildx shim uses the host binfmt directly):
  ```bash
  podman run --privileged --rm tonistiigi/binfmt --install all
  podman login docker.io
  ```

### Build Commands

These commands are really only here for maintenance and in case anything goes wrong.
Normal workflow involves the [How to Create Conatiners](#how-to-create-containers) section.

```bash
./build-local.sh ros            # ROS, native arch only
./build-local.sh ros-multiarch  # ROS, linux/amd64 + linux/arm64 (pushes to registry)
./build-local.sh matlab         # MATLAB, linux/amd64 only
./build-local.sh all            # Both ros (native) and matlab
```

## How to Create Containers

- `cd` into this repository
- run `./setup-containers.sh help` to see the possible commands and their descriptions.

## How to Run Containers

- run `distrobox-enter [container_name]`
    - `[container_name]` is either `ubuntu-ros` or `ubuntu-matlab`
This may take a few minutes! Don't stop it partway through unless you're confident that it is hung.

## Matlab Additional Steps

- Once inside the container, run `sudo /opt/matlab/R2025b/bin/glnxa64/MathWorksProductAuthorizer` and enter your credentials
    - Don't select "run matlab" in the credentials screen!
- Type `matlab` to start matlab afterwards
- If you get the error `Path to Python Executable is not set. Set the path to the Python executable using ROS Toolbox preferences.` when running `ros2genmsg()`, select `/usr/bin/python3.10`, then rebuild the Python environment with the button below the filepath box.
