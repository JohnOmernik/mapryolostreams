#!/bin/bash
. ./env.list

RAW_IMAGES="/zeta/brewpot/apps/prod/homeimgrec/raw_images"
OUT_IMAGES="/zeta/brewpot/apps/prod/homeimgrec/processed_images"
CLASS_IMAGES="/zeta/brewpot/apps/prod/homeimgrec/class_images"
CODE="/zeta/brewpot/apps/prod/homeimgrec/yolo/code"
WEIGHTS="/zeta/brewpot/apps/prod/homeimgrec/yolo/weights"
CMD="/bin/bash"

PORTS=""
#VOLS="-v=/tmp/mapr_ticket:/tmp/mapr_ticket:ro -v=${CODEDIR}:/app/code"
#VOLS="-v=/zeta/brewpot/apps/prod/homeimgrec/dirmonitor/maprpaccstreams/myticket:/tmp/mapr_ticket:ro -v=/zeta/brewpot/apps/prod/homeimgrec/dirmonitor/code:/app/code"
VOLS="-v=${CLASS_IMAGES}:/app/classout -v=${WEIGHTS}:/app/weights -v=${RAW_IMAGES}:/app/raw_images -v=${OUT_IMAGES}:/app/out_images -v=${CODE}:/app/code -v=/zeta/brewpot/apps/prod/homeimgrec/dirmonitor/maprpaccstreams/myticket:/tmp/mapr_ticket:ro"

sudo docker run -it $PORTS --env-file ./env.list $VOLS \
   --runtime=nvidia \
   --device /dev/fuse \
   --cap-add SYS_ADMIN \
   --cap-add SYS_RESOURCE \
   --security-opt apparmor:unconfined \
   $IMG \
   $CMD



