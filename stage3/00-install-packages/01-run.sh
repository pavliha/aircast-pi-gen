#!/bin/bash -e

# Install Oh My Zsh for the pi user
on_chroot << EOF
# Install Oh My Zsh unattended
su - ${FIRST_USER_NAME} -c 'sh -c "\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'

# Change default shell to zsh
chsh -s /bin/zsh ${FIRST_USER_NAME}
EOF
