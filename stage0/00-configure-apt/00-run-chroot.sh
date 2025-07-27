#!/bin/bash -e

# Fix DNS resolution in chroot
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf