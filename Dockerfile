FROM ubuntu:20.04

# docker
# -----------------
# apt-get install -y docker.io
# usermod -aG docker $USER
# printf '{"registry-mirrors":["https://docker.mirrors.ustc.edu.cn/"]}' > /etc/docker/daemon.json
# systemctl daemon-reload && systemctl restart docker

# google-pinyin
# -----------------
# apt-get install -y fcitx fcitx-googlepinyin
# im-config
# reboot
# fcitx-config-gtk3

# ssh
# -----------------
# chmod 700 .ssh
# chmod 600 .ssh/id_rsa
# chmod 644 .ssh/id_rsa.pub

ARG PROJECT_DIR

# locale
# -----------------
ENV TZ=Asia/Shanghai \
    DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y \
    && apt-get install -y ca-certificates \
    && cp /etc/apt/sources.list /etc/apt/sources.list.bak \
    && printf 'deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal main restricted universe multiverse\ndeb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal main restricted universe multiverse\ndeb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-updates main restricted universe multiverse\ndeb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-updates main restricted universe multiverse\ndeb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-backports main restricted universe multiverse\ndeb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-backports main restricted universe multiverse\ndeb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-security main restricted universe multiverse\ndeb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-security main restricted universe multiverse\n' > /etc/apt/sources.list \
    && apt-get update -y \
    && apt-get install -y tzdata language-pack-zh-hans \
    && ln -fs /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && dpkg-reconfigure --frontend noninteractive tzdata \
    && rm -rf /var/lib/apt/lists/*

ENV LANG=zh_CN.UTF-8 \
    LANGUAGE=zh_CN:zh \
    LC_ALL=zh_CN.UTF-8

# cmake
# -----------------
RUN apt-get update -y \
    && apt-get install -y build-essential curl libssl-dev \
    && cd /tmp \
    && curl -L -o cmake-3.23.1.tar.gz 'https://gh.api.99988866.xyz/https://github.com/Kitware/CMake/releases/download/v3.23.1/cmake-3.23.1.tar.gz' \
    && tar zxvf cmake-3.23.1.tar.gz \
    && cd /tmp/cmake-3.23.1 \
    && ./bootstrap --prefix=/usr/local --parallel=`nproc` \
    && make -j`nproc` \
    && make install \
    && rm -rf /tmp/cmake-3.23.1 /tmp/cmake-3.23.1.tar.gz

# clang
# -----------------
RUN apt-get update -y \
    && apt-get install -y wget software-properties-common \
    && wget -q -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - \
    && add-apt-repository 'deb https://mirrors.tuna.tsinghua.edu.cn/llvm-apt/focal/ llvm-toolchain-focal-13 main' \
    && apt-get update -y \
    && apt-get install -y clang-13 lldb-13 lld-13 clangd-13 clang-format-13 \
        libc++-13-dev libc++abi-13-dev \
    && ln -s /usr/bin/clang-13 /usr/bin/clang \
    && ln -s /usr/bin/clang++-13 /usr/bin/clang++ \
    && ln -s /usr/bin/ld.lld-13 /usr/bin/ld.lld \
    && ln -s /usr/bin/clangd-13 /usr/bin/clangd \
    && ln -s /usr/bin/clang-format-13 /usr/bin/clang-format

# vscode
# -----------------
ENV code='code --no-sandbox --user-data-dir /root/.config/vscode'

RUN apt-get update -y \
    && apt-get install -y libnss3 gnupg libxkbfile1 libsecret-1-0 \
        libgtk-3-0 libxss1 libgbm1 libasound2 tk-dev \
    && cd /tmp \
    && wget -q -O code_amd64.deb 'https://vscode.cdn.azure.cn/stable/c3511e6c69bb39013c4a4b7b9566ec1ca73fc4d5/code_1.67.2-1652812855_amd64.deb' \
    && dpkg -i code_amd64.deb \
    && rm -f code_amd64.deb

# install
# -----------------
RUN apt-get update -y \
    && apt-get build-dep -y qt5-default \
    && curl -sL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y gdb libcanberra-gtk3-module git git-lfs git-gui \
        nodejs zip tcl libxcb-xinerama0-dev jq tmux ripgrep \
    && npm install -g typescript-language-server typescript

RUN apt-get update -y \
    && apt-get install -y xclip \
    && cd /tmp \
    && curl -L -o nvim-linux64.tar.gz 'https://gh.api.99988866.xyz/https://github.com/neovim/neovim/releases/download/v0.7.0/nvim-linux64.tar.gz' \
    && tar zxvf nvim-linux64.tar.gz --directory=/usr --strip-components=1 \
    && curl -L -o lua-language-server.tar.gz 'https://gh.api.99988866.xyz/https://github.com/sumneko/lua-language-server/releases/download/3.2.5/lua-language-server-3.2.5-linux-x64.tar.gz' \
    && mkdir -p /root/app/lua-language-server \
    && tar zxvf lua-language-server.tar.gz --directory=/root/app/lua-language-server \
    && rm -f *.tar.gz

# config
# -----------------
ENV XDG_RUNTIME_DIR=/tmp/xdg-runtime-root \
    NO_AT_BRIDGE=1 \
    PATH="/root/app/lua-language-server/bin:${PATH}" \
    LD_LIBRARY_PATH=$PROJECT_DIR/deps/linux/torch/lib \
    pip=$PROJECT_DIR/deps/linux/python3/bin/pip3

RUN printf 'set -g mouse on\nset -g default-terminal "screen-256color"\n' > /root/.tmux.conf \
    && printf 'alias tmux="tmux -2"\n' >> /root/.bashrc \
    && git config --global user.name jaysinco \
    && git config --global user.email jaysinco@163.com \
    && git config --global --add safe.directory $PROJECT_DIR \
    && git config --global --add safe.directory /root/.config/nvim \
    && mkdir -p $XDG_RUNTIME_DIR \
    && chmod 700 $XDG_RUNTIME_DIR

# entry
# -----------------
WORKDIR $PROJECT_DIR
ENTRYPOINT ["/bin/bash"]
