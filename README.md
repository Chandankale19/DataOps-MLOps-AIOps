# Install Terraform Latest Version Script

This repository provides a robust and automated Bash script to download, install, and verify the latest version of [Terraform](https://www.terraform.io/), an infrastructure-as-code (IaC) tool by HashiCorp.

## Features

- **Cross-platform support**: Works on Debian, RHEL, and Fedora-based distributions.
- **Automatic dependency management**: Installs required dependencies (`wget`, `unzip`, `curl`) based on your system's package manager.
- **Version detection**: Fetches the latest Terraform release from GitHub.
- **Error handling**: Includes detailed error checks and messages.
- **Reinstallation prompt**: Detects existing installations and prompts the user for reinstallation.

---

## Prerequisites

- **Root privileges**: The script must be run as `root` or with `sudo` permissions.
- **Internet connection**: Required to fetch the latest Terraform version and dependencies.

---

## How to Use

1. **Clone the Repository**

   ```bash
   git clone https://github.com/Chandankale19/DataOps-MLOps-AIOps.git
   cd DataOps-MLOps-AIOps

2. **Run the Script**

   ```bash
   sudo ./install_terraform_latest_version.sh

