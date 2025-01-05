#!/bin/bash

sudo apt install ffmpeg portaudio19-dev 
python3 -m venv .
source bin/activate
pip install -r requirements.python.txt

