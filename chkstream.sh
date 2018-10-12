#!/bin/bash

. ./env.list

if [ -d ./conf ]; then
    CONF=1
else
    CONF=0
fi

echo "Checking the following topics $MAPR_STREAMS_TOPICS in stream $MAPR_STREAMS_STREAM_LOCATION"
echo ""
echo "First some Stream Information on $MAPR_STREAMS_STREAM_LOCATION"
echo ""
$MAPRCLI stream info -path $MAPR_STREAMS_STREAM_LOCATION
echo ""
echo "-------------------------------------------------------------------------"




for T in $MAPR_STREAMS_TOPICS; do
    echo ""
    echo "--------------------------------------------------------------------"
    echo "Checking ${MAPR_STREAMS_STREAM_LOCATION}:${T}"
    echo ""
    $MAPRCLI stream topic info -path $MAPR_STREAMS_STREAM_LOCATION -topic $T
    echo ""
done


if [ -d ./conf ] && [ "$CONF" == "0" ]; then
    rm -rf ./conf
fi
