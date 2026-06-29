#!/bin/bash
set -e

echo "=== VPS Manager — Node Agent Setup ==="
echo ""

if [ "$(id -u)" -ne 0 ]; then
    echo "Run as root: sudo bash setup_node.sh"
    exit 1
fi

if ! command -v docker &>/dev/null; then
    echo "[1/4] Installing Docker..."
    curl -fsSL https://get.docker.com | sh
    apt install docker.io -y
    systemctl enable docker
    systemctl start docker
else
    echo "[1/4] Docker already installed"
fi

if ! command -v python3 &>/dev/null; then
    echo "[2/4] Installing Python3..."
    apt-get update && apt-get install -y python3 python3-pip
else
    echo "[2/4] Python3 already installed"
fi

echo "[3/4] Installing Python packages..."
pip3 install flask docker psutil

echo "[4/4] Installing socat..."
apt-get install -y socat

echo ""
echo "Building Docker images..."
echo "  Ubuntu 22.04..."
docker build -f Dockerfile.ubuntu -t vps-ubuntu:latest .
echo "  Ubuntu 26.04..."
docker build -f Dockerfile.ubuntu26 -t vps-ubuntu26:latest .
echo "  Debian 12..."
docker build -f Dockerfile.debian -t vps-debian:latest .
echo "  Debian 13..."
docker build -f Dockerfile.debian13 -t vps-debian13:latest .

echo ""
echo "============================================"
echo "  Node Agent Setup Complete"
echo "============================================"
echo ""
echo "  Start: python3 node_agent.py"
echo "  Or:    NODE_API_KEY=your_key NODE_PORT=5001 python3 node_agent.py"
echo ""
