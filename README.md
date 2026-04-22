# distrobox-config-files
Config files for generating distrobox containers for use with Cyclone Robosub. Currently supports ROS2 Jazzy and MATLAB R2025b.

## How to run
- `cd` into this repository
- run `distrobox-assemble create --file [filename]`

This may take a few minutes! Don't stop it partway through unless you're confident that it is hung.

## Matlab Additional Steps
- Once inside the container, run `sudo /opt/matlab/R2025b/bin/glnxa64/MathWorksProductAuthorizer` and enter your credentials
    - Don't select "run matlab" in the credentials screen!
- Type `matlab` to start matlab afterwards
