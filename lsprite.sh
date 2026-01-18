#!/bin/bash

IMAGE_NAME="local-sprite-base"

# Auto-detect if sudo is needed for docker
if ! docker ps >/dev/null 2>&1; then
    DOCKER_CMD="sudo docker"
else
    DOCKER_CMD="docker"
fi

case "$1" in
  build)
    echo "Building $IMAGE_NAME..."
    $DOCKER_CMD build -t $IMAGE_NAME -f Dockerfile.sprite .
    ;;
  create|up)
    NAME=$2
    if [ -z "$NAME" ]; then echo "Usage: $0 up <name>"; exit 1; fi
    if [ "$($DOCKER_CMD ps -a -q -f name=^/${NAME}$)" ]; then
        echo "Sprite '$NAME' already exists. Starting it..."
        $DOCKER_CMD start "$NAME"
    else
        echo "Launching sprite: $NAME"
        # Mount current dir to /workspace inside
        $DOCKER_CMD run -d --name "$NAME" -e SPRITE_NAME="$NAME" -v "$(pwd):/workspace" $IMAGE_NAME
    fi
    ;;
  in)
    NAME=$2
    if [ -z "$NAME" ]; then echo "Usage: $0 in <name>"; exit 1; fi
    $DOCKER_CMD exec -it "$NAME" bash
    ;;
  rm)
    NAME=$2
    if [ -z "$NAME" ]; then echo "Usage: $0 rm <name>"; exit 1; fi
    $DOCKER_CMD rm -f "$NAME"
    ;;
  ls)
    $DOCKER_CMD ps --filter "ancestor=$IMAGE_NAME"
    ;;
  key)
    NAME=$2
    if [ -z "$NAME" ]; then echo "Usage: $0 key <name>"; exit 1; fi
    # Grep the key from the logs (grabbing the last occurrence if multiple exist)
    $DOCKER_CMD logs "$NAME" 2>&1 | grep "ssh-ed25519" | tail -n 1
    ;;
  *)
    echo "Usage: $0 {build|create|up|in|rm|ls|key}"
    exit 1
    ;;
esac
