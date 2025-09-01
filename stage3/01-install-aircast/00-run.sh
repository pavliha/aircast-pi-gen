#!/bin/bash -e

# Determine which repository to use based on the build context
echo "🔍 Build context debug info:"
echo "  GITHUB_WORKFLOW: ${GITHUB_WORKFLOW:-'not set'}"
echo "  GITHUB_REF: ${GITHUB_REF:-'not set'}"
echo "  GITHUB_EVENT_NAME: ${GITHUB_EVENT_NAME:-'not set'}"
echo "  PWD: ${PWD:-'not set'}"

# Check if this is a production build by looking for production-related environment variables or workflow context
if [[ "${GITHUB_WORKFLOW}" == *"Production"* ]] || [[ "${GITHUB_REF}" == *"main"* ]]; then
    REPO_CHANNEL="stable"
    echo "🏭 Production build detected - using stable repository"
else
    REPO_CHANNEL="development" 
    echo "🧪 Development build detected - using development repository"
fi

echo "📦 Selected repository channel: $REPO_CHANNEL"

# Install aircast-agent
on_chroot << EOF
# Add aircast-agent repository
curl -s https://aircast-apt.s3.us-east-1.amazonaws.com/public-key.gpg | gpg --dearmor -o /usr/share/keyrings/aircast.gpg
echo "deb [signed-by=/usr/share/keyrings/aircast.gpg] https://aircast-apt.s3.us-east-1.amazonaws.com $REPO_CHANNEL main" > /etc/apt/sources.list.d/aircast-agent.list

# Update and install
apt-get update
apt-get install -y aircast-agent
EOF
