d#!/bin/bash
set -e

VPS_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$VPS_DIR"

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

ok() { echo -e "${GREEN}[OK]${NC} $1"; }
fail() { echo -e "${RED}[FAIL]${NC} $1"; exit 1; }
step() { echo -e "\n${CYAN}==> $1${NC}"; }

if [ "$(id -u)" -ne 0 ]; then
    fail "Run as root: sudo bash setup.sh"
fi

step "1/8 — System packages"
apt-get update
apt-get install -y curl wget gnupg2 ca-certificates lsb-release socat jq docker.io
ok "System packages installed"

step "2/8 — Docker"
if ! command -v docker &>/dev/null; then
    curl -fsSL https://get.docker.com | sh
    ok "Docker installed"
else
    ok "Docker already installed"
fi
systemctl enable docker 2>/dev/null || true
systemctl start docker 2>/dev/null || true
ok "Docker running"

step "3/8 — Python3"
if ! command -v python3 &>/dev/null; then
    apt-get install -y python3 
    apt install python3-pip -y
    ok "Python3 installed"
else
    ok "Python3 already installed"
fi

step "4/8 — Python packages"
pip3 install -r requirements.txt
ok "Python packages installed"

step "5/8 — Node agent packages"
pip3 install -r node_requirements.txt
ok "Node agent packages installed"

step "6/8 — Docker images"
echo "Building Ubuntu 22.04..."
docker build -f Dockerfile.ubuntu -t vps-ubuntu:latest .
ok "Ubuntu 22.04 built"

echo "Building Ubuntu 26.04..."
docker build -f Dockerfile.ubuntu26 -t vps-ubuntu26:latest .
ok "Ubuntu 26.04 built"

echo "Building Debian 12..."
docker build -f Dockerfile.debian -t vps-debian:latest .
ok "Debian 12 built"

echo "Building Debian 13..."
docker build -f Dockerfile.debian13 -t vps-debian13:latest .
ok "Debian 13 built"

step "7/8 — Setup directories & database"
mkdir -p static/uploads
python3 -c "import app; app.init_db(); print('Database initialized')"
ok "Database ready"

step "8/8 — Verify"
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}   VPS Manager — Setup Complete${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo "  Admin login:"
echo "    Username: admin"
echo "    Password: admin123"
echo ""
echo "  Panel: http://localhost:5000"
echo ""
echo "  Start: cd $VPS_DIR && python3 app.py"
echo ""
echo "  Docker images:"
docker images --format '    {{.Repository}}:{{.Tag}}  {{.Size}}' | grep vps-
echo -e "${GREEN}============================================${NC}"
