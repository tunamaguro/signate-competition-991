FROM  nvidia/cuda:11.7.0-cudnn8-devel-ubuntu20.04

ENV TZ=Asia/Tokyo
ENV DEBIAN_FRONTEND=noninteractive=value

# Install dependencies
RUN apt-get update \
    && apt-get install -y \
    wget \
    git \
    curl \
    unzip \
    # ffmpeg \
    sudo \
    python3-tk \
    python3 \
    python3-pip

COPY ./requirements.txt /tmp/requirements.txt

# Install libralies
RUN pip3 install --no-cache-dir --upgrade pip setuptools \
    && pip3 install --no-cache-dir -r /tmp/requirements.txt

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