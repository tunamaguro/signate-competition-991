FROM  nvcr.io/nvidia/cuda:12.4.1-cudnn-runtime-ubuntu22.04

ENV TZ=Asia/Tokyo
ENV DEBIAN_FRONTEND=noninteractive=value

# Install dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    curl \
    wget \
    git \
    curl \
    unzip \
    #     # ffmpeg \
    sudo  \
    libgomp1 # for lightgbm

ENV RYE_HOME="/opt/rye"
ENV PATH="$RYE_HOME/shims:$PATH"

SHELL [ "/bin/bash", "-o", "pipefail", "-c" ]
RUN curl -sSf https://rye.astral.sh/get | RYE_INSTALL_OPTION="--yes" bash  \
    && rye config --set-bool behavior.global-python=true \
    && rye config --set-bool behavior.use-uv=true

COPY ./.python-version ./pyproject.toml ./requirements* README.md ./
RUN rye pin "$(cat .python-version)" \
    && rye sync


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

RUN chown -R vscode $RYE_HOME

USER $USERNAME
WORKDIR /home/$USERNAME/workspaces
