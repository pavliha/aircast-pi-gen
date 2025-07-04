#!/bin/bash -e

# Install aircast-agent
on_chroot << EOF
# Add aircast-agent repository
curl -s https://aircast-apt.s3.us-east-1.amazonaws.com/public-key.gpg | gpg --dearmor -o /usr/share/keyrings/aircast.gpg
echo "deb [signed-by=/usr/share/keyrings/aircast.gpg] https://aircast-apt.s3.us-east-1.amazonaws.com development main" > /etc/apt/sources.list.d/aircast-agent.list

# Update and install
apt-get update
apt-get install -y aircast-agent
EOF
