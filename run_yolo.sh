#!/bin/bash



IMG="dockerregv2-shared.marathon.slave.mesos:5005/yolo:latest"

RAW_IMAGES="/zeta/brewpot/apps/prod/homeimgrec/raw_images"

OUT_IMAGES="/zeta/brewpot/apps/prod/homeimgrec/processed_images"

CLASS_IMAGES="/zeta/brewpot/apps/prod/homeimgrec/class_images"

CODE="/zeta/brewpot/apps/prod/homeimgrec/yolo/code"

sudo docker run --runtime=nvidia -it -v=${CLASS_IMAGES}:/app/classout -v=${RAW_IMAGES}:/app/raw_images -v=${OUT_IMAGES}:/app/out_images -v=${CODE}:/app/code $IMG
