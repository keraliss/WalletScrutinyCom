#!/bin/bash

repo=https://github.com/piratecash/pcash-wallet-android.git
tag="v$versionName"
builtApk=$workDir/cash-p-terminal.apk # The path where the APK will be copied by the container

test() {
  # Clean previous build if exists
  podman rmi cash-p-terminal -f 2>/dev/null || true
  
  # Build the image with ulimit settings
  podman build --rm --tag cash-p-terminal --ulimit nofile=65536:65536 -f $SCRIPT_DIR/test/android/cash.p.terminal.dockerfile .
  
  # Run the container to copy the built APK
  podman run --rm -v "$workDir:/mnt" cash-p-terminal
  
#   # Clean up
#   podman rmi cash-p-terminal -f
#   podman image prune -f
}