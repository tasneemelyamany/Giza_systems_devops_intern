#!/bin/bash

# Create pet-clinic user and install Java JDK without package managers
# Rerunnable and idempotent

set -e

USERNAME="pet-clinic"
JAVA_VERSION="17.0.9"
JAVA_BUILD="9"

# Check root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root"
    exit 1
fi

# Create user if doesn't exist
if id "$USERNAME" &>/dev/null; then
    echo "User $USERNAME already exists"
else
    useradd -m -s /bin/bash "$USERNAME"
    echo "Created user $USERNAME"
fi

# Install Java as the user
su - "$USERNAME" << 'EOF'
set -e

JAVA_VERSION="17.0.9"
JAVA_BUILD="9"

# Detect architecture
ARCH=$(uname -m)
case $ARCH in
    x86_64) JAVA_ARCH="x64" ;;
    aarch64|arm64) JAVA_ARCH="aarch64" ;;
    *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

# Setup directories
JAVA_DIR="$HOME/java"
JDK_DIR="$JAVA_DIR/jdk-${JAVA_VERSION}+${JAVA_BUILD}"
DOWNLOAD_DIR="$HOME/tmp"

mkdir -p "$DOWNLOAD_DIR" "$JAVA_DIR"

# Download and extract Java if not already installed
if [ -d "$JDK_DIR" ] && [ -f "$JDK_DIR/bin/java" ]; then
    echo "Java already installed at $JDK_DIR"
else
    echo "Downloading OpenJDK ${JAVA_VERSION}..."

    URL="https://github.com/adoptium/temurin17-binaries/releases/download/jdk-${JA>
    TARBALL="$DOWNLOAD_DIR/openjdk.tar.gz"

    # Remove old incomplete downloads
    rm -f "$TARBALL"
    # Download with proper error checking
    if command -v wget &> /dev/null; then
        wget --tries=3 --timeout=30 -O "$TARBALL" "$URL" || {
            echo "Error: Download failed"
            rm -f "$TARBALL"
            exit 1
        }
    elif command -v curl &> /dev/null; then
        curl --retry 3 --max-time 300 -L -o "$TARBALL" "$URL" || {
            echo "Error: Download failed"
            rm -f "$TARBALL"
            exit 1
        }
    else
        echo "Error: wget or curl required"
        exit 1
    fi

    # Verify download succeeded and file is not empty
    if [ ! -s "$TARBALL" ]; then
        echo "Error: Downloaded file is empty or doesn't exist"
        rm -f "$TARBALL"
        exit 1
    fi
    echo "Download complete. Extracting..."

    # Extract with error checking
    if tar -xzf "$TARBALL" -C "$JAVA_DIR"; then
        rm -f "$TARBALL"
        echo "Java extracted to $JDK_DIR"
    else
        echo "Error: Extraction failed. Downloaded file may be corrupted."
        rm -f "$TARBALL"
        exit 1
    fi
fi

# Configure environment
BASHRC="$HOME/.bashrc"
sed -i '/# Java Configuration/,/# End Java Configuration/d' "$BASHRC"

cat >> "$BASHRC" << 'JAVA_EOF'

# Java Configuration
export JAVA_HOME="$HOME/java/jdk-17.0.9+9"
export PATH="$JAVA_HOME/bin:$PATH"
# End Java Configuration
JAVA_EOF

echo "Java configured in .bashrc"

# Verify
if [ -f "$JDK_DIR/bin/java" ]; then
    "$JDK_DIR/bin/java" -version
    echo "Installation complete. Java will be available on next login."
else
    echo "Error: Installation verification failed"
    echo "Expected java at: $JDK_DIR/bin/java"
    exit 1
fi

EOF

echo "Setup complete for user $USERNAME"