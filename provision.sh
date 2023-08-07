#!/bin/bash

# Print title card
print_title_card() {
    echo "-------------------------"
    echo "Ubuntu Headless Provisioner"
    echo "Version: 1.0"
    echo "Copyright (C) 2023 by Patrick DeLuca"
    echo "Description: Installs miniconda, nvm, build-essential, gcc, VSCode server, and Docker on Ubuntu 22.04"
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

    echo "Installation complete."
}

main
