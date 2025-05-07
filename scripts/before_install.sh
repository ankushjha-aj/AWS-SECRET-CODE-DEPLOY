#!/bin/bash
# Create application directory if it doesn't exist
if [ ! -d /home/ubuntu/myapp ]; then
  mkdir -p /home/ubuntu/myapp
fi

# Set proper ownership and permissions
chown -R ubuntu:ubuntu /home/ubuntu/myapp
chmod -R 755 /home/ubuntu/myapp 