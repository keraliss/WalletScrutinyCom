#!/bin/bash

# trezorSafe5.sh - Script for verifying Trezor Safe 5 firmware reproducibility
# Usage: ./trezorSafe5.sh <version>
# Example: ./trezorSafe5.sh 2.8.9

# Define colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if version parameter is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: Version parameter is required${NC}"
    echo "Usage: $0 <version>"
    echo "Example: $0 2.8.9"
    exit 1
fi

version=$1
echo -e "${BLUE}Analyzing Trezor Safe 5 firmware version ${version}${NC}"

# Create a working directory
workdir=$(mktemp -d)
echo -e "${BLUE}Working directory: ${workdir}${NC}"
cd "$workdir"

# Download firmware files with correct URLs
echo -e "${BLUE}Downloading firmware files...${NC}"
wget -q "https://data.trezor.io/firmware/t3t1/trezor-t3t1-${version}.bin" -O trezor-firmware.bin
wget -q "https://data.trezor.io/firmware/t3t1/trezor-t3t1-${version}-bitcoinonly.bin" -O trezor-firmware-bitcoinonly.bin

# Verify downloads were successful
if [ ! -s trezor-firmware.bin ]; then
    echo -e "${RED}Error: Failed to download standard firmware${NC}"
    exit 1
fi

if [ ! -s trezor-firmware-bitcoinonly.bin ]; then
    echo -e "${RED}Error: Failed to download Bitcoin-only firmware${NC}"
    exit 1
fi

echo -e "${GREEN}Successfully downloaded firmware files${NC}"

# Save original firmware hashes
standard_hash=$(sha256sum trezor-firmware.bin | cut -d' ' -f1)
bitcoin_hash=$(sha256sum trezor-firmware-bitcoinonly.bin | cut -d' ' -f1)

echo -e "\n${BLUE}Cloning firmware repository...${NC}"
git clone https://github.com/trezor/trezor-firmware.git
cd trezor-firmware

echo -e "${BLUE}Checking out version ${version}...${NC}"
git checkout "core/v${version}"
commit_hash=$(git rev-parse HEAD)

echo -e "${BLUE}Building firmware...${NC}"
# Use the correct build command for Trezor Safe 5 firmware
./build-docker.sh --models T3T1 --skip-legacy core/v${version}

# Check if build was successful by looking for the built firmware files
if [ ! -f "build/core-T3T1/firmware/firmware.bin" ]; then
    echo -e "${RED}Error: Failed to build standard firmware${NC}"
    echo -e "${YELLOW}This could be due to changes in the build system or Docker configuration${NC}"
    # Continue anyway to check downloaded firmware
else
    echo -e "${GREEN}Standard firmware built successfully${NC}"
fi

if [ ! -f "build/core-T3T1-bitcoinonly/firmware/firmware.bin" ]; then
    echo -e "${RED}Error: Failed to build Bitcoin-only firmware${NC}"
    # Continue anyway to check downloaded firmware
else
    echo -e "${GREEN}Bitcoin-only firmware built successfully${NC}"
fi

cd "$workdir"

echo
echo -e "${GREEN}=== Firmware Analysis ====${NC}"

echo -e "${BLUE}Hash of the signed firmware:${NC}"
echo -e "Standard:     ${standard_hash}  trezor-firmware.bin"
echo -e "Bitcoin-only: ${bitcoin_hash}  trezor-firmware-bitcoinonly.bin"

echo
echo -e "${BLUE}Creating zeroed versions (signatures removed) for comparison:${NC}"

# Create zeroed versions of the firmware files (remove signatures)
# Note the different signature offset for T3T1 model (1983 instead of 5567)
cp trezor-firmware.bin trezor-firmware.bin.zeroed
dd if=/dev/zero of=trezor-firmware.bin.zeroed bs=1 seek=1983 count=65 conv=notrunc status=none

cp trezor-firmware-bitcoinonly.bin trezor-firmware-bitcoinonly.bin.zeroed
dd if=/dev/zero of=trezor-firmware-bitcoinonly.bin.zeroed bs=1 seek=1983 count=65 conv=notrunc status=none

# Calculate hashes of zeroed firmware
standard_zeroed_hash=$(sha256sum trezor-firmware.bin.zeroed | cut -d' ' -f1)
bitcoin_zeroed_hash=$(sha256sum trezor-firmware-bitcoinonly.bin.zeroed | cut -d' ' -f1)

echo -e "${BLUE}Hash of downloaded firmware with signatures zeroed:${NC}"
echo -e "Standard:     ${standard_zeroed_hash}  trezor-firmware.bin.zeroed"
echo -e "Bitcoin-only: ${bitcoin_zeroed_hash}  trezor-firmware-bitcoinonly.bin.zeroed"

# Check if built firmware exists and calculate hashes
echo
echo -e "${BLUE}Checking built firmware (if available):${NC}"

built_standard_path="trezor-firmware/build/core-T3T1/firmware/firmware.bin"
built_bitcoin_path="trezor-firmware/build/core-T3T1-bitcoinonly/firmware/firmware.bin"

if [ -f "$built_standard_path" ]; then
    built_standard_hash=$(sha256sum "$built_standard_path" | cut -d' ' -f1)
    echo -e "${GREEN}Built standard firmware hash: ${built_standard_hash}${NC}"
    
    if [ "$standard_zeroed_hash" = "$built_standard_hash" ]; then
        echo -e "${GREEN}MATCH: The zeroed standard firmware matches the built firmware!${NC}"
    else
        echo -e "${YELLOW}MISMATCH: The zeroed standard firmware does not match the built firmware.${NC}"
    fi
else
    echo -e "${YELLOW}Built standard firmware not found - skipping comparison${NC}"
fi

if [ -f "$built_bitcoin_path" ]; then
    built_bitcoin_hash=$(sha256sum "$built_bitcoin_path" | cut -d' ' -f1)
    echo -e "${GREEN}Built Bitcoin-only firmware hash: ${built_bitcoin_hash}${NC}"
    
    if [ "$bitcoin_zeroed_hash" = "$built_bitcoin_hash" ]; then
        echo -e "${GREEN}MATCH: The zeroed Bitcoin-only firmware matches the built firmware!${NC}"
    else
        echo -e "${YELLOW}MISMATCH: The zeroed Bitcoin-only firmware does not match the built firmware.${NC}"
    fi
else
    echo -e "${YELLOW}Built Bitcoin-only firmware not found - skipping comparison${NC}"
fi

echo
echo -e "${GREEN}=== Build Information ===${NC}"
echo -e "${BLUE}Built from commit: ${commit_hash}${NC}"

# Add clear validation output
echo
echo -e "${GREEN}Validation results:${NC}"
if [ -f "$built_standard_path" ]; then
    if [ "$standard_zeroed_hash" = "$built_standard_hash" ]; then
        echo -e "${GREEN}✅ Standard firmware MATCH${NC}"
    else
        echo -e "${RED}❌ Standard firmware MISMATCH${NC}"
    fi
else
    echo -e "${YELLOW}⚠️ Standard firmware build FAILED${NC}"
fi

if [ -f "$built_bitcoin_path" ]; then
    if [ "$bitcoin_zeroed_hash" = "$built_bitcoin_hash" ]; then
        echo -e "${GREEN}✅ Bitcoin-only firmware MATCH${NC}"
    else
        echo -e "${RED}❌ Bitcoin-only firmware MISMATCH${NC}"
    fi
else
    echo -e "${YELLOW}⚠️ Bitcoin-only firmware build FAILED${NC}"
fi

echo
echo -e "${GREEN}Working directory preserved for manual inspection: ${workdir}${NC}"
echo -e "${YELLOW}To clean up manually later, run: rm -rf ${workdir}${NC}"
echo -e "${GREEN}Analysis complete!${NC}"