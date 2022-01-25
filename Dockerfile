ARG UBUNTU_VERSION=20.04
ARG LLVM_VERSION=12

FROM ubuntu:$UBUNTU_VERSION

ARG LLVM_VERSION

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -q update \
    && apt-get install -y --no-install-recommends wget software-properties-common gnupg2 \
    && wget -qO - 'https://apt.llvm.org/llvm.sh' | bash -s $LLVM_VERSION all \
    && apt-get install -y --no-install-recommends git ssh autoconf make ninja-build cmake build-essential libtool libeigen3-dev libboost-dev python3 python3-pip \
    && python3 -m pip install --upgrade pip setuptools \
    && python3 -m pip install lit \
    && groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get install -y --no-install-recommends sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && apt-get autoremove -y --purge \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
    

RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
    && mkdir /commandhistory \
    && touch /commandhistory/.bash_history \
    && chown -R $USERNAME /commandhistory \
    && echo $SNIPPET >> "/home/$USERNAME/.bashrc"

RUN mkdir -p /home/$USERNAME/.vscode-server/extensions \
        /home/$USERNAME/.vscode-server-insiders/extensions \
    && chown -R $USERNAME \
        /home/$USERNAME/.vscode-server \
        /home/$USERNAME/.vscode-server-insiders

ENV DEBIAN_FRONTEND=

USER $USERNAME
