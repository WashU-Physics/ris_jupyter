#!/bin/bash
#SBATCH --job-name=jupyter
#SBATCH --account=compute2-artsci      # artsci condo account
#SBATCH --partition=condo-artsci       # artsci condo partition
#SBATCH --gres=gpu:1                   # 1 GPU
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=08:00:00
#SBATCH --output=jupyter_%j.log
#SBATCH --error=jupyter_%j.log

module load ris
module load apptainer/1.3.4

# Reuse the shared image, or point this at your own copy.
CONTAINER=/storage1/fs1/cyuran/Active/containers/pytorch_25.08.sif

# Keep runtime caches OFF the 10 GB $HOME (see "Cache directories" below).
# NOTE the $USER subdir: everyone shares this storage allocation, so caches MUST
# be per-user or concurrent sessions will clash on the same files.
export CACHE_BASE=/storage1/fs1/cyuran/Active/cache/$USER
mkdir -p "$CACHE_BASE"
export XDG_CACHE_HOME=$CACHE_BASE                 # pip, matplotlib, misc ~/.cache
export HF_HOME=$CACHE_BASE/huggingface            # HuggingFace models/datasets
export TORCH_HOME=$CACHE_BASE/torch               # torch.hub pretrained weights
export TRITON_CACHE_DIR=$CACHE_BASE/triton        # torch.compile / Triton kernels
export CUDA_CACHE_PATH=$CACHE_BASE/nv             # CUDA JIT cache (~/.nv)
export TORCH_EXTENSIONS_DIR=$CACHE_BASE/torch_ext # torch C++/CUDA extensions
export PYTHONUSERBASE=$CACHE_BASE/pyuser          # pip install --user target

# Pick a FREE TCP port on this node automatically, so concurrent users never
# clash on a hard-coded port like 8888 (see "Port clashes" below).
PORT=$(python3 -c 'import socket; s=socket.socket(); s.bind(("",0)); print(s.getsockname()[1]); s.close()')
NODE=$(hostname -s)

cat <<EOF

==================================================================
 Jupyter is starting on ${NODE}, port ${PORT}
 From your LAPTOP, open a new terminal and run this tunnel:

     ssh -N -L ${PORT}:${NODE}:${PORT} <your_username>@<LOGIN_HOST>

 (<LOGIN_HOST> = whatever you normally SSH into the cluster with)
 Then watch below for the http://127.0.0.1:${PORT}/lab?token=... URL.
==================================================================

EOF

apptainer exec --nv \
  --bind /storage1/fs1/cyuran/Active \
  "$CONTAINER" \
  jupyter lab --no-browser --ip=0.0.0.0 --port=${PORT}