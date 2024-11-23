FROM nvcr.io/nvidia/pytorch:21.12-py3

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y git

RUN mkdir "/comfyui"
WORKDIR "/comfyui"

RUN git clone https://github.com/comfyanonymous/ComfyUI
WORKDIR "/comfyui/ComfyUI"
RUN git pull
RUN pip install -r requirements.txt

ENTRYPOINT python main.py --dont-print-server --listen=0.0.0.0