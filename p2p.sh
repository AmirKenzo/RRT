#!/bin/bash

# Function to configure the server in Iran
configure_iran_server() {
    echo "Installing iproute2..."
    sudo apt-get update
    sudo apt-get install -y iproute2

    echo "Creating /etc/netplan/pdtun.yaml..."
    sudo bash -c 'cat > /etc/netplan/pdtun.yaml << EOF
network:
  version: 2
  tunnels:
    tunel01:
      mode: sit
      local: '$iran_ipv4'
      remote: '$outside_ipv4'
      addresses:
        - '$iran_ipv6'/64
      mtu: 1500
EOF'

    echo "Setting file permissions and applying netplan configuration..."
    cd /etc/netplan
    sudo chmod 600 *.yaml
    sudo netplan apply

    echo "Creating /etc/systemd/network/tun0.network..."
    sudo bash -c 'cat > /etc/systemd/network/tun0.network << EOF
[Network]
Address='$iran_ipv6'/64
Gateway='$outside_ipv6'
EOF'

    echo "Configuration is done."
}

# Function to configure the server outside Iran
configure_outside_server() {
    echo "Installing iproute2..."
    sudo apt-get update
    sudo apt-get install -y iproute2

    echo "Creating /etc/netplan/pdtun.yaml..."
    sudo bash -c 'cat > /etc/netplan/pdtun.yaml << EOF
network:
  version: 2
  tunnels:
    tunel01:
      mode: sit
      local: '$outside_ipv4'
      remote: '$iran_ipv4'
      addresses:
        - '$outside_ipv6'/64
      mtu: 1500
EOF'

    echo "Setting file permissions and applying netplan configuration..."
    cd /etc/netplan
    sudo chmod 600 *.yaml
    sudo netplan apply

    echo "Creating /etc/systemd/network/tun0.network..."
    sudo bash -c 'cat > /etc/systemd/network/tun0.network << EOF
[Network]
Address='$outside_ipv6'/64
Gateway='$iran_ipv6'
EOF'

    echo "Configuration is done."
}

# Prompt the user for the server location
echo "Select server location:"
echo "1) Iran"
echo "2) Outside Iran"
read -p "Enter your choice (1 or 2): " choice

if [ "$choice" -eq 1 ]; then
    read -p "Enter the IPv4 address of the Iran server: " iran_ipv4
    read -p "Enter the IPv4 address of the outside server: " outside_ipv4
    read -p "Enter the IPv6 address of the Iran server: " iran_ipv6
    read -p "Enter the IPv6 address of the outside server: " outside_ipv6
    configure_iran_server
elif [ "$choice" -eq 2 ]; then
    read -p "Enter the IPv4 address of the Iran server: " iran_ipv4
    read -p "Enter the IPv4 address of the outside server: " outside_ipv4
    read -p "Enter the IPv6 address of the Iran server: " iran_ipv6
    read -p "Enter the IPv6 address of the outside server: " outside_ipv6
    configure_outside_server
else
    echo "Invalid choice. Exiting."
    exit 1
fi
