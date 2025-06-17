#!/bin/bash

echo ">>> Configuring systemd-journald to store logs in RAM only..."

# Modify journald.conf
sudo sed -i '/^\[Journal\]/,/^\[/ s/^#\?Storage=.*/Storage=volatile/' /etc/systemd/journald.conf
sudo sed -i '/^\[Journal\]/,/^\[/ s/^#\?RuntimeMaxUse=.*/RuntimeMaxUse=30M/' /etc/systemd/journald.conf
sudo sed -i '/^\[Journal\]/,/^\[/ s/^#\?SystemMaxUse=.*/SystemMaxUse=30M/' /etc/systemd/journald.conf

# Restart journald and cleanup logs
echo ">>> Restarting journald and cleaning logs..."
sudo systemctl restart systemd-journald
sudo journalctl --rotate
sudo journalctl --vacuum-time=1s

# Ensure /var/log/journal is removed and locked
echo ">>> Making /var/log/journal immutable..."
if [ -d /var/log/journal ]; then
    sudo chattr -i /var/log/journal 2>/dev/null
    sudo rm -rf /var/log/journal
fi
sudo mkdir -p /var/log/journal
sudo chattr +i /var/log/journal

# Mount /tmp as tmpfs
echo ">>> Configuring /tmp to use tmpfs (RAM)..."
if ! grep -q "^tmpfs /tmp" /etc/fstab; then
    echo 'tmpfs /tmp tmpfs defaults,noatime,nosuid,nodev,mode=1777,size=512M 0 0' | sudo tee -a /etc/fstab
fi

# Mount /var/log as tmpfs
echo ">>> Configuring /var/log to use tmpfs (RAM)..."
if ! grep -q "^tmpfs /var/log" /etc/fstab; then
    echo 'tmpfs /var/log tmpfs defaults,noatime,nosuid,nodev,mode=0755,size=100M 0 0' | sudo tee -a /etc/fstab
fi

# Create necessary /var/log dirs (will be recreated on boot, or can use systemd-tmpfiles)
sudo mkdir -p /var/log/journal
sudo mkdir -p /var/log/nginx
sudo mkdir -p /var/log/apache2
sudo mkdir -p /var/log/mysql
sudo chmod 755 /var/log

# Add noatime to root filesystem
echo ">>> Adding 'noatime' to root filesystem in /etc/fstab..."
sudo sed -i 's|\( / *ext[4]* *\)\(defaults\)|\1\2,noatime|' /etc/fstab

# Disable swap
echo ">>> Disabling swap..."
sudo swapoff -a
sudo sed -i '/swap/d' /etc/fstab

# Disable rsyslog if installed
echo ">>> Disabling rsyslog if present..."
if systemctl is-enabled rsyslog &>/dev/null; then
    sudo systemctl disable --now rsyslog
    echo ">>> rsyslog disabled."
else
    echo ">>> rsyslog not found or already disabled."
fi

# Remount affected mounts
echo ">>> Remounting filesystems..."
sudo mount -o remount /
sudo mount /tmp || true
sudo mount /var/log || true

echo "✅ SSD optimization complete. Reboot is recommended."
