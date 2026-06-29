#!/bin/bash

# Update package list (recommended)
apt update -y

# Install git
apt install git -y

# Clone the repository
git clone https://github.com/nafigamer0/Omega-Panel-V2.git

# Go into the directory
cd Omega-Panel-V2 || exit

# Give execute permission (just in case)
chmod +x setup.sh

# Run setup
sudo bash setup.sh
