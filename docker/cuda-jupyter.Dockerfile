FROM nvidia/cuda:11.2.0-cudnn8-devel-ubuntu18.04
ENV PATH="/root/miniconda3/bin:${PATH}"
ARG PATH="/root/miniconda3/bin:${PATH}"
RUN apt-get update

RUN apt-get install -y wget libsndfile1 sox libsox-fmt-mp3 zsh tmux nmon vim && rm -rf /var/lib/apt/lists/*

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
