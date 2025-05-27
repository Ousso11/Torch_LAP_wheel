### 🔧 Ultra-minimal CUDA Wheel Builder with PyTorch Only
FROM --platform=linux/amd64 nvidia/cuda:12.1.1-runtime-ubuntu20.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV CUDA_HOME=/usr/local/cuda

# Install Python, pip, build tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.11 python3.11-venv python3.11-dev python3-pip \
    git build-essential cmake ca-certificates curl && \
    rm -rf /var/lib/apt/lists/*

# Set Python 3.11 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 && \
    update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

# Install torch with CUDA 12.1 and build deps
RUN pip install --no-cache-dir \
    torch==2.2.0 --index-url https://download.pytorch.org/whl/cu121 && \
    pip install --no-cache-dir setuptools wheel

# Clone and build the wheel
WORKDIR /app
RUN git clone https://github.com/ivan-chai/torch-linear-assignment.git .
RUN pip install . && python setup.py bdist_wheel

# Export built wheel
FROM scratch AS export-stage
COPY --from=builder /app/dist .
