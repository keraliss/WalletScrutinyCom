#!/bin/bash
# testAAB.sh v0.1.0-alpha.9
# This script tests if an AAB and then split apks can be built from source.
# Currently works with io.nunchuk.android_v1.9.64.
# Exports device-spec.json that is generated. Apksigner is echoed in Begin Results block

# Uncomment for debugging
# set -x

# Global Constants
# ================
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
TEST_ANDROID_DIR="${SCRIPT_DIR}/scripts/test/android"
wsContainer="docker.io/walletscrutiny/android:5"
shouldCleanup=false

# Color Constants
# ===============
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD_CYAN='\033[1;36m'
NC='\033[0m' # No Color
BRIGHT_GREEN='\033[1;32m'

# Read script arguments and flags
# ===============================

apkDir=""
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -d|--directory) apkDir="$2"; shift ;;
    -c|--cleanup) shouldCleanup=true ;;
    *) echo "Unknown argument: $1"; exit 1 ;;
  esac
  shift
done

if [ -z "$apkDir" ]; then
  echo "APK directory not specified!"
  exit 1
fi

if [ ! -d "$apkDir" ]; then
  echo "APK directory $apkDir not found!"
  exit 1
fi

# Create temp dir for device spec
deviceSpecDir=$(mktemp -d)

# Functions
# =========
# Temporary until walletscrutiny:android is updated
containerApktool() {
  targetFolder=$1
  app=$2
  targetFolderParent=$(dirname "$targetFolder")
  targetFolderBase=$(basename "$targetFolder")
  appFolder=$(dirname "$app")
  appFile=$(basename "$app")

  # Build the command to run inside the container
  cmd=$(cat <<EOF
apt-get update && apt-get install -y wget && \
wget https://raw.githubusercontent.com/iBotPeaches/Apktool/v2.10.0/scripts/linux/apktool -O /usr/local/bin/apktool && \
wget https://github.com/iBotPeaches/Apktool/releases/download/v2.10.0/apktool_2.10.0.jar -O /usr/local/bin/apktool.jar && \
chmod +x /usr/local/bin/apktool && \
apktool d -f -o "/tfp/$targetFolderBase" "/af/$appFile"
EOF
  )

  # Run apktool in a container as root
  podman run \
    --rm \
    --user root \
    --volume "$targetFolderParent":/tfp \
    --volume "$appFolder":/af:ro \
    "$wsContainer" \
    sh -c "$cmd"

  return $?
}

getSigner() {
  apkFile=$1
  DIR=$(dirname "$apkFile")
  BASE=$(basename "$apkFile")
  s=$(
    podman run \
      --rm \
      --volume "$DIR":/mnt:ro \
      --workdir /mnt \
      $wsContainer \
      apksigner verify --print-certs "$BASE" | grep "Signer #1 certificate SHA-256"  | awk '{print $6}' )
  echo $s
}

list_apk_hashes() {
  local dir="$1"
  local title="$2"
  echo -e "${BOLD_CYAN}========================================${NC}"
  echo -e "${BOLD_CYAN}**$title**${NC}"
  for apk_file in "$dir"/*.apk; do
    [ -e "$apk_file" ] || continue
    apk_hash=$(sha256sum "$apk_file" | awk '{print $1}')
    echo "$apk_hash $(basename "$apk_file")"
  done
  echo -e "${BOLD_CYAN}========================================${NC}"
}

display_results() {
  color=$1
  apk=$2
  appHash=$3
  signer=$4
  extractionResult=$5
  appId=$6
  versionName=$7
  versionCode=$8

  echo -e "${color}"
  echo "========================================"
  echo "APK: $apk"
  echo "========================================"
  echo "SHA256 Checksum: $appHash"
  echo "Signer Extraction: $signer"
  echo "APK Extraction: $extractionResult"
  echo "Metadata Extraction:"
  echo "  - appId: $appId"
  echo "  - versionName: $versionName"
  echo "  - versionCode: $versionCode"
  echo "========================================"
  echo -e "${NC}"
}

# Main process
# ============

# List all APKs and their hashes in the specified directory
list_apk_hashes "$apkDir" "Official APKs Hashes"

# Check if base.apk exists
apk="$apkDir/base.apk"
if [ ! -f "$apk" ]; then
  echo "base.apk not found in $apkDir!"
  exit 1
fi

# Extract metadata from base.apk
echo "Extracting metadata from base.apk..."
tempExtractDir=$(mktemp -d /tmp/extract_base_XXXXXX)
containerApktool "$tempExtractDir" "$apk"
extractionResult=$?

if [ $extractionResult -ne 0 ]; then
  extractionResult="Failed"
else
  extractionResult="Success"
fi

appId=$(grep 'package=' "$tempExtractDir"/AndroidManifest.xml | sed 's/.*package=\"//g' | sed 's/\".*//g')
versionName=$(grep 'versionName' "$tempExtractDir"/apktool.yml | awk '{print $2}' | tr -d "'")
versionCode=$(grep 'versionCode' "$tempExtractDir"/apktool.yml | awk '{print $2}' | tr -d "'")

if [ -z "$appId" ]; then
  echo "appId could not be determined from $apk"
  exit 1
fi

if [ -z "$versionName" ]; then
  echo "versionName could not be determined from $apk"
  exit 1
fi

if [ -z "$versionCode" ]; then
  echo "versionCode could not be determined from $apk"
  exit 1
fi

# Define workDir
workDir="/tmp/test_${appId}_${versionName}"
export workDir

# Use only device-spec.json generated 
if [ -z "$deviceSpec" ]; then
  echo -e "${BRIGHT_GREEN}We will now generate a device-spec.json file based on the values derived from the apk.${NC}"
  # Derive supportedAbis from aapt dump badging
  supportedAbis=$(aapt dump badging "$apk" 2>/dev/null | grep "native-code" | sed 's/.*native-code: //g' | sed 's/\"//g')
  if [ -z "$supportedAbis" ]; then
    supportedAbis='["armeabi-v7a"]'
  else
    IFS=', ' read -r -a abisArray <<< "$supportedAbis"
    jsonAbis="["
    for abi in "${abisArray[@]}"; do
       jsonAbis+="\"$abi\", "
    done
    jsonAbis=$(echo "$jsonAbis" | sed 's/, $//')
    jsonAbis+="]"
    supportedAbis="$jsonAbis"
  fi

  # Derive sdkVersion from aapt dump badging
  sdkVersion=$(aapt dump badging "$apk" 2>/dev/null | grep "sdkVersion" | head -n1 | sed "s/.*sdkVersion:'\([0-9]*\)'.*/\1/")
  if [ -z "$sdkVersion" ]; then
    sdkVersion=31
  fi

  # Set defaults for supportedLocales and screenDensity
  supportedLocales='["en"]'
  screenDensity=280

  echo -e "${BRIGHT_GREEN}The device-spec.json file will have these values:${NC}"
  echo -e "${BRIGHT_GREEN}{"
  echo -e "${BRIGHT_GREEN}  \"supportedAbis\": $supportedAbis,"
  echo -e "${BRIGHT_GREEN}  \"supportedLocales\": $supportedLocales,"
  echo -e "${BRIGHT_GREEN}  \"screenDensity\": $screenDensity,"
  echo -e "${BRIGHT_GREEN}  \"sdkVersion\": $sdkVersion"
  echo -e "${BRIGHT_GREEN}}${NC}"
  echo -e "${BRIGHT_GREEN}Continue? y/n${NC}"
  read -r userInput
  if [ "$userInput" != "y" ]; then
    echo "Aborting."
    exit 1
  fi

  # Ensure workDir exists
  mkdir -p "$workDir"
  
  tempSpec="$workDir/device-spec.json"
  # Create device-spec.json
  if ! cat > "$tempSpec" <<EOF
{
  "supportedAbis": $supportedAbis,
  "supportedLocales": $supportedLocales,
  "screenDensity": $screenDensity,
  "sdkVersion": $sdkVersion
}
EOF
  then
    echo "Error: Failed to create device-spec.json"
    exit 1
  fi

  # Verify file was created and has content
  if [ ! -s "$tempSpec" ]; then
    echo "Error: device-spec.json was created but is empty"
    exit 1
  fi
  
  echo -e "${BRIGHT_GREEN}Generated device spec at $tempSpec:${NC}"
  cat "$tempSpec"
  echo -e "${BRIGHT_GREEN}Device spec file path:${NC} $tempSpec"
  deviceSpec="$tempSpec"
  export deviceSpec
fi

# Define and create workDir
mkdir -p "$workDir/fromPlay-decoded/base"
mkdir -p "$workDir/fromPlay-unzipped/base"

# Move the decoded base.apk to the appropriate directory
mv "$tempExtractDir"/* "$workDir/fromPlay-decoded/base/"
rm -rf "$tempExtractDir"

# Unzip base.apk to fromPlay-unzipped/base
unzip -o "$apk" -d "$workDir/fromPlay-unzipped/base"

# Process other APKs in apkDir
for apk_file in "$apkDir"/*.apk; do
  [ -e "$apk_file" ] || continue
  apk_name=$(basename "$apk_file")
  if [ "$apk_name" = "base.apk" ]; then
    continue
  fi
  # Normalize apk_name
  normalized_name=$(echo "$apk_name" | sed 's/^split_config\.//; s/\.apk$//')
  mkdir -p "$workDir/fromPlay-unzipped/$normalized_name"
  unzip -o "$apk_file" -d "$workDir/fromPlay-unzipped/$normalized_name"
done

# Get appHash and signer
appHash=$(sha256sum "$apk" | awk '{print $1;}')
signer=$( getSigner "$apk" )

# Display meta information
display_results "$CYAN" "$apk" "$appHash" "$signer" "$extractionResult" "$appId" "$versionName" "$versionCode"

# Source the app-specific script
echo "Attempting to source $TEST_ANDROID_DIR/$appId.sh"
if [ -f "$TEST_ANDROID_DIR/$appId.sh" ]; then
  source "$TEST_ANDROID_DIR/$appId.sh"
  echo "Sourced $TEST_ANDROID_DIR/$appId.sh successfully"
else
  echo "Error: $TEST_ANDROID_DIR/$appId.sh not found"
  exit 1
fi

# The app-specific script should build the AAB, generate split APKs, and place them in $workDir/built-split_apks/

# After app-specific script execution
# List built APKs and their hashes
list_apk_hashes "$workDir/built-split_apks" "Built APKs Hashes"

# Extract and normalize built APKs
for apk_file in "$workDir/built-split_apks"/*.apk; do
  [ -e "$apk_file" ] || continue
  apk_name=$(basename "$apk_file")

  # Special handling for base-master.apk - match with fromPlay extraction to base
  if [ "$apk_name" = "base-master.apk" ]; then
    mkdir -p "$workDir/fromBuild-unzipped/base"
    unzip -o "$apk_file" -d "$workDir/fromBuild-unzipped/base"
    continue
  fi
    # Normalize apk_name
  normalized_name=$(echo "$apk_name" | sed 's/^base-//; s/^split_config\.//; s/\.apk$//')
  mkdir -p "$workDir/fromBuild-unzipped/$normalized_name"
  unzip -o "$apk_file" -d "$workDir/fromBuild-unzipped/$normalized_name"
done

# Display extracted built APK directories
echo -e "${GREEN}Built split APKs have been extracted in the following directories:${NC}"
for dir in "$workDir/fromBuild-unzipped"/*; do
  echo "- $dir"
done

# Begin Results
echo "===== Begin Results ====="
echo "APK Signer (SHA-256): $signer"

# Compare hashes of official and built APKs
echo -e "${YELLOW}*** Comparing Official and Built APKs Hashes ***${NC}"
echo -e "${CYAN}Official APKs:${NC}"
list_apk_hashes "$apkDir" "Official APKs Hashes"
echo -e "${CYAN}Built APKs:${NC}"
list_apk_hashes "$workDir/built-split_apks" "Built APKs Hashes"

# Run diffs between corresponding directories
echo "Running diffs between official and built unzipped APKs..."
for dir in "$workDir/fromPlay-unzipped"/*; do
  dir_name=$(basename "$dir")
  if [ -d "$workDir/fromBuild-unzipped/$dir_name" ]; then
    echo "Comparing $dir_name..."
    diff_result=$(diff -r "$dir" "$workDir/fromBuild-unzipped/$dir_name")
    if [ -z "$diff_result" ]; then
      echo -e "${GREEN}No differences found between $dir and $workDir/fromBuild-unzipped/$dir_name${NC}"
      # Create an empty diff file to indicate no differences
      touch "$workDir/diff_$dir_name.txt"
    else
      echo -e "${YELLOW}Differences found between $dir and $workDir/fromBuild-unzipped/$dir_name${NC}"
      echo -e "${BRIGHT_CYAN}$(echo "$diff_result" | head -n 10)${NC}"
      if [ "$(echo "$diff_result" | wc -l)" -gt 10 ]; then
        echo -e "${YELLOW}[Output truncated. Full diff saved to $workDir/diff_$dir_name.txt]${NC}"
      fi
      echo "$diff_result" > "$workDir/diff_$dir_name.txt"
      echo "Differences saved to $workDir/diff_$dir_name.txt"
    fi
  else
    echo -e "${YELLOW}Built directory for $dir_name not found${NC}"
  fi
done

# Display End Results 
echo "===== End Results ====="

# Create the parent directory before decoding
mkdir -p "$workDir/fromBuild-decoded"

# Decode built base.apk
built_base_apk="$workDir/built-split_apks/base.apk"
if [ ! -f "$built_base_apk" ]; then
  echo "Built base.apk not found at $built_base_apk"
  exit 1
fi

containerApktool "$workDir/fromBuild-decoded/base" "$built_base_apk"

# Run diffoscope on AndroidManifest.xml
diffoscope_output="$workDir/diffoscope_AndroidManifest.html"
echo "Running diffoscope on AndroidManifest.xml..."
diffoscope --html "$diffoscope_output" "$workDir/fromPlay-decoded/base/AndroidManifest.xml" "$workDir/fromBuild-decoded/base/AndroidManifest.xml"

echo "Diffoscope output saved to $diffoscope_output"

# Check stamp-cert-sha256
stamp_cert_file_play="$workDir/fromPlay-decoded/base/stamp-cert-sha256"
stamp_cert_file_build="$workDir/fromBuild-decoded/base/stamp-cert-sha256"

if [ -f "$stamp_cert_file_play" ]; then
  size_play=$(wc -c < "$stamp_cert_file_play")
  echo "The file size of official stamp-cert-sha256 is $size_play bytes"
fi

if [ -f "$stamp_cert_file_build" ]; then
  size_build=$(wc -c < "$stamp_cert_file_build")
  echo "The file size of built stamp-cert-sha256 is $size_build bytes"
fi

# Display the diff results again at the end of the script
echo -e "${YELLOW}*** Summary of Differences ***${NC}"
for diff_file in "$workDir"/diff_*.txt; do
  if [ -s "$diff_file" ]; then
    diff_name=$(basename "$diff_file")
    echo -e "${CYAN}Contents of $diff_name:${NC}"
    cat "$diff_file"
    echo ""
  else
    echo -e "${GREEN}No differences found for $(basename "$diff_file" .txt)${NC}"
  fi
done

echo -e "${GREEN}Process completed.${NC}"

# Cleanup if needed
if [ "$shouldCleanup" = true ]; then
  echo "Cleaning up temporary files..."
  rm -rf "$workDir"
  rm -rf "$deviceSpecDir"
fi

echo -e "${GREEN}Process completed.${NC}"