FROM docker.io/mathworks/matlab:R2025b
ENV DEBIAN_FRONTEND=noninteractive
# QT_FONT_DPI is always required; QT_SCALE_FACTOR is per-machine and set at runtime
ENV QT_FONT_DPI=96
USER root

# Dependencies from MathWorks' ubuntu24.04 base-dependencies list
RUN apt-get update && apt-get install -y \
    git vim make cmake neofetch software-properties-common \
    ca-certificates debianutils ibverbs-providers libasound2t64 \
    libatk-bridge2.0-0t64 libatk1.0-0t64 libatomic1 libatspi2.0-0t64 \
    libc6 libcairo-gobject2 libcairo2 libcap2 libcrypt1 libcups2t64 \
    libdrm2 libfontconfig1 libfribidi0 libgbm1 libgdk-pixbuf-2.0-0 \
    libgl1 libglib2.0-0t64 libgstreamer-plugins-base1.0-0 libgstreamer1.0-0 \
    libgtk-3-0t64 libibverbs1 libice6 libltdl7 libnspr4 libnss3 libnuma1 \
    libpam0g libpango-1.0-0 libpangocairo-1.0-0 libpangoft2-1.0-0 \
    libpixman-1-0 libpsm2-2 librdmacm1t64 libsndfile1 libtirpc3t64 \
    libucx0 libuhd4.6.0-dpdk libuuid1 libxcomposite1 libxcursor1 \
    libxdamage1 libxfixes3 libxfont2 libxft2 libxinerama1 libxrandr2 \
    libxt6t64 libxtst6 libxxf86vm1 locales locales-all make net-tools \
    procps sudo unzip x11-xkb-utils zlib1g wget \
    && rm -rf /var/lib/apt/lists/*

# Python 3.10 (required by ROS Toolbox)
RUN add-apt-repository ppa:deadsnakes/ppa -y \
    && apt-get update \
    && apt-get install -y python3.10 python3.10-venv \
    && rm -rf /var/lib/apt/lists/*

# Install MATLAB toolboxes via mpm
COPY mpm_input_r2025b.txt /tmp/mpm_input_r2025b.txt
RUN wget -P /tmp/mpm https://www.mathworks.com/mpm/glnxa64/mpm \
    && chmod +x /tmp/mpm/mpm \
    && /tmp/mpm/mpm install --inputfile /tmp/mpm_input_r2025b.txt \
    && rm -rf /tmp/mpm /tmp/mpm_input_r2025b.txt

# Symlink fix for MATLAB compiler SDK
RUN ln -sf \
    /opt/matlab/R2025b/toolbox/compiler_sdk/mps_clients/python/dist/matlab/extern/bin/glnxa64/libstdc++.so.6 \
    /opt/matlab/R2025b/sys/os/glnxa64/libstdc++.so.6