FROM nvcr.io/nvidia/pytorch:21.12-py3

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y git
RUN apt-get install -y wget

RUN mkdir "/comfyui"
WORKDIR "/comfyui"

RUN git clone https://github.com/comfyanonymous/ComfyUI
WORKDIR "/comfyui/ComfyUI"
RUN git pull
RUN pip install -r requirements.txt

RUN wget -c https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.ckpt -P ./models/checkpoints/

ENTRYPOINT python main.py --dont-print-server --listen=0.0.0.0