#!/bin/bash


. ./env.list

PORTS=""

MYDIR=$(pwd)

if [ "$MAPR_TICKETFILE_LOCATION" != "" ]; then
#    echo "Setting Secure Cluster"
    VOLS="-v=${MAPR_TICKET_HOST_LOCATION}:${MAPR_TICKET_CONTAINER_LOCATION}:ro"
else
    VOLS=""
fi


if [ ! -d "${APP_YOLO_WEIGHTS_DIR}" ]; then
#    echo "Creating ${APP_YOLO_WEIGHTS_DIR}"
    mkdir -p ${APP_YOLO_WEIGHTS_DIR}
fi

if [ ! -f "${APP_YOLO_WEIGHTS_DIR}/${APP_YOLO_WEIGHTS_FILE}" ]; then
    echo "${APP_YOLO_WEIGHTS_DIR}/${APP_YOLO_WEIGHTS_FILE} not found attempting to download"
    cd ${APP_YOLO_WEIGHTS_DIR}
    wget ${APP_YOLO_WEIGHTS_URL}
    if [ "$?" != "0" ]; then
        echo "Could not get weights, exiting"
        exit 1
    fi
    cd $MYDIR
fi


PORTS=""

# If the APP_CMD is blank OR a 1  is passed as an argument to run.sh run the conainter with /bin/bash
# This allows you to update the command in the container to start the app directly 
if [ "$APP_CMD" == "" ] || [ "$1" == "1" ]; then
    APP_CMD="/bin/bash"
fi
# Basically do we run Docker interactive?
RUN_TYPE=""
if [ "$APP_CMD" == "/bin/bash" ]; then
    RUN_TYPE="-it"
else
    RUN_TYPE="-d"
fi


# Read the env.list and create the env.list.docker to use. 
env|sort|grep -P "^(MAPR_|APP_)" > ./env.list.docker
# --ipc host \

sudo docker run $RUN_TYPE $PORTS $VOLS --env-file ./env.list.docker \
--runtime=nvidia \
--device /dev/fuse \
--cap-add SYS_ADMIN \
--cap-add SYS_RESOURCE \
--security-opt apparmor:unconfined \
 $APP_IMG $APP_CMD
