#!/bin/bash
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

step "1/9 — System packages"
apt-get update
apt-get install -y curl wget gnupg2 ca-certificates lsb-release socat jq docker.io software-properties-common
ok "System packages installed"

step "2/9 — Docker"
if ! command -v docker &>/dev/null; then
curl -fsSL https://get.docker.com | sh
ok "Docker installed"
else
ok "Docker already installed"
fi
systemctl enable docker 2>/dev/null || true
systemctl start docker 2>/dev/null || true
ok "Docker running"

step "3/9 — Python 3.10"

NEED_INSTALL=false

# Check python3.10

if ! command -v python3.10 &>/dev/null; then
NEED_INSTALL=true
fi

# Check venv module

if ! python3.10 -m venv --help &>/dev/null; then
NEED_INSTALL=true
fi

# Check distutils (required for some builds)

if ! python3.10 -c "import distutils" &>/dev/null; then
NEED_INSTALL=true
fi

if [ "$NEED_INSTALL" = true ]; then
step "Installing Python 3.10 + required modules"
add-apt-repository ppa:deadsnakes/ppa -y
apt-get update
apt-get install -y python3.10 python3.10-venv python3.10-distutils
ok "Python 3.10 + venv + distutils installed"
else
ok "Python 3.10 + venv + distutils already installed"
fi

step "4/9 — Install pip for Python 3.10"
curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10
ok "pip installed for Python 3.10"

step "5/9 — Setup virtual environment"
python3.10 -m venv venv
source venv/bin/activate
ok "Virtual environment created & activated"

step "6/9 — Python packages (venv)"
pip install --upgrade pip
pip install -r requirements.txt
ok "Main Python packages installed"

step "7/9 — Node agent packages (venv)"
pip install -r node_requirements.txt
ok "Node agent packages installed"

step "8/9 — Docker images"
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

step "9/9 — Setup directories & database"
mkdir -p static/uploads
python -c "import app; app.init_db(); print('Database initialized')"
ok "Database ready"

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
echo "  Start:"
echo "    source venv/bin/activate"
echo "    python app.py"
echo ""
echo "  Docker images:"
docker images --format '    {{.Repository}}:{{.Tag}}  {{.Size}}' | grep vps-
echo -e "${GREEN}============================================${NC}"
