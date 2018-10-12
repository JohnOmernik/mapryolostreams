#!/usr/bin/python3
import os, sys
import shutil
import re


sortfolder = "/app/classout"



files = os.listdir(sortfolder)

for f in files:
    match = re.search(r'_(\d{8})', f)
    print(f)
    redate = ""

    if match:
        redate = match.group(1)
    if redate:
        outdir = sortfolder + "/" + redate
        if not os.path.isdir(outdir):
            os.mkdir(outdir)
        shutil.move(sortfolder + "/" + f, outdir + "/" + f)
        outdir = ""
