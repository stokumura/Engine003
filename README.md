# Engine003
OpenGL Graphics Engine

## Build Container
### Setup
#### Build Image
docker build -t engine003-builder .

#### Create Container
docker create --name engine003-build \
    -v $(pwd):/local-src \
    -v ~/Builds:/output \
    engine002-builder
    
### How to use
#### Start
docker start engine003-build

#### Build Release
docker exec -e BUILD_TYPE=Release engine003-build build.sh

#### Build Debug
docker exec -e BUILD_TYPE=Debug engine003-build build.sh

#### Stop
docker stop engine003-build
