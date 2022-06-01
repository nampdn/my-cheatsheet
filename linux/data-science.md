# INSTALL DATA SCIENCE DEV ON UBUNTU 18.04

## Install Docker
```bash
wget https://raw.githubusercontent.com/dokku/dokku/v0.27.4/bootstrap.sh
sudo DOKKU_TAG=v0.27.4 bash bootstrap.sh
```

## Install NVIDIA RUNTIME

```bash
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
      && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
      && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
            sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
            sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
            
sudo apt-get update

sudo apt-get install -y nvidia-docker2

sudo systemctl restart docker

sudo docker run --rm --gpus all nvidia/cuda:11.0.3-base-ubuntu20.04 nvidia-smi
```

## Build custom Docker image for jupyterlab

```Dockerfile
FROM nvidia/cuda:11.2.0-devel-ubuntu20.04

ENV PATH="/root/miniconda3/bin:${PATH}"
ARG PATH="/root/miniconda3/bin:${PATH}"
RUN apt-get update


# declare the image name
ENV IMG_NAME=11.2.0-devel-ubuntu20.04 \
    # declare what jaxlib tag to use
    # if a CI/CD system is expected to pass in these arguments
    # the dockerfile should be modified accordingly
    JAXLIB_VERSION=0.3.0

RUN apt-get install -y wget libsndfile1 python3-pip sox libsox-fmt-mp3 zsh tmux nmon vim && rm -rf /var/lib/apt/lists/*
RUN pip3 install numpy scipy six wheel jaxlib==${JAXLIB_VERSION}+cuda11.cudnn82 -f https://storage.googleapis.com/jax-releases/jax_releases.html jax[cuda11_cudnn82] -f https://storage.googleapis.com/jax-releases/jax_releases.html


RUN wget \
    https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && mkdir /root/.conda \
    && bash Miniconda3-latest-Linux-x86_64.sh -b \
    && rm -f Miniconda3-latest-Linux-x86_64.sh
RUN conda --version
RUN conda install -c conda-forge jupyterlab pytorch torchvision gdown tqdm

WORKDIR /content

ENTRYPOINT ["jupyter-lab"]
CMD ["--allow-root", "--ip=0.0.0.0"]
```

## Install minicuda

## Install Dependencies
```
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/${last_public_key}.pub
sudo add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /"
sudo apt-get update
sudo apt-get install libcudnn8
sudo apt-get install libcudnn8-dev
```
where ${last_public_key} is the last public key (file with .pub extension) published on https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/. (At May 9th 2022 when this post was edit, it was 3bf863cc.pub).

[Source](https://stackoverflow.com/questions/66977227/could-not-load-dynamic-library-libcudnn-so-8-when-running-tensorflow-on-ubun)

```bash
# Fix `jax` for TPU/GPU not found
/tmp/tts/miniconda3/bin/pip install --upgrade "jax[cuda]" -f https://storage.googleapis.com/jax-releases/jax_releases.html
```
