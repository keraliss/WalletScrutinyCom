#!/bin/bash

# Provide version without "v" as argument
version=$1

# Create archive directory if it doesn't exist
mkdir -p /var/shared/firmware/trezorSafe3/${version}

# Download firmware files
wget https://data.trezor.io/firmware/t2b1/trezor-t2b1-${version}.bin
wget https://data.trezor.io/firmware/t2b1/trezor-t2b1-${version}-bitcoinonly.bin

# Store initial hashes
INITIAL_HASHES=$(sha256sum *.bin)

# Store the non-zeroed hashes separately for final output
standard_nonzeroed_hash=$(sha256sum trezor-t2b1-${version}.bin | cut -d' ' -f1)
bitcoin_nonzeroed_hash=$(sha256sum trezor-t2b1-${version}-bitcoinonly.bin | cut -d' ' -f1)

# Copy to archive
cp trezor-t2b1-${version}.bin /var/shared/firmware/trezorSafe3/${version}/
cp trezor-t2b1-${version}-bitcoinonly.bin /var/shared/firmware/trezorSafe3/${version}/

# Clone and prepare repository
git clone https://github.com/trezor/trezor-firmware.git
cd trezor-firmware

# Checkout the version
git checkout core/v${version}

# Store commit hash
COMMIT_HASH=$(git rev-parse HEAD)

# Build firmware - using T2B1 instead of R
bash -c "./build-docker.sh --models T2B1 core/v${version}"

# Store fingerprints with clear labeling
FINGERPRINTS=$(echo "Standard firmware:" && 
               sha256sum build/core-T2B1/firmware/firmware.bin 2>/dev/null &&
               echo "Bitcoin-only firmware:" &&
               sha256sum build/core-T2B1-bitcoinonly/firmware/firmware.bin 2>/dev/null &&
               echo "Bootloaders:" &&
               sha256sum build/core-T2B1/bootloader/bootloader.bin 2>/dev/null &&
               sha256sum build/core-T2B1-bitcoinonly/bootloader/bootloader.bin 2>/dev/null)

# Zero out signatures
vendorHeaderSize=4608
seekSize=$((5567 - vendorHeaderSize + 512))

cp ../trezor-t2b1-${version}.bin trezor-t2b1-${version}.bin.zeroed
cp ../trezor-t2b1-${version}-bitcoinonly.bin trezor-t2b1-${version}-bitcoinonly.bin.zeroed

dd if=/dev/zero of=trezor-t2b1-${version}.bin.zeroed bs=1 seek=$seekSize count=65 conv=notrunc 2>/dev/null
dd if=/dev/zero of=trezor-t2b1-${version}-bitcoinonly.bin.zeroed bs=1 seek=$seekSize count=65 conv=notrunc 2>/dev/null

# Calculate and store zeroed hashes with clear labeling
standard_zeroed_hash=$(sha256sum trezor-t2b1-${version}.bin.zeroed | cut -d' ' -f1)
bitcoin_zeroed_hash=$(sha256sum trezor-t2b1-${version}-bitcoinonly.bin.zeroed | cut -d' ' -f1)
standard_built_hash=$(sha256sum build/core-T2B1/firmware/firmware.bin 2>/dev/null | cut -d' ' -f1 || echo "NOT_FOUND")
bitcoin_built_hash=$(sha256sum build/core-T2B1-bitcoinonly/firmware/firmware.bin 2>/dev/null | cut -d' ' -f1 || echo "NOT_FOUND")

# Create a clearer comparison output
ZEROED_COMPARISON=$(echo "Standard firmware:"
echo "$standard_built_hash build/core-T2B1/firmware/firmware.bin"
echo "$standard_zeroed_hash trezor-t2b1-${version}.bin.zeroed"
echo ""
echo "Bitcoin-only firmware:"
echo "$bitcoin_built_hash build/core-T2B1-bitcoinonly/firmware/firmware.bin"
echo "$bitcoin_zeroed_hash trezor-t2b1-${version}-bitcoinonly.bin.zeroed")

# Cleanup downloaded and temporary files
cd ..
rm -f trezor-t2b1-${version}.bin trezor-t2b1-${version}-bitcoinonly.bin
rm -f trezor-t2b1-${version}.bin.zeroed trezor-t2b1-${version}-bitcoinonly.bin.zeroed
rm -rf trezor-firmware

# Output all results at the end in the correct order
echo "Hash of the binaries downloaded:"
echo "$INITIAL_HASHES"
echo
echo "Built from commit $COMMIT_HASH"
echo
echo "Fingerprints:"
echo "$FINGERPRINTS"
echo
echo "Comparing hashes of zeroed binaries with built firmware:"
echo "$ZEROED_COMPARISON"

# Add clear validation output
echo
echo "Validation results:"
if [ "$standard_built_hash" = "NOT_FOUND" ]; then
    echo "⚠️ Standard firmware build FAILED"
elif [ "$standard_zeroed_hash" = "$standard_built_hash" ]; then
    echo "✅ Standard firmware MATCH"
else
    echo "❌ Standard firmware MISMATCH"
fi

if [ "$bitcoin_built_hash" = "NOT_FOUND" ]; then
    echo "⚠️ Bitcoin-only firmware build FAILED"
elif [ "$bitcoin_zeroed_hash" = "$bitcoin_built_hash" ]; then
    echo "✅ Bitcoin-only firmware MATCH"
else
    echo "❌ Bitcoin-only firmware MISMATCH"
fi

# Add the non-zeroed hashes for comparison with external sources
echo
echo "Original non-zeroed firmware hashes for external comparison:"
echo "Standard firmware: $standard_nonzeroed_hash"
echo "Bitcoin-only firmware: $bitcoin_nonzeroed_hash"