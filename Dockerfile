FROM maprcuda:6.1.0_6.0.0_ubuntu16
WORKDIR /app

# Versions being run
ENV MAPR_LIBRDKAFKA_BASE="http://package.mapr.com/releases/MEP/MEP-5.0/ubuntu"
ENV MAPR_LIBRDKAFKA_FILE="mapr-librdkafka_0.11.3.201803231414_all.deb"


RUN apt-get update && apt-get install -y --no-install-recommends python3 cmake git sudo nano vim python3-numpy python3-pip python3-pil python3-scipy python3-matplotlib build-essential python3-bs4 \
                         python python-dev python-setuptools python-pip python3 python3-dev python3-setuptools  \
                        zlib1g-dev libssl-dev libsasl2-dev liblz4-dev libsnappy1v5 libsnappy-dev liblzo2-2 liblzo2-dev \
                        python-docutils \
         && rm -rf /var/lib/apt/lists/*



ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64:/usr/local/cuda/lib:/usr/local/cuda/lib64:/usr/local/cuda-9.1/lib:/usr/local/cuda-9.1/lib64:/opt/mapr

RUN wget https://raw.githubusercontent.com/milq/milq/master/scripts/bash/install-opencv.sh && chmod +x install-opencv.sh && \
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/nvidia/lib:/usr/local/nvidia/lib64:/usr/local/cuda/lib64:/usr/local/cuda/lib64/stubs && \
    sed -i "s@-DFORCE_VTK=ON@-DFORCE_VTK=ON -DCMAKE_LIBRARY_PATH=/usr/local/cuda/lib64/stubs@" install-opencv.sh && \
    sed -i "s@-DBUILD_EXAMPLES=ON@-DBUILD_EXAMPLES=OFF@" install-opencv.sh && \
    cat install-opencv.sh && \
    bash install-opencv.sh && rm -rf /app/OpenCV && rm /app/install-opencv.sh

# These are suspect fixes for an Open CV Build that seems to be problemactic"


RUN sed -i "s/CVAPI(cv::Rect)/CVAPI(CvRect)/g" /usr/local/include/opencv2/highgui/highgui_c.h

RUN sed -i '485s@.*@//&@' /usr/local/include/opencv2/core/cvdef.h && sed -i '486s@.*@//&@' /usr/local/include/opencv2/core/cvdef.h && \
    sed -i '487s@.*@//&@' /usr/local/include/opencv2/core/cvdef.h && sed -i '488s@.*@//&@' /usr/local/include/opencv2/core/cvdef.h && \
    sed -i '489s@.*@//&@' /usr/local/include/opencv2/core/cvdef.h && sed -i '490s@.*@//&@' /usr/local/include/opencv2/core/cvdef.h && \
    sed -i '491s@.*@//&@' /usr/local/include/opencv2/core/cvdef.h && sed -i '492s@.*@//&@' /usr/local/include/opencv2/core/cvdef.h && \
    sed -i '493s@.*@//&@' /usr/local/include/opencv2/core/cvdef.h && sed -i '494s@.*@//&@' /usr/local/include/opencv2/core/cvdef.h



RUN git clone https://github.com/pjreddie/darknet && cd darknet && sed -i "s/OPENCV=0/OPENCV=1/" ./Makefile && sed -i "s/GPU=0/GPU=1/" ./Makefile && sed -i "s@# ARCH= -gencode arch=compute_52,code=compute_52@ARCH= -gencode arch=compute_50,code=sm_50@" ./Makefile && make

# Get Weights file (We are using the v3 weights)

#RUN cd /app/darknet  && wget https://pjreddie.com/media/files/yolo.weights

#RUN cd /app/darknet && wget https://pjreddie.com/media/files/yolov3.weights

RUN sed -i "s/print r//g" /app/darknet/python/darknet.py


RUN sed -i "s/width=608/width=416/g" /app/darknet/cfg/yolov3.cfg && sed -i "s/height=608/height=416/g" /app/darknet/cfg/yolov3.cfg && sed -i "s/batch=64/batch=32/g" /app/darknet/cfg/yolov3.cfg && sed -i "s/subdivisions=16/subdivisions=32/g" /app/darknet/cfg/yolov3.cfg

#RUN sed -i "s@im = load_image(image, 0, 0)@im = image@g" /app/darknet/python/darknet.py




RUN echo "classes= 80" > /app/darknet/cfg/coco.data
RUN echo "train  = /home/pjreddie/data/coco/trainvalno5k.txt" >> /app/darknet/cfg/coco.data
RUN echo "valid = /app/darknet/data/coco_val_5k.list" >> /app/darknet/cfg/coco.data
RUN echo "names = /app/darknet/data/coco.names" >> /app/darknet/cfg/coco.data
RUN echo "backup = /home/pjreddie/backup/" >> /app/darknet/cfg/coco.data
RUN echo "eval=coco" >> /app/darknet/cfg/coco.data


RUN sed -i "s@libdarknet.so@/app/darknet/libdarknet.so@g" /app/darknet/python/darknet.py


#ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
#ENV LIBRARY_PATH=/opt/mapr/lib
#ENV C_INCLUDE_PATH=/opt/mapr/include

# Install MapR LibRD KAfka - Have to unpack it and manually install it into the PACC This is now down in 6.1.0!
#RUN MYPWD=`pwd` && wget ${MAPR_LIBRDKAFKA_BASE}/${MAPR_LIBRDKAFKA_FILE} && dpkg -x ${MAPR_LIBRDKAFKA_FILE} ./tmp  && \
#    mkdir /opt/mapr/include/librdkafka && cp ./tmp/opt//mapr/include/librdkafka/* /opt/mapr/include/librdkafka/ && \
#    cp ./tmp/opt/mapr/lib/librdkafka.so.1 /opt/mapr/lib/ &&  cd /opt/mapr/lib && ln -s librdkafka.so.1 librdkafka.so && ln -s librdkafka.so.1 librdkafka.a &&  ln -s libMapRClient.so libMapRClient_c.so && cd $MYPWD && \
#    rm -rf ./tmp && rm ./${MAPR_LIBRDKAFKA_FILE} && ldconfig

RUN ln -s /opt/mapr/lib/librdkafka_jvm.so.1 /usr/lib/librdkafka_jvm.so && \
    ln -s /opt/mapr/lib/librdkafka_jvm.so.1 /usr/lib/librdkafka_jvm.so.1 && \
    ln -s /opt/mapr/lib/librdkafka.so.1 /usr/lib/librdkafka.so && \
    ln -s /opt/mapr/lib/librdkafka.so.1 /usr/lib/librdkafka.so.1 && \
    ln -s /opt/mapr/lib/libMapRClient_c.so.1 /usr/lib/libMapRClient_c.so.1 && \
    ln -s /opt/mapr/lib/libMapRClient_c.so.1 /usr/lib/libMapRClient_c.so  && \
    ln -s /opt/mapr/lib/libMapRClient.so.1 /usr/lib/libMapRClient.so.1 && \
    ln -s /opt/mapr/lib/libMapRClient.so.1 /usr/lib/libMapRClient.so  && \
    ln -s /opt/mapr/include/librdkafka /usr/include/librdkafka


RUN pip install python-snappy python-lzo brotli kazoo requests pytest
RUN pip3 install python-snappy python-lzo brotli kazoo requests pytest

ENV MAPR_STREAMS_PYTHON="http://archive.mapr.com/releases/MEP/MEP-5.0/mac/mapr-streams-python-0.11.0.tar.gz"
RUN pip install --global-option=build_ext --global-option="--library-dirs=/opt/mapr/lib" --global-option="--include-dirs=/opt/mapr/include/" $MAPR_STREAMS_PYTHON
RUN pip3 install --global-option=build_ext --global-option="--library-dirs=/opt/mapr/lib" --global-option="--include-dirs=/opt/mapr/include/" $MAPR_STREAMS_PYTHON

CMD ["/bin/bash"]
