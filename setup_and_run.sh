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
FLUTTER_VERSION="3.35.0" # Using a version known to be stable and compatible
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

# 7. Run the Application on Web
log "Running the app on web..."
# The app will be launched in the background. We can check logs for success.
flutter run -d web-server &> flutter_run.log &

log "Waiting for web server to be ready..."
ATTEMPTS=0
MAX_ATTEMPTS=30
while [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
    PORT_LINE=$(grep 'is being served at' flutter_run.log || true)
    if [ ! -z "$PORT_LINE" ]; then
        log "Web server is ready."
        break
    fi
    sleep 2
    ATTEMPTS=$((ATTEMPTS + 1))
done

if [ -z "$PORT_LINE" ]; then
    log "Web server failed to start in time. Checking logs for errors."
    cat flutter_run.log
    exit 1
fi

log "Setup and run script completed successfully."
