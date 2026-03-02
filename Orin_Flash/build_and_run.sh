#!/bin/bash

# Build Dockerfile
docker build -t orin-image .

# Optional: bind-mount the Auvidea X230D kernel_out BSP directory when flashing
# auvidea-x230d-agx-orin-64gb. Set AUVIDEA_BSP_PATH on the host before running:
#   export AUVIDEA_BSP_PATH=/path/to/auvidea_x230d/kernel_out
#   ./build_and_run.sh
auvidea_mount_arg=""
if [ -n "${AUVIDEA_BSP_PATH}" ] && [ -d "${AUVIDEA_BSP_PATH}" ]; then
    auvidea_mount_arg="-v ${AUVIDEA_BSP_PATH}:/data/auvidea-bsp:ro"
    echo "Mounting Auvidea BSP from: ${AUVIDEA_BSP_PATH}"
fi

# Run resulting Docker image. The balenaOS image downloaded from balena-cloud is expected to exist in the HOST, inside ~/images. That directory will be bind-mounted inside the running container in /data/images/
docker container run --rm -it --privileged -v /dev/:/dev/ -v ~/images:/data/images ${auvidea_mount_arg} orin-image /bin/bash

