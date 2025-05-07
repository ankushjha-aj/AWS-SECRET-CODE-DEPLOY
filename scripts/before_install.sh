#!/bin/bash
# Create destination directory if it doesn't exist
if [ ! -d /var/www/html ]; then
  mkdir -p /var/www/html
fi

# Set proper permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html 