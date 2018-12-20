#!/usr/bin/python3
import os
import sys
sys.path.append('/app/darknet')
import python.darknet
import cv2
from collections import OrderedDict
import base64
import confluent_kafka
from confluent_kafka import Producer, KafkaError, version, libversion, Consumer
import json
import time
import datetime
import numpy as np
from PIL import Image, ImageFont, ImageDraw, ImageEnhance

from io import BytesIO
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import re

try:
    save_images = int(os.environ["APP_YOLO_SAVE_CLASS_IMG"].replace('"', ''))
except:
    print("Could not read APP_YOLO_SAVE_CLASS_IMG value from ENV defaulting to true (1)")
    save_images = 1

try:
    topic_frames =  os.environ["MAPR_STREAMS_STREAM_INPUT_LOCATION"].replace('"', '') + ":" + os.environ["MAPR_STREAMS_TOPIC_INPUT"].replace('"', '')
except:
    print("Error getting MAPR_STREAMS_STREAM_LOCATION and MAPR_STREAMS_TOPIC_INPUT from env")
    sys.exit(1)

try:
    topic_class_frames =  os.environ["MAPR_STREAMS_STREAM_LOCATION"].replace('"', '') + ":" + os.environ["MAPR_STREAMS_TOPIC_OUTPUT"].replace('"', '')
except:
    print("Error getting MAPR_STREAMS_STREAM_LOCATION and MAPR_STREAMS_TOPIC_OUTPUT from env")
    sys.exit(1)

try:
    weights_file = os.environ["APP_YOLO_WEIGHTS_DIR"].replace('"', '') + "/" + os.environ["APP_YOLO_WEIGHTS_FILE"].replace('"', '')
    print("Weights: %s" % weights_file)
except:
    print("Error getting APP_YOLO_WEIGHTS_DIR and APP_YOLO_WEIGHTS_FILE from env")
    sys.exit(1)


try:
    consumer_group = os.environ["APP_STREAMS_CONSUMER_GROUP"].replace('"', '')
except:
    print("Could not get APP_STREAMS_CONSUMER_GROUP from env")
    sys.exit(1)

try:
    consumer_group_start = os.environ["APP_STREAMS_CONSUMER_GROUP_START"].replace('"', '')
except:
    print("Could not get APP_STREAMS_CONSUMER_GROUP_START from env")
    sys.exit(1)


print("Loading Net")
net = python.darknet.load_net(b"/app/darknet/cfg/yolov3.cfg",weights_file.encode(),0)
print("Loading Meta")
meta = python.darknet.load_meta(b"/app/darknet/cfg/coco.data")
border = 4


def main ():


    print("Confluent Kafka Version: %s - Libversion: %s" % (version(), libversion()))
    print("")
    print("Using weights file: %s" % weights_file)
    print("")
    print("Consuming raw video frames from %s" % topic_frames)
    print("")
    print("Producing classified video frames to: %s" % topic_class_frames)
    print("")
    print("Consumer group name: %s" % consumer_group)
    print("")
    print("Consumer group start: %s" % consumer_group_start)


    con_conf = {'bootstrap.servers': '', 'group.id': consumer_group, 'default.topic.config': {'auto.offset.reset': consumer_group_start}}
    pro_conf = {'bootstrap.servers': '', 'message.max.bytes':'2978246'}
    c = Consumer(con_conf)
    p = Producer(pro_conf)

    c.subscribe([topic_frames])

    running = True
    while running:
        msg = c.poll(timeout=1.0)
        if msg is None: continue
        if not msg.error():
            mymsg = json.loads(msg.value().decode('utf-8'), object_pairs_hook=OrderedDict)
            mypart = msg.partition()
            myoffset = msg.offset()
            outmsg = OrderedDict()
            outmsg['ts'] = mymsg['ts']
            outmsg['epoch_ts'] = mymsg['epoch_ts']
            outmsg['cam_name'] = mymsg['cam_name']
            outmsg['src_partition'] = mypart
            outmsg['src_offset'] = myoffset
            mybytes = base64.b64decode(mymsg['img'])
            o = open("/dev/shm/tmp.jpg", "wb")
            o.write(mybytes)
            o.close
#            myimage = np.array(Image.open(BytesIO(mybytes))) 

            r = python.darknet.detect(net, meta, b'/dev/shm/tmp.jpg')
            if r != []:
                curtime = datetime.datetime.now()
                mystrtime = curtime.strftime("%Y-%m-%d %H:%M:%S")
                epochtime = int(time.time())
                arclass = []
                if save_images == 1:
                    try:
                        image = Image.open(BytesIO(mybytes)).convert("RGBA")
                    except:
                        continue
                    draw = ImageDraw.Draw(image)
                    for q in r:
                        j = OrderedDict()
                        name = q[0]
                        j['name'] = name.decode()
                        predict = q[1]
                        j['predict'] = predict
                        x = q[2][0]
                        y = q[2][1]
                        w = q[2][2]
                        z = q[2][3]
                        x_max = (2*x+w)/2
                        x_min = (2*x-w)/2
                        y_min = (2*y-z)/2
                        y_max = (2*y+z)/2
                        j['x_min'] = x_min
                        j['x_max'] = x_max
                        j['y_min'] = y_min
                        j['y_max'] = y_max
                        for x in range(border):
                            draw.rectangle(((x_min - x, y_min - x), (x_max + x, y_max + x)), fill=None, outline="black")
                        draw.text((x_min + border + 2, y_max - border - 5), name)
                        arclass.append(j)

                    imgSave = BytesIO()
                    image.save(imgSave, format='JPEG')
                    imgSave = imgSave.getvalue()
                    encdata = base64.b64encode(imgSave)
                    encdatastr = encdata.decode('utf-8')
                else:
                    encdatastr = ""
                outmsg['class_json'] = arclass
                outmsg['class_ts'] = mystrtime
                outmsg['class_epoch_ts'] = epochtime
                outmsg['class_img'] = encdatastr
                produceMessage(p, topic_class_frames, json.dumps(outmsg))
            else:
                pass



def produceMessage(p, topic, message_json):
    try:
        p.produce(topic, value=message_json, callback=delivery_callback)
        p.poll(0)
    except BufferError as e:
        print("Buffer full, waiting for free space on the queue")
        p.poll(10)
        p.produce(topic, value=message_json,callback=delivery_callback)
    except KeyboardInterrupt:
        print("\n\nExiting per User Request")
        p.close()
        sys.exit(0)

def delivery_callback(err, msg):
    """ Called once for each message produced to indicate delivery result.
        Triggered by poll() or flush(). """
    if err is not None:
        print('Message delivery failed to %s failed: %s' % (msg.topic(), err))
    else:
        pass

if __name__ == '__main__':
    main()


