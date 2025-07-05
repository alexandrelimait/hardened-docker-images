#!/bin/sh
set -e

# Post-install script for hardened Node.js Alpine image
# This script removes the package manager and sets final permissions

echo "Starting post-install hardening..."

# Remove package manager to reduce attack surface
if [ -f /sbin/apk ]; then
echo "Removing apk package manager..."
rm -f /sbin/apk
fi

# Remove any remaining package manager files
rm -rf /lib/apk /var/lib/apk /etc/apk /usr/share/apk

# Remove package manager cache if it still exists
rm -rf /var/cache/apk/*

# Set final permissions on /app directory
if [ -d /app ]; then
echo "Setting final permissions on /app..."
chown -R app:app /app
find /app -type d -exec chmod 750 {} \;
find /app -type f -exec chmod 640 {} \;
fi

# Remove any temporary files
rm -rf /tmp/* /var/tmp/*

# Remove this script itself to reduce attack surface
rm -f /usr/local/bin/post-install.sh

echo "Post-install hardening completed."