#!/bin/bash
# zowe_operations.sh

# Check if directory exists, create if it doesn't
if ! zowe zos-files list uss-files "/z/$LC_USERNAME/cobolcheck" &>/dev/null; then
  echo "Directory does not exist. Creating it..."
  zowe zos-files create uss-directory /z/$LC_USERNAME/cobolcheck
else
  echo "Directory already exists."
fi

# Upload files
  zowe zos-files upload dir-to-uss "./cobol-check" "/z/$LC_USERNAME/cobolcheck" --recursive \
        --binary-files "cobol-check-0.2.19.jar"

# Verify upload
echo "Verifying upload:"
zowe zos-files list uss-files "/z/$LC_USERNAME/cobolcheck"
