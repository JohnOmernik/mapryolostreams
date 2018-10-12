#!/usr/bin/python3
import os, sys

sys.path.append('/app/darknet')
import python.darknet
import numpy as np
from PIL import Image, ImageFont, ImageDraw, ImageEnhance
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import shutil
import re


net = python.darknet.load_net(b"/app/darknet/cfg/yolov3.cfg",b"/app/weights/yolov3.weights",0)
meta = python.darknet.load_meta(b"/app/darknet/cfg/coco.data")

border = 4


folder = "/app/raw_images/"
classout = "/app/classout"
destclass = "/app/out_images/class"
destnoclass = "/app/out_images/noclass"
files = os.listdir(folder)

for f in files:
    redate = "unknown"
    if f.endswith(".jpg") or f.endswith(".jpeg") or f.endswith(".png"):
        match = re.search(r'_(\d{8})', f)

        if match:
            redate = match.group(1)
        outdir = classout + "/" + redate
        if not os.path.isdir(outdir):
            os.mkdir(outdir)

        print (f)
        strpath = os.path.join(folder, f)
        path = bytes(strpath, encoding="utf-8")
        r = python.darknet.detect(net, meta, path)
        if r != []:
            try:
                image = Image.open(path).convert("RGBA")
            except:
                continue
            draw = ImageDraw.Draw(image)
            print(r)
            for q in r:
                name = q[0]
                predict = q[1]
                x = q[2][0]
                y = q[2][1]
                w = q[2][2]
                z = q[2][3]
                x_max = (2*x+w)/2
                x_min = (2*x-w)/2
                y_min = (2*y-z)/2
                y_max = (2*y+z)/2
                print(x_min, y_min, x_max, y_max)
                for x in range(border):
                    draw.rectangle(((x_min - x, y_min - x), (x_max + x, y_max + x)), fill=None, outline="black")
                draw.text((x_min + border + 2, y_max - border - 5), name)

#            cropped = image.crop((int(x_min), int(y_min+20), int(x_max), int(y_max)))
            saving_path = outdir + "/" + f
            save_file = open(saving_path, 'w')
            image.save(saving_path)
            save_file.close()
            print("Path: %s - destclass: %s" % (strpath, destclass + "/" + f))
            shutil.move(path, destclass + "/" + f)
        else:
            print("\t -> No Detection on %s" % f)
            print("Path: %s - destclass: %s" % (strpath, destnoclass + "/" + f))
            shutil.move(path, destnoclass + "/" + f)
