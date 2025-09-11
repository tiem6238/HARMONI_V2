# This install works for Ubuntu 24.04.3 LTS using an RTX 5060 graphics card
set -euo pipefail

sudo apt update
sudo apt install -y build-essential cmake ffmpeg libgl1 libglib2.0-0 libsm6 libxext6 libxrender1

source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate harmoni_visual

python -m pip install -U pip setuptools wheel

pip install PyOpenGL==3.1.7 PyOpenGL_accelerate==3.1.7
pip install --no-deps pyrender==0.1.45

# Pytorch pinned to CUDA 11.3 build (matches detectron2 wheel we'll install)
pip install torch==1.10.1+cu113 torchvision==0.11.2+cu113 torchaudio==0.10.1+cu113 \
  -f https://download.pytorch.org/whl/torch_stable.html

python - <<'PY'
import torch; print("Torch:", torch.__version__, "CUDA build:", torch.version.cuda, "GPU avail:", torch.cuda.is_available())
PY

# Detectron2 that matches torch 1.12 + cu113 (Linux ONLY)
pip install detectron2==0.6 -f https://dl.fbaipublicfiles.com/detectron2/wheels/cu113/torch1.10/index.html

pip install git+https://github.com/nghorbani/configer

pip install \
  matplotlib==3.7.1 \
  opencv-python==4.7.0.72 \
  scikit-image==0.20.0

pip install loguru==0.7.2 termcolor==2.3.0 Pillow==9.5.0 joblib==1.2.0 tqdm==4.66.1 configargparse==1.5.3
pip install smplx==0.1.28 trimesh==3.9.13 pyrender==0.1.45
pip install pytube==12.1.0
pip install chumpy==0.70
pip install "numpy<1.24,>=1.21" --force-reinstall

# COCO / panoptic tools
pip install git+https://github.com/cocodataset/panopticapi.git

# Open3D can be touchy; 0.17.0 is a safe pick for py3.9
pip install open3d==0.17.0 einops==0.6.1 timm==0.9.2

# PHALP-related deps
pip install gdown cython==0.29.36
# NOTE: scikit-learn==0.22 (from your script) is too old for Python 3.9.
# Use a compatible version:
pip install scikit-learn==1.1.3 scipy==1.9.0

pip install rich==13.4.2 dill==0.3.6 colordict==1.2.6 scenedetect[opencv]==0.6.2
pip install hydra-core==1.3.2 hydra-colorlog==1.2.0
pip install pyransac3d==0.6.0

# Downstream
pip install scikit-spatial==7.0.0

# Optional legacy alias sometimes imported by older code paths:
pip install kornia==0.6.12 torchgeometry==0.1.2 || true

# Verify Detectron2 environment coherence
python - <<'PY'
from detectron2.utils.collect_env import collect_env_info
print(collect_env_info())
PY

echo "*** HARMONI successfully initialized! ***"
