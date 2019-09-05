#!/bin/bash

# Create a Beaker image using provided image name tagged with the current username and git commit hash
# of the repo. Key difference from create_docker_image: it will not push this image to docker, but
# instead create a Beaker blueprint.
# Usage: ./scripts/create_beaker_image.sh [image_prefix]


IMAGE_NAME=${1-OpenBookQA}
DOCKERFILE_NAME=Dockerfile

# Image name
GIT_HASH=`git log --format="%h" -n 1`
IMAGE=$IMAGE_NAME_$USER-$GIT_HASH
BP_NAME=$IMAGE

# Build the image (if needed)
if [[ "$(docker images -q $IMAGE 2> /dev/null)" == "" ]]; then
  echo "Building $IMAGE"
  docker build -f $DOCKERFILE_NAME -t $IMAGE .
  beaker blueprint create --name=$BP_NAME --desc="OpenBookQA Repo; Git Hash: $GIT_HASH" $IMAGE
else
  image_spec=`beaker blueprint inspect $BP_NAME`
  if [[ -z $image_spec ]]; then
    echo "No beaker blueprint with name $image_spec"
    unset BP_NAME
    exit 1
  else
    echo "Running with beaker blueprint: $image_spec"
  fi
fi