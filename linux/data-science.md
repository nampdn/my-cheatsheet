# INSTALL DATA SCIENCE DEV ON UBUNTU 18.04

## Install Docker
## Install NVIDIA RUNTIME
## Build custom Docker image for jupyterlab
## Install minicuda

## Install Dependencies

```bash
# Fix `jax` for TPU/GPU not found
/tmp/tts/miniconda3/bin/pip install --upgrade "jax[cuda]" -f https://storage.googleapis.com/jax-releases/jax_releases.html
```
