#!/usr/bin/env bash
set -euo pipefail

ENV_NAME="harmoni_py311"
REQS="$HOME/repos/HARMONI_V2/requirements.txt"

# Initialize conda for non-interactive shells
source "$(conda info --base)/etc/profile.d/conda.sh"

# Create env if missing
if ! conda env list | awk '{print $1}' | grep -q "^${ENV_NAME}$"; then
  conda create -y -n "$ENV_NAME" python=3.11
fi

# Activate it
conda activate "$ENV_NAME"

echo ">>> Python in use:"
python -V
which python

echo ">>> Install GPU PyTorch (CUDA 12.8 build for RTX 5060)"
python -m pip install --upgrade pip wheel setuptools
python -m pip install --index-url https://download.pytorch.org/whl/cu128 \
  torch==2.9.0 torchvision==0.24.0 torchaudio

echo ">>> Install Open3D from conda-forge (prebuilt binaries)"
conda install -y -c conda-forge open3d=0.19.0

echo ">>> Prep build tools + numpy for openDR's legacy setup.py"
python -m pip install -U pip setuptools wheel cython
python -m pip install "numpy==2.3.4"

echo ">>> Install OpenDR from PyPI without build isolation (so it sees the NumPy)"
python -m pip install --no-build-isolation opendr==0.78

echo ">>> Sanity check locations"
which python
python -V
python - <<'PY'
import sys, site
print("sys.executable:", sys.executable)
print("site-packages:", [p for p in site.getsitepackages() if "envs" in p])
PY

echo ">>> Install the rest of your pinned deps (without touching open3d/opendr)"
# --no-deps so pip won’t try to override conda-forge Open3D/OPENDR
python -m pip install -r "$REQS"

echo ">>> Final versions:"
python - <<'PY'
import sys, torch, numpy, scipy
print("Python:", sys.version.split()[0])
print("Torch:", torch.__version__, "CUDA:", torch.version.cuda, "is_available:", torch.cuda.is_available())
import importlib
for pkg in ["open3d", "opendr", "pandas", "matplotlib"]:
    try:
        m = importlib.import_module(pkg)
        print(f"{pkg}:", getattr(m, "__version__", "OK"))
    except Exception as e:
        print(f"{pkg}: import failed -> {e}")
PY

