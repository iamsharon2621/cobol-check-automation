#!/bin/bash
# mainframe_operations.sh

# Set up environment
export PATH=$PATH:/usr/lpp/java/J8.0_64/bin
export JAVA_HOME=/usr/lpp/java/J8.0_64
export PATH=$PATH:/usr/lpp/zowe/cli/node/bin

# Check Java availability
java -version

# Set ZOWE_USERNAME
# ZOWE_USERNAME="Z80922" # Replace with the actual username

# Change to the cobolcheck directory
cd cobol-check
echo "Changed to $(pwd)"
ls -al

# Make cobolcheck executable
chmod +x cobolcheck
echo "Made cobolcheck executable"

# Make script in scripts directory executable
cd scripts
chmod +x linux_gnucobol_run_tests
echo "Made linux_gnucobol_run_tests executable"
cd ..

# Function to run cobolcheck and copy files
run_cobolcheck() {
  program=$1
  echo "Running cobolcheck for $program"

  # Run cobolcheck, but don't exit if it fails
  ./cobolcheck -p $program
  echo "Cobolcheck execution completed for $program (exceptions may have occurred)"

  # Define the correct path where CobolCheck puts the generated test file
  GENERATED_CBL="./cobol-check/testruns/CC##99.CBL"
  # Define the correct path where JCL file located
  PGM_JCL="../$program.JCL"

  # Check if CC##99.CBL was created, regardless of cobolcheck exit status
  if [ -f "${GENERATED_CBL}" ]; then
    # Copy to the MVS dataset
    if cp ${GENERATED_CBL} "//'${ZOWE_USERNAME}.CBL($program)'"; then
      echo "Copied CC##99.CBL to ${ZOWE_USERNAME}.CBL($program)"
    else
      echo "Failed to copy CC##99.CBL to ${ZOWE_USERNAME}.CBL($program)"
    fi
  else
    echo "CC##99.CBL not found for $program"
  fi

  # Copy the JCL file if it exists
  if [ -f "${PGM_JCL}" ]; then
    if cp ${PGM_JCL} "//'${ZOWE_USERNAME}.JCL($program)'"; then
      echo "Copied ${PGM_JCL} to ${ZOWE_USERNAME}.JCL($program)"
    else
      echo "Failed to copy ${PGM_JCL} to ${ZOWE_USERNAME}.JCL($program)"
    fi
  else
    echo "${PGM_JCL} not found"
  fi
}

# Run for each program
for program in NUMBERS EMPPAY DEPTPAY; do
  run_cobolcheck $program
done

echo "Mainframe operations completed"
