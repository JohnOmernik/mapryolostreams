#!/bin/bash

. ./env.list


if [ -d ./conf ]; then
    CONF=1
else
    CONF=0
fi

T="$MAPR_STREAMS_TOPIC_OUTPUT"

read -e -p "Are you sure you want to delete the topic(s) $T in ${MAPR_STREAMS_STREAM_LOCATION}? (Y/N): " -i "N" CHK

if [ "$CHK" != "Y" ]; then
    echo "You did not type Y therefore we will exit"
    exit 0
fi


#for T in $MAPR_STREAMS_TOPICS; do

    echo "THis only works on the output topic $T"
    echo ""
    echo "--------------------------------------------------------------------"
    echo "Erasing topic:  ${MAPR_STREAMS_STREAM_LOCATION}:${T}"
    echo ""
    $MAPRCLI stream topic delete -path $MAPR_STREAMS_STREAM_LOCATION -topic $T
    echo ""
    sleep 2
    echo "Recreating topic: ${MAPR_STREAMS_STREAM_LOCATION}:${T}"
    $MAPRCLI stream topic create -path $MAPR_STREAMS_STREAM_LOCATION -topic $T
    echo ""
#done


if [ -d ./conf ] && [ "$CONF" == "0" ]; then
    rm -rf ./conf
fi
