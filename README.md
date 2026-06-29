# Omega Panel V2

A full-featured VPS management website built with Flask, Docker, and modern web technologies.

## Features

- **User Authentication**: Register and login system with secure password hashing
- **Admin Panel**: Create and manage VPS instances for users
- **User Dashboard**: View and manage your VPS instances
- **Docker Integration**: Automated VPS creation using Docker containers
- **SSH Access**: sshx-based SSH access to VPS instances
- **Real-time Status**: Auto-refreshing VPS status monitoring

## Default Credentials

- **Admin Username**: admin
- **Admin Password**: admin123

## Setup

### Prerequisites

- Python 3.8+ (Use Python 3.10 If crashes.) 
- Docker installed and running

### Installation

1. Clone the repository Then Run:
```bash
cd Omega-Panel-V2
```

2. Run the setup script:
```bash
./setup.sh
```

3. Start the server:
```bash
python3 app.py
```

4. Visit http://localhost:5000

## Manual Setup

If you prefer manual setup:

1. Install Python dependencies:
```bash
pip3 install -r requirements.txt
```

2. Build Docker images:
```bash
docker build -f Dockerfile.ubuntu -t vps-ubuntu:latest .
docker build -f Dockerfile.ubuntu26 -t vps-ubuntu26:latest .
docker build -f Dockerfile.debian -t vps-debian:latest .
docker build -f Dockerfile.debian13 -t vps-debian13:latest .
```

3. Run the application:
```bash
python app.py
```

## Usage

### For Admins

1. Login with admin credentials
2. Go to Admin Panel
3. Click "Create VPS"
4. Select a user, OS type, and specifications
5. The VPS will be created and assigned to the user

### For Users

1. Register an account
2. Login to your dashboard
3. View your VPS instances
4. Start, stop, restart, or delete your VPS
5. Copy SSHX URL to connect


## API Endpoints

See On Admin > API Docs.
