FROM ubuntu:22.04 AS deps

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    wget \
    ca-certificates \
    gnupg \
    git \
    rsync \
    pkg-config \
    ninja-build \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libx11-dev \
    libxrandr-dev \
    libxinerama-dev \
    libxcursor-dev \
    libxi-dev \
    libwayland-dev \
    libxkbcommon-dev \
    wayland-protocols \
    extra-cmake-modules \
    && rm -rf /var/lib/apt/lists/*

# CMAKE
RUN wget -qO- https://apt.kitware.com/keys/kitware-archive-latest.asc \
    | gpg --dearmor -o /usr/share/keyrings/kitware-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ jammy main" \
    > /etc/apt/sources.list.d/kitware.list \
    && apt-get update && apt-get install -y --no-install-recommends cmake \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /deps

# GLM
ARG GLM_VERSION=1.0.1
RUN git clone --depth 1 --branch ${GLM_VERSION} https://github.com/g-truc/glm.git \
    && cmake -S glm -B glm/build -G Ninja \
        -DGLM_BUILD_TESTS=OFF \
        -DGLM_BUILD_LIBRARY=OFF \
        -DCMAKE_BUILD_TYPE=Release \
    && cmake --build glm/build \
    && cmake --install glm/build \
    && rm -rf glm

# GLFW
ARG GLFW_VERSION=3.4
RUN git clone --depth 1 --branch ${GLFW_VERSION} https://github.com/glfw/glfw.git \
    && cmake -S glfw -B glfw/build -G Ninja \
        -DBUILD_SHARED_LIBS=OFF \
        -DGLFW_BUILD_EXAMPLES=OFF \
        -DGLFW_BUILD_TESTS=OFF \
        -DGLFW_BUILD_DOCS=OFF \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    && cmake --build glfw/build -j$(nproc) \
    && cmake --install glfw/build \
    && rm -rf glfw

# ASSIMP
ARG ASSIMP_VERSION=v5.4.3
RUN git clone --depth 1 --branch ${ASSIMP_VERSION} https://github.com/assimp/assimp.git \
    && cmake -S assimp -B assimp/build -G Ninja \
        -DBUILD_SHARED_LIBS=OFF \
        -DASSIMP_BUILD_TESTS=OFF \
        -DASSIMP_BUILD_ASSIMP_TOOLS=OFF \
        -DASSIMP_INSTALL_PDB=OFF \
        -DASSIMP_BUILD_ZLIB=ON \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    && cmake --build assimp/build -j2 \
    && cmake --install assimp/build \
    && rm -rf assimp

COPY build.sh /usr/local/bin/build.sh
RUN chmod +x /usr/local/bin/build.sh

WORKDIR /

ENTRYPOINT ["sleep", "infinity"]
