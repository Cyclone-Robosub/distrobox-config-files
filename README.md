# distrobox-config-files
Config files for generating distrobox containers for use with Cyclone Robosub. Currently supports ROS2 Jazzy and MATLAB R2025b.

## Setup
- Install `docker` or `podman`, and install `distrobox`
    - If you are on Ubuntu 24.04, the version in `apt` **will not work!** Instead, install it from [Distrobox's GitHub page](https://github.com/89luca89/distrobox#installation). I recommend running `curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sudo sh`
- `cd` into this repository
- run `./configure_bashrc.sh`
- If you are running with scaling other than 100%, uncomment the indicated line in `ubuntu_matlab.ini`
    - You can check this in your computer's display settings. If you see 100%, you're fine.

## How to Create Containers
- `cd` into this repository
- run `distrobox-assemble create --file [filename]`
    - `[filename]` is either `ubuntu_ros.ini` or `ubuntu_matlab.ini`

## How to Run Containers
- run `distrobox-enter [container_name]`
    - `[container_name]` is either `ubuntu_ros` or `ubuntu_matlab`
This may take a few minutes! Don't stop it partway through unless you're confident that it is hung.

## Matlab Additional Steps
- Once inside the container, run `sudo /opt/matlab/R2025b/bin/glnxa64/MathWorksProductAuthorizer` and enter your credentials
    - Don't select "run matlab" in the credentials screen!
- Type `matlab` to start matlab afterwards
