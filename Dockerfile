### 🔧 CUDA Wheel Builder for torch-linear-assignment (with verification)

FROM --platform=linux/amd64 nvidia/cuda:12.1.1-devel-ubuntu20.04 AS builder

# ---- Environment Variables ----
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH=/opt/conda/bin:$PATH
ENV CUDA_HOME=/usr/local/cuda
ENV TLA_BUILD_CUDA=1       
ENV CC=gcc                

# ---- Install System Tools ----
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git build-essential cmake ca-certificates ninja-build && \
    rm -rf /var/lib/apt/lists/*

# ---- Install Miniconda (Python 3.11) ----
RUN curl -L -o miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-py311_23.11.0-1-Linux-x86_64.sh && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh && \
    /opt/conda/bin/conda clean -afy

# ---- Create Conda Environment and Install Dependencies ----
RUN conda create -y -n torch-env python=3.11 && \
    echo "conda activate torch-env" >> ~/.bashrc

RUN /opt/conda/bin/conda run -n torch-env pip install --no-cache-dir \
    torch==2.2.0 --index-url https://download.pytorch.org/whl/cu121 && \
    /opt/conda/bin/conda run -n torch-env pip install --no-cache-dir \
    setuptools wheel ninja

# ---- Copy Local Project Files ----
WORKDIR /app
COPY . .

# ---- Build the Wheel (triggers CUDA extension compilation) ----
RUN /opt/conda/bin/conda run -n torch-env python setup.py bdist_wheel


# ---- Export Only the Built Wheel ----
FROM scratch AS export-stage
COPY --from=builder /app/dist .
