FROM  nvcr.io/nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04

ENV TZ=Asia/Tokyo
ENV DEBIAN_FRONTEND=noninteractive=value

# Install dependencies
RUN apt-get update 
RUN apt-get install -y --no-install-recommends \
    curl \
    wget \
    git \
    curl \
    unzip \
    #     # ffmpeg \
    sudo  \
    python3

RUN apt-get install -y --no-install-recommends \
    # for lightgbm cuda and gpu
    cmake \
    build-essential \
    libboost-dev \
    libboost-system-dev \
    libboost-filesystem-dev 

RUN curl -LsSf https://bootstrap.pypa.io/get-pip.py | python3

# Add OpenCL ICD files for LightGBM
RUN mkdir -p /etc/OpenCL/vendors && \
    echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd
    
RUN pip install lightgbm \
    --no-binary lightgbm \
    --no-cache lightgbm \
    --config-settings=cmake.define.USE_CUDA=ON 

COPY requirements.txt /requirements.txt
RUN pip3 install --no-cache-dir -r requirements.txt

# Set non root user
ARG USERNAME=vscode
ARG GROUPNAME=vscode
ARG UID=1000
ARG GID=1000
ARG PASSWORD=vscode
RUN groupadd -g $GID $GROUPNAME && \
    useradd -m -s /bin/bash -u $UID -g $GID -G sudo $USERNAME && \
    echo $USERNAME:$PASSWORD | chpasswd && \
    echo "$USERNAME   ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER $USERNAME
WORKDIR /home/$USERNAME/workspaces
