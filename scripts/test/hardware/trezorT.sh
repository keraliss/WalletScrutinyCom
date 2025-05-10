#!/bin/bash

# This script downloads Trezor T firmware, builds it from source, and compares hashes
# Usage: ./script.sh <version>
# Example: ./script.sh 2.8.9

# Exit on any error
set -e

# Define colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

if [ -z "$1" ]; then
    echo -e "${RED}Error: Version parameter is required${NC}"
    echo "Usage: $0 <version>"
    echo "Example: $0 2.8.9"
    exit 1
fi

version=$1
echo -e "${BLUE}Analyzing Trezor T firmware version ${version}${NC}"

# Create a working directory
workdir=$(mktemp -d)
echo -e "${BLUE}Working directory: ${workdir}${NC}"
cd "$workdir"

# Download firmware files with correct URLs
echo -e "${BLUE}Downloading firmware files...${NC}"
wget -q "https://data.trezor.io/firmware/t2t1/trezor-t2t1-${version}.bin" -O trezor-firmware.bin
wget -q "https://data.trezor.io/firmware/t2t1/trezor-t2t1-${version}-bitcoinonly.bin" -O trezor-firmware-bitcoinonly.bin

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

# Download releases.json to find bootloader version
echo -e "${BLUE}Downloading releases.json to find bootloader version...${NC}"
wget -q "https://data.trezor.io/firmware/t2t1/releases.json" -O releases.json

# Extract bootloader version for the specified firmware version
major=$(echo $version | cut -d. -f1)
minor=$(echo $version | cut -d. -f2)
patch=$(echo $version | cut -d. -f3)
version_pattern="\"version\": \[$major, $minor, $patch\]"

bootloader_version_line=$(grep -A 15 "$version_pattern" releases.json | grep '"bootloader_version"' | head -1)
bootloader_version=$(echo "$bootloader_version_line" | grep -o "\[.*\]" | tr -d '[]" ' | tr ',' '.')

if [ -z "$bootloader_version" ]; then
    echo -e "${YELLOW}Error: Could not find bootloader version for firmware $version${NC}"
    echo -e "${YELLOW}Trying alternative URL...${NC}"
    wget -q "https://data.trezor.io/firmware/releases.json" -O releases.json
    
    bootloader_version_line=$(grep -A 15 "$version_pattern" releases.json | grep '"bootloader_version"' | head -1)
    bootloader_version=$(echo "$bootloader_version_line" | grep -o "\[.*\]" | tr -d '[]" ' | tr ',' '.')
    
    if [ -z "$bootloader_version" ]; then
        echo -e "${RED}Error: Could not find bootloader version for firmware $version in either location${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}Found bootloader version ${bootloader_version} for firmware ${version}${NC}"

echo -e "\n${BLUE}Cloning firmware repository...${NC}"
git clone https://github.com/trezor/trezor-firmware.git
cd trezor-firmware

echo -e "${BLUE}Checking out version ${version}...${NC}"
git checkout "core/v${version}"

# Check for reference bootloader in the repository
echo -e "\n${GREEN}=== Bootloader Analysis ===${NC}"

reference_bootloader_path="core/embed/models/T2T1/bootloaders/bootloader_T2T1.bin"
if [ -f "$reference_bootloader_path" ]; then
    reference_bootloader_hash=$(sha256sum "$reference_bootloader_path" | cut -d' ' -f1)
    echo -e "${GREEN}Found reference bootloader in repository${NC}"
    echo -e "${GREEN}Reference bootloader hash: ${reference_bootloader_hash}${NC}"
else
    echo -e "${YELLOW}No reference bootloader found in repository at ${reference_bootloader_path}${NC}"
    echo -e "${YELLOW}Checking alternative paths...${NC}"
    
    # Check alternative paths where the bootloader might be stored
    alternative_paths=(
        "core/embed/bootloader/bootloader.bin"
        "core/embed/models/T/bootloaders/bootloader_T.bin"
        "legacy/bootloader/bootloader.bin"
    )
    
    found=false
    for path in "${alternative_paths[@]}"; do
        if [ -f "$path" ]; then
            reference_bootloader_path="$path"
            reference_bootloader_hash=$(sha256sum "$path" | cut -d' ' -f1)
            echo -e "${GREEN}Found reference bootloader at ${path}${NC}"
            echo -e "${GREEN}Reference bootloader hash: ${reference_bootloader_hash}${NC}"
            found=true
            break
        fi
    done
    
    if [ "$found" = false ]; then
        echo -e "${YELLOW}No reference bootloader found in repository${NC}"
    fi
fi

echo -e "${BLUE}Building firmware...${NC}"
# Use the correct build command for modern Trezor firmware
./build-docker.sh --models T2T1 --targets firmware core/v${version}

# Check if build was successful by looking for the built firmware files
if [ ! -f "build/core-T2T1/firmware/firmware.bin" ]; then
    echo -e "${RED}Error: Failed to build standard firmware${NC}"
    echo -e "${YELLOW}This could be due to changes in the build system or Docker configuration${NC}"
    # Continue anyway to check downloaded firmware
else
    echo -e "${GREEN}Standard firmware built successfully${NC}"
fi

if [ ! -f "build/core-T2T1-bitcoinonly/firmware/firmware.bin" ]; then
    echo -e "${RED}Error: Failed to build Bitcoin-only firmware${NC}"
    # Continue anyway to check downloaded firmware
else
    echo -e "${GREEN}Bitcoin-only firmware built successfully${NC}"
fi

echo
echo -e "${GREEN}=== Firmware Analysis ====${NC}"

echo -e "${BLUE}Hash of the signed firmware:${NC}"
echo -e "Standard:     ${standard_hash}  trezor-firmware.bin"
echo -e "Bitcoin-only: ${bitcoin_hash}  trezor-firmware-bitcoinonly.bin"

echo
echo -e "${BLUE}Creating zeroed versions (signatures removed) for comparison:${NC}"

# Create zeroed versions of the firmware files (remove signatures)
cp "$workdir/trezor-firmware.bin" "$workdir/trezor-firmware.bin.zeroed"
dd if=/dev/zero of="$workdir/trezor-firmware.bin.zeroed" bs=1 seek=5567 count=65 conv=notrunc status=none

cp "$workdir/trezor-firmware-bitcoinonly.bin" "$workdir/trezor-firmware-bitcoinonly.bin.zeroed"
dd if=/dev/zero of="$workdir/trezor-firmware-bitcoinonly.bin.zeroed" bs=1 seek=5567 count=65 conv=notrunc status=none

# Calculate hashes of zeroed firmware
standard_zeroed_hash=$(sha256sum "$workdir/trezor-firmware.bin.zeroed" | cut -d' ' -f1)
bitcoin_zeroed_hash=$(sha256sum "$workdir/trezor-firmware-bitcoinonly.bin.zeroed" | cut -d' ' -f1)

echo -e "${BLUE}Hash of downloaded firmware with signatures zeroed:${NC}"
echo -e "Standard:     ${standard_zeroed_hash}  trezor-firmware.bin.zeroed"
echo -e "Bitcoin-only: ${bitcoin_zeroed_hash}  trezor-firmware-bitcoinonly.bin.zeroed"

# Check if built firmware exists and calculate hashes
echo
echo -e "${BLUE}Checking built firmware (if available):${NC}"

built_standard_path="build/core-T2T1/firmware/firmware.bin"
built_bitcoin_path="build/core-T2T1-bitcoinonly/firmware/firmware.bin"

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

# Now build the bootloader
echo
echo -e "${GREEN}=== Building and checking bootloader ===${NC}"
echo -e "${BLUE}Checking out bootloader version ${bootloader_version}...${NC}"

cd "$workdir"
# Clone a fresh repository for the bootloader build
git clone https://github.com/trezor/trezor-firmware.git bootloader-repo
cd bootloader-repo

git checkout "core/bl${bootloader_version}"
echo -e "${BLUE}Building bootloader version ${bootloader_version}...${NC}"
./build-docker.sh --models T --targets bootloader "core/bl${bootloader_version}"

built_bootloader_path="build/core-T/bootloader/bootloader.bin"
if [ -f "$built_bootloader_path" ]; then
    built_bootloader_hash=$(sha256sum "$built_bootloader_path" | cut -d' ' -f1)
    echo -e "${GREEN}Built bootloader hash: ${built_bootloader_hash}${NC}"
    
    # Compare with reference bootloader if it was found
    if [ ! -z "$reference_bootloader_hash" ]; then
        if [ "$reference_bootloader_hash" = "$built_bootloader_hash" ]; then
            echo -e "${GREEN}MATCH: The built bootloader matches the reference bootloader in the repository!${NC}"
        else
            echo -e "${YELLOW}MISMATCH: The built bootloader does not match the reference bootloader.${NC}"
        fi
    fi
else
    echo -e "${YELLOW}Failed to build bootloader - file not found${NC}"
fi

echo
echo -e "${GREEN}Working directory preserved for manual inspection: ${workdir}${NC}"
echo -e "${YELLOW}To clean up manually later, run: rm -rf ${workdir}${NC}"
echo -e "${GREEN}Analysis complete!${NC}"

if [ ! -z "$reference_bootloader_hash" ]; then
    echo -e "${GREEN}Reference bootloader hash: ${reference_bootloader_hash}${NC}"
fi

if [ ! -z "$built_bootloader_hash" ]; then
    echo -e "${GREEN}Built bootloader hash: ${built_bootloader_hash}${NC}"
fi