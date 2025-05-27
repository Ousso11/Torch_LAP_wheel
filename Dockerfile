### 🔧 Final Lightweight CUDA Wheel Builder with PyTorch (Python 3.11)

FROM --platform=linux/amd64 nvidia/cuda:12.1.1-runtime-ubuntu20.04 AS builder

# Environment
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH=/opt/conda/bin:$PATH
ENV CUDA_HOME=/usr/local/cuda

# Install system tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git build-essential cmake ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Install Miniconda with Python 3.11
RUN curl -L -o miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-py311_23.11.0-1-Linux-x86_64.sh && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh && \
    /opt/conda/bin/conda clean -afy

# Create minimal Python 3.11 environment
RUN conda create -y -n torch-env python=3.11 && \
    echo "conda activate torch-env" >> ~/.bashrc

# Install PyTorch with CUDA 12.1 + build tools
RUN /opt/conda/bin/conda run -n torch-env pip install --no-cache-dir \
    torch==2.2.0 --index-url https://download.pytorch.org/whl/cu121 && \
    /opt/conda/bin/conda run -n torch-env pip install --no-cache-dir \
    setuptools wheel

# Clone and build wheel
WORKDIR /app
RUN git clone https://github.com/ivan-chai/torch-linear-assignment.git .
RUN /opt/conda/bin/conda run -n torch-env pip install . && \
    /opt/conda/bin/conda run -n torch-env python setup.py bdist_wheel

# Export only the wheel artifact
FROM scratch AS export-stage
COPY --from=builder /app/dist .
