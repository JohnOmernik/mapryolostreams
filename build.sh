#!/bin/bash

. ./env.list

MYDIR=$(pwd)

echo "Building MapR Cuda first"
cd ./maprcuda
./build.sh
cd ..

# Build Image
sudo docker build -t $APP_IMG .

if [ "$?" == "0" ]; then
    echo "Image Build - Sucess!"
else
    echo "Image did not build correctly"
    exit 1
fi
