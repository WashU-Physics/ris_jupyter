# Connecting to a Jupyter Session on RIS

## Recommended: batch job + VS Code "Existing Jupyter Server"

### 0. Login to the RIS

``` bash
ssh <your_username>@c2-login-001.ris.wustl.edu
```

The password is your WashU key password.

### 1. Clone this repo on RIS

```bash
git clone https://github.com/WashU-Physics/ris_jupyter.git
cd ris_jupyter
```

### 2. Submit a batch job and wait for it to run

```bash
sbatch jupyter.sbatch
squeue -u $USER          # wait until ST shows R (running)
```

To make use of our REU reservation, you can use the following command to submit the job:

```bash
sbatch --reservation=physics_reu_2026 jupyter.sbatch
squeue -u $USER
```

### 3. Read the connection details from the log

```bash
cat jupyter_<jobid>.log
```

The `<jobid>` is what you found from the `squeue` command earlier. This prints (a) the exact `ssh -N -L ...` tunnel command with the real node and
port already filled in, and (b) a Jupyter URL like
`http://127.0.0.1:38421/lab?token=abc123...`. Copy that token URL. The port may very well be different from 38421. You need to note it for the next step.

### 4. Open the tunnel (on your laptop)

In a terminal **on your laptop**, paste the tunnel line from the log, e.g.:

```bash
ssh -N -L 38421:c2-gpu-021:38421 <your_username>@<LOGIN_HOST>
```

`<LOGIN_HOST>` is whatever host you already use to SSH into Compute2, such as `c2-login-001.ris.wustl.edu`. Replace 38421 with the port you noted above. Leave this
terminal open — it *is* the tunnel. The login node forwards the port to the GPU
node over the internal network, so the compute node needs no sshd of its own.

### 5. Attach VS Code (on your laptop)

1. Open or create a `.ipynb` file in VS Code.
2. Kernel picker (top-right) → **Select Another Kernel…** → **Existing Jupyter Server…**
3. Paste the full URL **including the token**:
   `http://127.0.0.1:38421/lab?token=...`
   (or paste just `http://127.0.0.1:38421` and enter the token when prompted). Remember to replace 38421 with the correct port you noted above.
4. Choose the **Python 3** kernel.

The kernel now runs **inside the PyTorch container on the GPU node**. Verify in a cell:

```python
import torch
print(torch.__version__, torch.version.cuda, torch.cuda.get_device_name(0))
# expect a CUDA 13.0 build and a GPU name (e.g. an H100)
```

### 6. When you're done

- Stop the tunnel: `Ctrl-C` in the laptop terminal.
- Free the GPU: `scancel <jobid>` on the login node.

