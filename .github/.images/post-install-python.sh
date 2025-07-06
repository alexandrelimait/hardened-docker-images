#!/bin/sh
set -e

# Post-install script for hardened Python Alpine image
# This script removes the package manager and sets final permissions

echo "Starting post-install hardening for Python..."

# Remove package manager to reduce attack surface
if [ -f /sbin/apk ]; then
echo "Removing apk package manager..."
rm -f /sbin/apk
fi

# Remove any remaining package manager files
rm -rf /lib/apk /var/lib/apk /etc/apk /usr/share/apk

# Remove package manager cache if it still exists
rm -rf /var/cache/apk/*

# Python-specific: Clean up pip cache and temporary files
echo "Cleaning up pip cache and temporary files..."
rm -rf /root/.cache/pip
rm -rf /tmp/pip-*
rm -rf /tmp/build

# Set final permissions on /app directory
if [ -d /app ]; then
echo "Setting final permissions on /app..."
chown -R app:app /app
find /app -type d -exec chmod 750 {} \;
find /app -type f -exec chmod 640 {} \;
fi

# Remove any temporary files
rm -rf /tmp/* /var/tmp/*

# Python-specific: Remove any Python bytecode files that might have been created
find / -name "*.pyc" -delete 2>/dev/null || true
find / -name "*.pyo" -delete 2>/dev/null || true
find / -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true

# Remove this script itself to reduce attack surface
rm -f /usr/local/bin/post-install-python.sh

echo "Post-install hardening for Python completed."
