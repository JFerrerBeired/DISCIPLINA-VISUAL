#!/bin/bash

# Exit on any error
set -e

# Function to print messages
log() {
    echo "--- $1 ---"
}

# 1. Install System Dependencies
log "Installing system dependencies..."
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -y
# Install Flutter dependencies plus the required GTK libraries for Linux desktop target
sudo apt-get install -y wget unzip default-jdk curl git libgtk-3-dev mesa-utils

# 2. Install Flutter
FLUTTER_VERSION="3.22.2" # Using a version known to be stable and compatible
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
FLUTTER_PATH="/opt/flutter"

if [ -d "$FLUTTER_PATH" ]; then
    log "Flutter already installed. Skipping."
else
    log "Installing Flutter ${FLUTTER_VERSION}..."
    wget "$FLUTTER_URL" -O /tmp/flutter.tar.xz
    sudo tar xf /tmp/flutter.tar.xz -C /opt/
    sudo chown -R $(whoami):$(whoami) "$FLUTTER_PATH"
    rm /tmp/flutter.tar.xz
fi

# 3. Add Flutter to PATH
export PATH="$FLUTTER_PATH/bin:$PATH"

# 4. Configure Git for Flutter's internal use
# This prevents the "dubious ownership" error when flutter runs git commands
git config --global --add safe.directory "$FLUTTER_PATH"

# 5. Get Flutter Project Dependencies
log "Getting Flutter project dependencies..."
flutter pub get

# 6. Check Flutter and System Status
log "Running flutter doctor..."
flutter doctor -v

# 7. Run the Application on Linux Desktop
log "Running the app on Linux desktop..."
# The app will be launched in the background. We can check logs for success.
flutter run -d linux &> flutter_run.log &
# Give the app a moment to launch
sleep 20

# Check if the process is still running
if pgrep -f "disciplina_visual" > /dev/null; then
    log "Application process found. It appears to have launched successfully."
else
    log "Application process not found. Checking logs for errors."
    cat flutter_run.log
    exit 1
fi

log "Setup and run script completed successfully."
