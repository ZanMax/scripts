#!/bin/bash

set -euo pipefail

# --- Shared setup ---
setup() {
    echo "Adding NVIDIA PPA and updating package lists..."
    sudo add-apt-repository -y ppa:graphics-drivers/ppa
    sudo apt update
}

# --- Prompt for reboot ---
prompt_reboot() {
    read -rp "Reboot now? [y/N]: " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        sudo reboot
    else
        echo "Please reboot later to apply changes."
    fi
}

# --- Subcommands ---

cmd_list() {
    setup
    echo ""
    echo "Available NVIDIA drivers:"
    echo "-------------------------"
    ubuntu-drivers devices
}

cmd_install() {
    local version="$1"
    local package="nvidia-driver-${version}"

    setup
    echo "Installing ${package}..."
    sudo apt install -y "$package"
    echo "Installing nvidia-cuda-toolkit..."
    sudo apt install -y nvidia-cuda-toolkit
    echo "Done."
    prompt_reboot
}

cmd_auto() {
    setup
    local recommended
    recommended=$(ubuntu-drivers devices | grep "recommended" | awk '{print $3}')
    if [[ -z "$recommended" ]]; then
        echo "No recommended driver found. Exiting."
        exit 1
    fi
    echo "Recommended driver: ${recommended}"
    echo "Installing ${recommended}..."
    sudo apt install -y "$recommended"
    echo "Installing nvidia-cuda-toolkit..."
    sudo apt install -y nvidia-cuda-toolkit
    echo "Done."
    prompt_reboot
}

cmd_remove() {
    echo "Removing all NVIDIA driver packages..."
    sudo apt purge -y 'nvidia-*'
    echo "Removing nvidia-cuda-toolkit..."
    sudo apt purge -y nvidia-cuda-toolkit
    echo "Cleaning up leftover dependencies..."
    sudo apt autoremove -y
    echo "Done."
    prompt_reboot
}

cmd_help() {
    cat <<EOF
Usage: $(basename "$0") <command> [options]

Commands:
  list              List available NVIDIA drivers
  install <version> Install a specific driver (e.g. install 550)
  auto              Detect and install the recommended driver + CUDA toolkit
  remove            Purge all NVIDIA drivers and CUDA toolkit
  help              Show this help message
EOF
}

# --- Main dispatch ---
case "${1:-}" in
    list)
        cmd_list
        ;;
    install)
        if [[ -z "${2:-}" ]]; then
            echo "Error: install requires a version number (e.g. ./nv_install.sh install 550)"
            exit 1
        fi
        cmd_install "$2"
        ;;
    auto)
        cmd_auto
        ;;
    remove)
        cmd_remove
        ;;
    help|"")
        cmd_help
        ;;
    *)
        echo "Unknown command: $1"
        echo ""
        cmd_help
        exit 1
        ;;
esac
