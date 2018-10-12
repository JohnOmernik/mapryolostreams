#!/usr/bin/python3
import os, sys

sys.path.append('/app/darknet')
import python.darknet
import numpy as np
from PIL import Image, ImageFont, ImageDraw, ImageEnhance
import matplotlib.pyplot as plt
import matplotlib.patches as patches

net = python.darknet.load_net(b"/app/darknet/cfg/yolo.cfg",b"/app/darknet/yolo.weights",0)
meta = python.darknet.load_meta(b"/app/darknet/cfg/coco.data")

folder = "/app/raw_images/"
files = os.listdir(folder)

for f in files:
    if f.endswith(".jpg") or f.endswith(".jpeg") or f.endswith(".png"):
        print (f)
        path = bytes(os.path.join(folder, f), encoding="utf-8")
        r = python.darknet.detect(net, meta, path)
        if r != []:
            print(r)
            for q in r:
            name = r[0][0]
            predict = r[0][1]
            x = r[0][2][0]
            y = r[0][2][1]
            w = r[0][2][2]
            z = r[0][2][3]
            x_max = (2*x+w)/2
            x_min = (2*x-w)/2
            y_min = (2*y-z)/2
            y_max = (2*y+z)/2
            print(x_min, y_min, x_max, y_max)
            image = Image.open(path).convert("RGBA")
            draw = ImageDraw.Draw(image)



            for x in range(5):
                draw.rectangle(((x_min - x, y_min - x), (x_max + x, y_max + x)), fill=None, outline="black")

#            cropped = image.crop((int(x_min), int(y_min+20), int(x_max), int(y_max)))
            saving_path = "crop_images/"+f
            save_file = open(saving_path, 'w')
            image.save(saving_path)
            save_file.close()
        else:
            print("\t -> No Detection on %s" % f)
