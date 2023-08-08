#!/bin/bash

# Print title card
print_title_card() {
    echo "-------------------------"
    echo "Ubuntu Headless Provisioner"
    echo "Version: 1.0"
    echo "Copyright (C) 2023 by Patrick DeLuca"
    echo "Description: Installs miniconda, nvm, build-essential, gcc, VSCode server, Docker, nVidia driver, and Cuda on Ubuntu 22.04"
    echo "Usage Example: ./provision.sh"
    echo "-------------------------"
}

main() {
    # Print title card
    print_title_card

    # Update packages
    sudo apt-get update -y

    # Install build-essential and gcc
    sudo apt-get install -y build-essential gcc

    # Download and Install Miniconda
    miniconda_url="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
    miniconda_file="Miniconda3-latest-Linux-x86_64.sh"

    curl -O $miniconda_url
    chmod +x $miniconda_file
    ./Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda
    rm $miniconda_file

    # Add miniconda to PATH
    echo 'export PATH=$HOME/miniconda/bin:$PATH' >> $HOME/.bashrc
    source $HOME/.bashrc

    # Install nvm
    wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.1/install.sh | bash
    source $HOME/.bashrc

    # Install VSCode server
    curl -fsSL https://code-server.dev/install.sh | sh

    # Install Docker
    sudo apt-get install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo $VERSION_CODENAME) stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Add user to docker group and create a new group
    sudo usermod -aG docker $USER
    newgrp docker

    # Ask user if they want to install nVidia driver and Cuda
    read -p "Do you want to install nVidia driver and Cuda? [Y/n] " choice
    case "$choice" in
      y|Y ) echo "Proceeding with nVidia driver and Cuda installation";;
      n|N ) echo "Skipping nVidia driver and Cuda installation"; exit 0;;
      * ) echo "Invalid input. Exiting."; exit 1;;
    esac

    # Blacklist nouveau driver
    echo "blacklist nouveau" | sudo tee -a /etc/modprobe.d/blacklist-nvidia-nouveau.conf
    echo "options nouveau modeset=0" | sudo tee -a /etc/modprobe.d/blacklist-nvidia-nouveau.conf
    sudo update-initramfs -u

    # Download and install nVidia driver
    nvidia_driver_url="https://us.download.nvidia.com/tesla/535.86.10/NVIDIA-Linux-x86_64-535.86.10.run"
    nvidia_driver_file="NVIDIA-Linux-x86_64-535.86.10.run"

    wget $nvidia_driver_url
    chmod +x $nvidia_driver_file
    sudo ./$nvidia_driver_file --dkms

    # Install Cuda
    sudo apt-get install -y nvidia-cuda-toolkit

    echo "Installation complete. The system will now reboot."
    sudo reboot
}

main
