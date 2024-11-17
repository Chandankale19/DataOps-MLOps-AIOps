#!/bin/bash

# Author : Chandan Kale (Data & ML Platform Engineer)

# Variables
INSTALL_DIR="/usr/local/bin"  # Directory to install Terraform
TEMP_ZIP="/tmp/terraform.zip" # Temporary zip file for downloading Terraform

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Please use sudo."
   exit 1
fi

# Function to install dependencies based on distribution
install_dependencies() {
    echo "Checking for dependencies..."

    if command -v apt-get &>/dev/null; then
        echo "Detected Debian-based distribution."
        apt-get update -y &>/dev/null && apt-get install -y wget unzip curl &>/dev/null || { echo "Failed to install dependencies."; exit 1; }
    elif command -v yum &>/dev/null; then
        echo "Detected RHEL-based distribution."
        yum install -y wget unzip curl &>/dev/null || { echo "Failed to install dependencies."; exit 1; }
    elif command -v dnf &>/dev/null; then
        echo "Detected Fedora distribution."
        dnf install -y wget unzip curl &>/dev/null || { echo "Failed to install dependencies."; exit 1; }
    else
        echo "Unsupported distribution. Exiting."
        exit 1
    fi
}

# Function to get the latest version of Terraform
get_latest_version() {
    local latest_version
    latest_version=$(curl -s https://api.github.com/repos/hashicorp/terraform/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')

    if [[ -z "$latest_version" ]]; then
        echo "Failed to retrieve the latest version of Terraform. Exiting."
        exit 1
    fi

    # Remove the "v" prefix if present
    echo "$latest_version" | sed 's/^v//'
}

# Function to download and install Terraform
install_terraform() {
    local version="$1"
    echo "Downloading Terraform version $version..."

    local ARCHITECTURE=$(uname -m)
    local TARBALL_URL="https://releases.hashicorp.com/terraform/${version}/terraform_${version}_linux_$(echo $ARCHITECTURE | sed 's/x86_64/amd64/' | sed 's/aarch64/arm64/').zip"

    if wget -q "$TARBALL_URL" -O "$TEMP_ZIP"; then
        echo "Terraform downloaded successfully."
    else
        echo "Failed to download Terraform. Exiting."
        exit 1
    fi

    echo "Unzipping Terraform..."
    if unzip -o "$TEMP_ZIP" -d /tmp &>/dev/null; then
        echo "Terraform unzipped successfully."
    else
        echo "Failed to unzip Terraform. Exiting."
        exit 1
    fi

    echo "Moving Terraform to $INSTALL_DIR..."
    if mv /tmp/terraform "$INSTALL_DIR"; then
        echo "Terraform installed successfully."
    else
        echo "Failed to move Terraform to $INSTALL_DIR. Exiting."
        exit 1
    fi

    echo "Cleaning up temporary files..."
    rm -f "$TEMP_ZIP"
}

# Function to verify installation
verify_installation() {
    echo "Verifying Terraform installation..."
    if command -v terraform &>/dev/null; then
        echo "Terraform installation verified successfully. Version: $(terraform version)"
    else
        echo "Terraform installation verification failed."
        exit 1
    fi
}

# Function to check if Terraform is already installed
check_existing_installation() {
    if command -v terraform &>/dev/null; then
        echo "Terraform is already installed. Version: $(terraform version)"
        read -rp "Do you want to reinstall Terraform? (y/N): " choice
        case "$choice" in
            [yY]) 
                echo "Proceeding with reinstallation."
                ;;
            [nN]|"")
                echo "Exiting without reinstalling."
                exit 0
                ;;
            *)
                echo "Invalid option. Exiting."
                exit 1
                ;;
        esac
    fi
}

# Main function
main() {
    echo "Starting Terraform installation script."

    # Check for existing installation
    check_existing_installation

    # Call functions with error handling
    install_dependencies || { echo "Dependency installation failed. Exiting."; exit 1; }
    
    # Get the latest version and install it
    local latest_version
    latest_version=$(get_latest_version) || { echo "Failed to get latest version. Exiting."; exit 1; }
    install_terraform "$latest_version" || { echo "Terraform installation failed. Exiting."; exit 1; }

    verify_installation || { echo "Verification failed. Exiting."; exit 1; }
    
    echo "Terraform installation completed successfully."
}

# Execute main function
main

