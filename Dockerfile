ARG UBUNTU_VERSION=20.04
ARG LLVM_VERSION=12

FROM ubuntu:$UBUNTU_VERSION AS base

ARG LLVM_VERSION

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -q update \
    && apt-get install -y --no-install-recommends ca-certificates software-properties-common curl gnupg2 \
    && curl -fsSL https://apt.llvm.org/llvm-snapshot.gpg.key|apt-key add - \
    && apt-add-repository "deb http://apt.llvm.org/`lsb_release -c | cut -f2`/ llvm-toolchain-`lsb_release -c | cut -f2`-$LLVM_VERSION main" || true \
    && apt-get -q update \
    && apt-get install -y --no-install-recommends git ssh zsh zlib1g-dev automake autoconf cmake make ninja-build gcc g++ gfortran build-essential libtool gfortran llvm-$LLVM_VERSION-dev clang-format clang-$LLVM_VERSION libclang-$LLVM_VERSION-dev libomp-$LLVM_VERSION-dev libblas-dev libeigen3-dev libboost-dev python3 python3-pip \
    && mkdir /.software \
    && chown -R $USERNAME /.software
    && curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage -o /.software/nvim.appimage && chmod u+x /.software/nvim.appimage \
    && /.software/nvim/appimage --appimage-extract \
    && ln -s /squashfs-root/AppRun /bin/nvim \
    && python3 -m pip install --upgrade pip setuptools \
    && python3 -m pip install lit pathlib2 \
    && touch /usr/lib/llvm-$LLVM_VERSION/bin/yaml-bench \
    && groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get install -y --no-install-recommends sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME
    
FROM base AS llvm-lt-7
RUN sudo apt-get install -y llvm-7-tools
ENV PATH="/usr/lib/llvm-7/bin:${PATH}"

FROM base AS llvm-lt-8
RUN sudo apt-get install -y llvm-7-tools
ENV PATH="/usr/lib/llvm-7/bin:${PATH}"

FROM base AS llvm-lt-9

FROM base AS llvm-lt-10

FROM base AS llvm-lt-11

FROM base AS llvm-lt-12

FROM base AS llvm-lt-13

FROM base AS llvm-lt-14

FROM llvm-lt-${LLVM_VERSION} AS final
RUN apt-get autoremove -y --purge \
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
