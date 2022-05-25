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
## Install minicuda

## Install Dependencies

```bash
# Fix `jax` for TPU/GPU not found
/tmp/tts/miniconda3/bin/pip install --upgrade "jax[cuda]" -f https://storage.googleapis.com/jax-releases/jax_releases.html
```
