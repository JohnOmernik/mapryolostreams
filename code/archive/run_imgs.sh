#!/bin/bash

cd /app/raw_images
FILELIST="/tmp/filelist.txt"
rm $FILELIST
for F in ./*.jpg; do
    echo "$F" |sed "s@\./@/app/raw_images/@g" >> $FILELIST
done

cd /app/darknet

cat $FILELIST|./darknet detect cfg/yolo.cfg yolo.weights
