#!/usr/bin/env bash
set -euo pipefail

ENV_NAME="harmoni"
REQS="$HOME/repos/HARMONI_V2/requirements.txt"

# Initialize conda for non-interactive shells
source "$(conda info --base)/etc/profile.d/conda.sh"

# Create env if missing
if ! conda env list | awk '{print $1}' | grep -q "^${ENV_NAME}$"; then
  conda create -y -n "$ENV_NAME" python=3.8
fi

# Activate it
conda activate "$ENV_NAME"

echo ">>> Python in use:"
python -V
which python

echo ">>> Install GPU PyTorch (CUDA 11.X build for RTX 3060)"
python -m pip install --upgrade pip wheel setuptools
# python -m pip install --index-url https://download.pytorch.org/whl/cu113 \
#   torch==1.12.1+cu113 torchvision==0.13.1+cu113 torchaudio==0.12.1 \
#   --extra-index-url https://pypi.org/simple
python -m pip install --index-url https://download.pytorch.org/whl/cu113 \
  torch==1.10.1+cu113 torchvision==0.11.2+cu113 torchaudio==0.10.1 \
  --extra-index-url https://pypi.org/simple

# uninstall the pytorch included numpy packages (it downloads the latest which we don't want)
# and install the ones we need for detectron2
python -m pip uninstall -y numpy pillow urllib3 certifi charset_normalizer idna requests
python -m pip install numpy==1.23.5 pillow==8.4.0 urllib3==1.26.16 certifi==2022.12.7 idna==3.4 charset_normalizer==2.1.1 requests==2.28.1

echo ">>> Install Detectron and set CUDA toolkit"
#python -m pip install --no-build-isolation \
#  'git+https://github.com/facebookresearch/detectron2.git@2f54e6cc88f3158c5f6b983b6e0fbf061d7f5a2d'
pip install detectron2 -f \
  https://dl.fbaipublicfiles.com/detectron2/wheels/cu113/torch1.10/index.html

echo ">>> Install COCO / panoptic tools"
python -m pip install git+https://github.com/cocodataset/panopticapi.git

echo ">>> Prep build tools + numpy for openDR's legacy setup.py"
#python -m pip install -U pip setuptools wheel cython
pip install cython==0.29.36
pip install "numpy<1.24,>=1.20"
pip install pycocotools==2.0.6 --no-build-isolation
pip install chumpy==0.70 --no-build-isolation
pip install opendr==0.78 --no-build-isolation\

echo ">>> Install the rest of the dependencies from requirements.txt (without touching open3d/opendr)"
python -m pip install --no-deps -r "$REQS"