#!/bin/bash

STARTIMG="nvidia/cuda:9.1-devel-ubuntu16.04"

echo "When prompted use the following:"

echo "Image OS class: ubuntu16"

echo "Docker FROM: $STARTIMG"

echo "MapR Core: 6.1.0"

echo "MapR MEP: 6.0.0"

echo "Install Hadoop YARN client: n"

echo "MapR Image name: maprcuda:6.1.0_6.0.0_ubuntu16"

echo "Container network mode: bridge (default)"

echo "Container memory: 0 (default)"

sudo ./mapr-setup.sh docker client

sudo rm -rf ./docker_images


