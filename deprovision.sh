#!/bin/bash

# Print title card
print_title_card() {
    echo "-------------------------"
    echo "Ubuntu Headless Deprovisioner"
    echo "Version: 1.0"
    echo "Copyright (C) 2023 by Patrick DeLuca"
    echo "Description: Uninstalls miniconda, nvm, build-essential, gcc, VSCode server, and Docker on Ubuntu 22.04"
    echo "Usage Example: ./deprovision.sh"
    echo "-------------------------"
}

main() {
    # Print title card
    print_title_card

    # Uninstall miniconda
    echo "Uninstalling miniconda..."
    rm -rf $HOME/miniconda
    sed -i '/miniconda/d' $HOME/.bashrc

    # Uninstall nvm
    echo "Uninstalling nvm..."
    rm -rf $HOME/.nvm
    sed -i '/NVM_DIR/d' $HOME/.bashrc

    # Uninstall build-essential and gcc
    echo "Uninstalling build-essential and gcc..."
    sudo apt-get remove --purge -y build-essential gcc

    # Uninstall VSCode server
    echo "Uninstalling VSCode server..."
    rm -rf $HOME/.local/lib/code-server

    # Uninstall Docker
    echo "Uninstalling Docker..."
    sudo apt-get remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo rm -f /etc/apt/keyrings/docker.gpg
    sudo rm -f /etc/apt/sources.list.d/docker.list

    echo "Uninstallation complete!"
}

main
