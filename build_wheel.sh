#!/bin/bash
set -e

# === Configuration ===
TAG="ousso11/tla-builder:latest"
OUTPUT_DIR="$(pwd)/wheel"
DOCKERFILE_PATH="."

# === Preparation ===
mkdir -p "$OUTPUT_DIR"
echo "🧠 Host architecture: $(uname -m)"

# Optional: Apple Silicon (Rosetta for Intel builds)
if [[ "$(uname -m)" == "arm64" ]]; then
    echo "🛠 Installing Rosetta if needed..."
    /usr/sbin/softwareupdate --install-rosetta --agree-to-license || true
fi

# === Docker Buildx Setup ===
echo "🔧 Setting up Docker Buildx..."
if ! docker buildx ls | grep -q "buildx-torch"; then
    docker buildx create --name buildx-torch --use
else
    docker buildx use buildx-torch
fi
docker buildx inspect --bootstrap > /dev/null

# === Build Docker image and extract wheel ===
echo "🚀 Building Docker image and exporting .whl to: $OUTPUT_DIR"
docker buildx build \
    --platform linux/amd64 \
    --tag "$TAG" \
    --output "type=local,dest=$OUTPUT_DIR" \
    "$DOCKERFILE_PATH"

echo "✅ Build complete! Wheel saved to: $OUTPUT_DIR"
echo "Docker image tagged as: $TAG"

# === Optional: Run container interactively ===
read -p "🧪 Do you want to run the Docker image interactively? (y/N): " RUN_INTERACTIVE

if [[ "$RUN_INTERACTIVE" =~ ^[Yy]$ ]]; then
    echo "🔄 Running Docker image interactively..."
    docker run --rm -it "$TAG" /bin/bash
else
    echo "ℹ️ Skipping interactive run."
fi
