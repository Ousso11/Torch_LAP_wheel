### 🔧 Dockerfile: CUDA-enabled wheel builder (Dockerfile)
# Build Stage: Linux x86_64 with CUDA
FROM --platform=linux/amd64 nvidia/cuda:12.1.1-devel-ubuntu20.04 AS builder

SHELL ["/bin/bash", "-c"]
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH=/opt/conda/bin:$PATH
ENV TLA_BUILD_CUDA=1
ENV CUDA_HOME=/usr/local/cuda

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl git build-essential cmake ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Install Miniforge (Python 3.11)
RUN curl -L -o Miniforge.sh https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh && \
    bash Miniforge.sh -b -p /opt/conda && \
    rm Miniforge.sh && \
    /opt/conda/bin/conda clean -afy

# Set up Conda environment
RUN conda create -y -n torch-env python=3.11 && \
    echo "conda activate torch-env" >> ~/.bashrc

# Install PyTorch and build tools
RUN source /opt/conda/bin/activate torch-env && \
    conda install -y pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia && \
    pip install --upgrade pip setuptools wheel ninja

# Show CUDA info
RUN source /opt/conda/bin/activate torch-env && \
    python -c "import torch; print('✅ CUDA available:', torch.cuda.is_available()); print('🧱 CUDA built:', torch.backends.cuda.is_built())"

# Clone and build
WORKDIR /app
RUN git clone https://github.com/ivan-chai/torch-linear-assignment.git .
RUN source /opt/conda/bin/activate torch-env && \
    pip install . && \
    python setup.py bdist_wheel

# Export Stage
FROM scratch AS export-stage
COPY --from=builder /app/dist .
