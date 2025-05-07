#!/bin/bash
cd /home/ubuntu/myapp

# Install dependencies if package.json exists
if [ -f "package.json" ]; then
  npm install
fi

# Make sure all scripts are executable
find . -type f -name "*.sh" -exec chmod +x {} \;

echo "Deployment completed successfully!" 