#!/bin/bash

# Update package lists
sudo apt-get update

# Install prerequisites
sudo apt-get install -y \
    unzip \
    curl

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf aws awscliv2.zip

# Create application directory with proper permissions
sudo mkdir -p /home/ubuntu/myapp
sudo chown ubuntu:ubuntu /home/ubuntu/myapp

# Display installed versions
echo "AWS CLI Version:"
aws --version

echo "Setup complete!" 