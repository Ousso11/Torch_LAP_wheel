### 🔧 Minimal CUDA Wheel Builder with PyTorch Only
FROM --platform=linux/amd64 nvidia/cuda:12.1.1-devel-ubuntu20.04 AS builder

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH=/opt/miniconda/bin:$PATH
ENV CUDA_HOME=/usr/local/cuda

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git build-essential cmake ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Install Miniconda (lightweight)
RUN curl -L -o miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash miniconda.sh -b -p /opt/miniconda && \
    rm miniconda.sh && \
    /opt/miniconda/bin/conda clean -afy

# Create environment with Python 3.11
RUN /opt/miniconda/bin/conda create -y -n torch-env python=3.11 && \
    echo "conda activate torch-env" >> ~/.bashrc

# Install only PyTorch with CUDA 12.1
RUN /opt/miniconda/bin/conda run -n torch-env pip install --no-cache-dir \
    torch==2.2.0 --index-url https://download.pytorch.org/whl/cu121 && \
    /opt/miniconda/bin/conda run -n torch-env pip install --no-cache-dir \
    setuptools wheel

# Clone repo and build
WORKDIR /app
RUN git clone https://github.com/ivan-chai/torch-linear-assignment.git .
RUN /opt/miniconda/bin/conda run -n torch-env pip . && \
    /opt/miniconda/bin/conda run -n torch-env python setup.py bdist_wheel

# Export Stage
FROM scratch AS export-stage
COPY --from=builder /app/dist .
