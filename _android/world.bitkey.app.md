---
wsId: bitkeyBlock
title: Bitkey - Bitcoin Wallet
altTitle: 
authors:
- danny
users: 5000
appId: world.bitkey.app
appCountry: US
released: 2024-02-28
updated: 2025-02-26
version: 2025.1.1 (1)
stars: 4.1
ratings: 
reviews: 18
website: https://bitkey.world
repository: https://github.com/proto-at-block/bitkey
issue: 
icon: world.bitkey.app.png
bugbounty: 
meta: ok
verdict: wip
appHashes:
- 3850818298d2c8f13eb42c38b2fac7f9c46a3047bb8c99c26a1f03901ac097b4
- 782c20f09f9ced07b5b933dc3f7cdc22c1de2e9723a52e8c62b480fa5c6e1438
- f5ecf995f916caef93300c55eedce4e3b9cb8a95a0b33cda35571ac6cd7dda28
- 54cc265679cd8925b9045b3bb8e6099f15f74d55f3f1d8255d4f8773e0cc9bdb
date: 2025-03-03
signer: c0d0f9da7158cde788d0281e9ebd07034178165584d635f7ce17f77c037d961a
reviewArchive:
- date: 2024-12-16
  version: 2024.74.1 (1)
  appHashes:
  - b7d9b4829f6296a7c01ee789e10cf4fad4b1bf514f8f2fafd2844ca129d57c91
  - e81e73a66e18e53eb8be2eadfee9fb901c5554ed1ba5cc92466e04aeeed41d19
  - 221ddbe7796a123c565a002e2bf0356a4d2d4098a8a58f415d25e852d6300d1e
  - a6a40e592bafb2c58c92491a9fd27107a018cc1add4013754e54f7187a9eb404
  gitRevision: a06617f9acadfcfedb75effc3aafc544d5051eb2
  verdict: nonverifiable
- date: 2024-12-07
  version: 2024.73.1 (2)
  appHashes:
  - c450bc84fe154daa4cec5af3a87bf1646fd0fa2d340a99a608d25f737173ca52
  gitRevision: 5d7b9b51299533649649997ba132ef2bd73f49f5
  verdict: nonverifiable
- date: 2024-09-23
  version: 2024.69.0 (4)
  appHashes:
  - 67c4d8ec5beec9b6424a39700e0fc9673f713a98d965a6cdd3ef4a968fd000af
  gitRevision: 3cb9e16e08babae6e2f6ce682158ba2aa6c603c5
  verdict: reproducible
- date: 2024-08-30
  version: 2024.68.0 (1)
  appHashes:
  - 0979d68dc323e95dbb5ddb4be259d7d0fcd83eccab4d5af5dd18a4632d216fa1
  gitRevision: 65f0d9d3018e6f4e8a32f53de5263b6c2e132964
  verdict: reproducible
- date: 2024-08-30
  version: 2024.67.0 (1)
  appHashes:
  - a3699344ebea4262a7d5652a6ea0a9bf45ab1b3a73423fae3e289c05f3c9ee72
  gitRevision: 3e0dace0287b9ad1ad11631f05bb5f067db5db6d
  verdict: reproducible
- date: 2024-07-26
  version: 2024.63.0 (4)
  appHashes:
  - d1adb1725e83e115c169f3676cee3b67fb97e044f6e8ba5be4c7dd88fe746de9
  gitRevision: 6ae7c72d480ca51b583f6b18d05516226e30f5a4
  verdict: reproducible
- date: 2024-03-23
  version: 2024.63.0 (2)
  appHashes:
  - 110568d39beb8b0ccb6fc0f4ed710c2d129392137acc9e97202d5ac1ee192125
  gitRevision: 93c2de0de2ff3717c59dffa274b444490b4a45d6
  verdict: reproducible
twitter: Bitkeyofficial
social:
- https://www.linkedin.com/company/bitkey-official
- https://www.facebook.com/profile.php?id=100088526238789
- https://www.instagram.com/ownbitkey
redirect_from: 
developerName: Block, Inc.
features:
- multiSignature

---

**Disclaimer**: The WalletScrutiny project is sponsored by Spiral, a subsidiary of Block.

## Analysis 

This is the **companion app** to the {% include walletLink.html wallet='hardware/blockhww' verdict='true' %}. It requires an NFC-capable phone, otherwise the app would not be installed.

<hr>

[**Release Notes**](https://bitkey.world/en-US/releases)

# Verified Builds

[Documentation](https://github.com/proto-at-block/bitkey/blob/main/app/verifiable-build/android/README.md) 


## Version 2025.1.1 (1)

We endeavored to follow the instructions in the [README](https://github.com/proto-at-block/bitkey/blob/main/app/verifiable-build/android/README.md) to build the app. 

However, we noticed some recurring problems. 

Git version not found.

  ```
  2.446 Package git is not available, but is referred to by another package.
  2.446 This may mean that the package is missing, has been obsoleted, or
  2.446 is only available from another source
  2.446 However the following packages replace it:
  2.446   git-svn
  2.446 
  2.451 E: Version '1:2.34.1-1ubuntu1.12' for 'git' was not found
  ```

This was remedied by replacing [this line](https://github.com/proto-at-block/bitkey/blob/7e17ee0bc103853c91a05079b8d4e49bbba42634/app/verifiable-build/android/Dockerfile#L8) in the Dockerfile, to a git version that is not pinned.

  ```dockerfile
  RUN apt update && apt upgrade -y
  RUN apt install -y git
  ```

Next, we then had problems with the segment of the script that looks for aapt2. Although we followed the instructions in the ['prep stage'](https://github.com/proto-at-block/bitkey/blob/main/app/verifiable-build/android/README.md), this did not work until we installed build-tools-34.0.0 and exported aapt2 to the correct path.

## Version 2025.1.1 (1) Build Results

  ```
  Comparing builds:

  + '[' 2 -ne 2 ']'
  + which diff
  + which /home/dannybuntu/Android/Sdk/build-tools/34.0.0/aapt2
  + lhs_comparable=verify-apk/from-device/comparable
  + lhs_apks=verify-apk/from-device/normalized-names
  + rhs_comparable=verify-apk/locally-built/comparable
  + rhs_apks=verify-apk/locally-built/normalized-names
  ++ find verify-apk/from-device/normalized-names -maxdepth 1 -mindepth 1 -type f -exec basename '{}' ';'
  + lhs_apk_files='base.apk
  en.apk
  xxhdpi.apk
  arm64_v8a.apk'
  ++ find verify-apk/locally-built/normalized-names -maxdepth 1 -mindepth 1 -type f -exec basename '{}' ';'
  + rhs_apk_files='base.apk
  en.apk
  xxhdpi.apk
  arm64_v8a.apk'
  +++ echo 'base.apk
  en.apk
  xxhdpi.apk
  arm64_v8a.apk'
  ++ sort -u /dev/fd/63 /dev/fd/62
  +++ echo 'base.apk
  en.apk
  xxhdpi.apk
  arm64_v8a.apk'
  + all_apk_files='arm64_v8a.apk
  base.apk
  en.apk
  xxhdpi.apk'
  ++ diff -x resources.arsc -r verify-apk/from-device/comparable verify-apk/locally-built/comparable
  + differences='Binary files verify-apk/from-device/comparable/base/classes2.dex and verify-apk/locally-built/comparable/base/classes2.dex differ
  Binary files verify-apk/from-device/comparable/base/classes.dex and verify-apk/locally-built/comparable/base/classes.dex differ'
  + diff_exit_status=1
  + diff_result=1
  + declare -a aapt_differences
  + for apk_file in $all_apk_files
  + '[' '!' -f verify-apk/from-device/normalized-names/arm64_v8a.apk ']'
  + '[' '!' -f verify-apk/locally-built/normalized-names/arm64_v8a.apk ']'
  + unzip -l verify-apk/from-device/normalized-names/arm64_v8a.apk resources.arsc
  Archive:  verify-apk/from-device/normalized-names/arm64_v8a.apk
    Length      Date    Time    Name
  ---------  ---------- -----   ----
  ---------                     -------
          0                     0 files
  + lhs_contains_resources_exit_code=11
  + unzip -l verify-apk/locally-built/normalized-names/arm64_v8a.apk resources.arsc
  Archive:  verify-apk/locally-built/normalized-names/arm64_v8a.apk
    Length      Date    Time    Name
  ---------  ---------- -----   ----
  ---------                     -------
          0                     0 files
  + rhs_contains_resources_exit_code=11
  + '[' 11 -ne 0 ']'
  + '[' 11 -eq 0 ']'
  + '[' 11 -eq 0 ']'
  + echo 'Skipping aapt2 diff of arm64_v8a.apk as it doesn'\''t contain resources.arsc file'
  Skipping aapt2 diff of arm64_v8a.apk as it doesn't contain resources.arsc file
  + for apk_file in $all_apk_files
  + '[' '!' -f verify-apk/from-device/normalized-names/base.apk ']'
  + '[' '!' -f verify-apk/locally-built/normalized-names/base.apk ']'
  + unzip -l verify-apk/from-device/normalized-names/base.apk resources.arsc
  Archive:  verify-apk/from-device/normalized-names/base.apk
    Length      Date    Time    Name
  ---------  ---------- -----   ----
    124232  1981-01-01 01:01   resources.arsc
  ---------                     -------
    124232                     1 file
  + lhs_contains_resources_exit_code=0
  + unzip -l verify-apk/locally-built/normalized-names/base.apk resources.arsc
  Archive:  verify-apk/locally-built/normalized-names/base.apk
    Length      Date    Time    Name
  ---------  ---------- -----   ----
    124232  1981-01-01 01:01   resources.arsc
  ---------                     -------
    124232                     1 file
  + rhs_contains_resources_exit_code=0
  + '[' 0 -ne 0 ']'
  + '[' 0 -ne 0 ']'
  ++ /home/dannybuntu/Android/Sdk/build-tools/34.0.0/aapt2 diff verify-apk/from-device/normalized-names/base.apk verify-apk/locally-built/normalized-names/base.apk
  + aapt_difference=
  + aapt_diff_exit_status=0
  + '[' '' '!=' '' ']'
  + diff_result=1
  + for apk_file in $all_apk_files
  + '[' '!' -f verify-apk/from-device/normalized-names/en.apk ']'
  + '[' '!' -f verify-apk/locally-built/normalized-names/en.apk ']'
  + unzip -l verify-apk/from-device/normalized-names/en.apk resources.arsc
  Archive:  verify-apk/from-device/normalized-names/en.apk
    Length      Date    Time    Name
  ---------  ---------- -----   ----
      48692  1981-01-01 01:01   resources.arsc
  ---------                     -------
      48692                     1 file
  + lhs_contains_resources_exit_code=0
  + unzip -l verify-apk/locally-built/normalized-names/en.apk resources.arsc
  Archive:  verify-apk/locally-built/normalized-names/en.apk
    Length      Date    Time    Name
  ---------  ---------- -----   ----
      48692  1981-01-01 01:01   resources.arsc
  ---------                     -------
      48692                     1 file
  + rhs_contains_resources_exit_code=0
  + '[' 0 -ne 0 ']'
  + '[' 0 -ne 0 ']'
  ++ /home/dannybuntu/Android/Sdk/build-tools/34.0.0/aapt2 diff verify-apk/from-device/normalized-names/en.apk verify-apk/locally-built/normalized-names/en.apk
  + aapt_difference=
  + aapt_diff_exit_status=0
  + '[' '' '!=' '' ']'
  + diff_result=1
  + for apk_file in $all_apk_files
  + '[' '!' -f verify-apk/from-device/normalized-names/xxhdpi.apk ']'
  + '[' '!' -f verify-apk/locally-built/normalized-names/xxhdpi.apk ']'
  + unzip -l verify-apk/from-device/normalized-names/xxhdpi.apk resources.arsc
  Archive:  verify-apk/from-device/normalized-names/xxhdpi.apk
    Length      Date    Time    Name
  ---------  ---------- -----   ----
      9852  1981-01-01 01:01   resources.arsc
  ---------                     -------
      9852                     1 file
  + lhs_contains_resources_exit_code=0
  + unzip -l verify-apk/locally-built/normalized-names/xxhdpi.apk resources.arsc
  Archive:  verify-apk/locally-built/normalized-names/xxhdpi.apk
    Length      Date    Time    Name
  ---------  ---------- -----   ----
      9852  1981-01-01 01:01   resources.arsc
  ---------                     -------
      9852                     1 file
  + rhs_contains_resources_exit_code=0
  + '[' 0 -ne 0 ']'
  + '[' 0 -ne 0 ']'
  ++ /home/dannybuntu/Android/Sdk/build-tools/34.0.0/aapt2 diff verify-apk/from-device/normalized-names/xxhdpi.apk verify-apk/locally-built/normalized-names/xxhdpi.apk
  + aapt_difference=
  + aapt_diff_exit_status=0
  + '[' '' '!=' '' ']'
  + diff_result=1
  + '[' 1 -eq 0 ']'
  + printf 'The builds are NOT identical!\n\n'
  The builds are NOT identical!

  + printf 'Found differences:\n\n'
  Found differences:

  + echo 'Binary files verify-apk/from-device/comparable/base/classes2.dex and verify-apk/locally-built/comparable/base/classes2.dex differ
  Binary files verify-apk/from-device/comparable/base/classes.dex and verify-apk/locally-built/comparable/base/classes.dex differ'
  Binary files verify-apk/from-device/comparable/base/classes2.dex and verify-apk/locally-built/comparable/base/classes2.dex differ
  Binary files verify-apk/from-device/comparable/base/classes.dex and verify-apk/locally-built/comparable/base/classes.dex differ
  + echo

  + exit 1

  ```

## Asciicast

{% include asciicast %}

## Diffoscope Results

{% include diffoscope-modal.html label='arm64_v8a.apk' url='/assets/diffoscope-results/android/world.bitkey.app/2025.1.1/diffo-arm64.html' %}

{% include diffoscope-modal.html label='base.apk' url='/assets/diffoscope-results/android/world.bitkey.app/2025.1.1/diffo-base.html' %}

{% include diffoscope-modal.html label='xxhdpi.apk' url='/assets/diffoscope-results/android/world.bitkey.app/2025.1.1/diffo-xxhdpi.html' %}

{% include diffoscope-modal.html label='en.apk' url='/assets/diffoscope-results/android/world.bitkey.app/2025.1.1/diffo-en.html' %}

## Analysis 

### diffo-arm64.apk - reproducible

- When comparing the arm64_v8a.apk files, we observe the following: 
  - Signing-related diffs: (stamp-cert-sha256, BNDLTOOL.SF, BNDLTOOL.RSA, MANIFEST.MF)
  - The expected 1 to 2 line difference in AndroidManifest.xml: 
    
    ```
    <meta-data·android:name="com.android.vending.derived.apk.id"·android:value="3"/>	 
	  </application>
    ```

### diffo-base.apk 

- In base.apk, we note: 
  - We note the minor diff in AndroidManifest.xml:

    ```
    android:requiredSplitTypes="base__abi,base__density"·android:splitTypes=""·
    ```
  - We observe `stamp-cert-sha256:·'8'`
  - The most significant diffs we observed in base.apk include those in classes.dex and classes2.dex
    - Checksum Differences
      - The checksum field in classes.dex and classes2.dex files are different.
      - This suggests that the contents of the DEX files are not identical.
    - Signature Differences
      - The signature field is also different, which is expected since the checksum differs.
      - The signature is a cryptographic hash of the file’s contents, so any change in the code or structure will alter it.
    - File Size Differences
      - The file_size of classes.dex in both builds has slight variations (e.g., 9819452 bytes vs. 9819444 bytes).
    - We take a deeper look into the diffs in classes2.dex with:

      ```
      $ unzip -j base.apk classes2.dex -d play-classes2.dex/
      $ unzip -j base.apk classes2.dex -d built-classes2.dex/
      $ dexdump -d play-classes2.dex/classes2.dex > play_classes2.txt
      $ dexdump -d built-classes2.dex/classes2.dex > built_classes2.txt
      $ diffoscope --html diffo-classes2.dex.html built_classes2.txt ../../from-device/normalized-names/play_classes2.txt
      ```
      We come up with: {% include diffoscope-modal.html label='classes2.dex' url='/assets/diffoscope-results/android/world.bitkey.app/2025.1.1/diffo-classes2.dex.html' %} 


<hr />

## Version 2024.74.1 (1)

We used **Bitkey's own [verification script](https://github.com/proto-at-block/bitkey/blob/main/app/verifiable-build/android/verification/verify-android-apk)** to verify the build. This process requires a phone connected via USB to the build computer.

We see in the sub-script [**normalize-apk-content**](https://github.com/proto-at-block/bitkey/blob/2c0dd04b9b434ae1d36747128471b26622f182c6/app/verifiable-build/android/verification/steps/normalize-apk-content#L26) that Bitkey excludes these signing-related files from comparison:

```
incomparable_files=(
    "AndroidManifest.xml"
    "stamp-cert-sha256"
    "BNDLTOOL.RSA"
    "BNDLTOOL.SF"
    "MANIFEST.MF"
    "EMERGENC.RSA"
    "EMERGENC.SF"
)
```

Files matching `\*/res/xml/splits\*.xml` are also excluded as seen in line 32 of **[normalize-apk-content](https://github.com/proto-at-block/bitkey/blob/2c0dd04b9b434ae1d36747128471b26622f182c6/app/verifiable-build/android/verification/steps/normalize-apk-content#L32)**

## Successful Build

[View on asciinema](https://asciinema.org/a/694658)

## Diffs

`$ diff -r from-device/comparable/ locally-built/comparable/`

```
Binary files from-device/comparable/base/assets/dexopt/baseline.prof and locally-built/comparable/base/assets/dexopt/baseline.prof differ
Binary files from-device/comparable/base/classes2.dex and locally-built/comparable/base/classes2.dex differ
Binary files from-device/comparable/base/classes.dex and locally-built/comparable/base/classes.dex differ
Binary files from-device/comparable/base/resources.arsc and locally-built/comparable/base/resources.arsc differ
Binary files from-device/comparable/en/resources.arsc and locally-built/comparable/en/resources.arsc differ
Binary files from-device/comparable/xxhdpi/resources.arsc and locally-built/comparable/xxhdpi/resources.arsc differ
```

### base.apk

```
$ diff -r from-device/comparable/base loc ally-built/comparable/base
Binary files from-device/comparable/base/assets/dexopt/baseline.prof and locally-built/comparable/base/assets/dexopt/baseline.prof differ
Binary files from-device/comparable/base/classes2.dex and locally-built/comparable/base/classes2.dex differ
Binary files from-device/comparable/base/classes.dex and locally-built/comparable/base/classes.dex differ
Binary files from-device/comparable/base/resources.arsc and locally-built/comparable/base/resources.arsc differ 
```

Diffoscope results for {% include diffoscope-modal.html label='classes2.dex' url='/assets/diffoscope-results/android/world.bitkey.app/2024.74.1.1/base/classes2.dex.html' %}

Diffoscope results for {% include diffoscope-modal.html label='classes.dex' url='/assets/diffoscope-results/android/world.bitkey.app/2024.74.1.1/base/classes.dex.html' %}


`$ diff -r from-device/unpacked locally-built/unpacked`

```
Binary files from-device/unpacked/arm64_v8a/AndroidManifest.xml and locally-built/unpacked/arm64_v8a/AndroidManifest.xml differ
Only in from-device/unpacked/arm64_v8a: META-INF
Only in from-device/unpacked/arm64_v8a: stamp-cert-sha256
Binary files from-device/unpacked/base/AndroidManifest.xml and locally-built/unpacked/base/AndroidManifest.xml differ
Binary files from-device/unpacked/base/assets/dexopt/baseline.prof and locally-built/unpacked/base/assets/dexopt/baseline.prof differ
Binary files from-device/unpacked/base/classes2.dex and locally-built/unpacked/base/classes2.dex differ
Binary files from-device/unpacked/base/classes.dex and locally-built/unpacked/base/classes.dex differ
Binary files from-device/unpacked/base/res/xml/splits0.xml and locally-built/unpacked/base/res/xml/splits0.xml differ
Binary files from-device/unpacked/base/resources.arsc and locally-built/unpacked/base/resources.arsc differ
Only in from-device/unpacked/base: stamp-cert-sha256
Binary files from-device/unpacked/en/AndroidManifest.xml and locally-built/unpacked/en/AndroidManifest.xml differ
Only in from-device/unpacked/en: META-INF
Binary files from-device/unpacked/en/resources.arsc and locally-built/unpacked/en/resources.arsc differ
Only in from-device/unpacked/en: stamp-cert-sha256
Binary files from-device/unpacked/xxhdpi/AndroidManifest.xml and locally-built/unpacked/xxhdpi/AndroidManifest.xml differ
Only in from-device/unpacked/xxhdpi: META-INF
Binary files from-device/unpacked/xxhdpi/resources.arsc and locally-built/unpacked/xxhdpi/resources.arsc differ
Only in from-device/unpacked/xxhdpi: stamp-cert-sha256
```

`$ diff -r from-device/normalized-names locally-built/normalized-names`

## Verdict

Similar to the previous version, this version has a verdict of **not verifiable**.

```
Binary files from-device/normalized-names/arm64_v8a.apk and locally-built/normalized-names/arm64_v8a.apk differ
Binary files from-device/normalized-names/base.apk and locally-built/normalized-names/base.apk differ
Binary files from-device/normalized-names/en.apk and locally-built/normalized-names/en.apk differ
Binary files from-device/normalized-names/xxhdpi.apk and locally-built/normalized-names/xxhdpi.apk differ
```

## For archival purposes:

### From device APK checksums:

```
b7d9b4829f6296a7c01ee789e10cf4fad4b1bf514f8f2fafd2844ca129d57c91  base.apk
e81e73a66e18e53eb8be2eadfee9fb901c5554ed1ba5cc92466e04aeeed41d19  split_config.arm64_v8a.apk
221ddbe7796a123c565a002e2bf0356a4d2d4098a8a58f415d25e852d6300d1e  split_config.en.apk
a6a40e592bafb2c58c92491a9fd27107a018cc1add4013754e54f7187a9eb404  split_config.xxhdpi.apk
```

### Locally built APK checksums:

```
75231c06bae15ce51167b68b483b9ffde702c8a7ff0728e37fad8b84e2c32b5b  base-arm64_v8a.apk
6af1a20c2d7b9370f6409ced1a9b33fd441d03d4b47d7b3a901f645b297d9046  base-en.apk
b433801ca76ff773e839ca7a2c0473bc0a729c252c815f2bd4f5ec839331e412  base-master.apk
6f95117f4940e34eaa1dbc151e78b721d1691ccaa01f2b538a11712c37a316ee  base-xxhdpi.apk
