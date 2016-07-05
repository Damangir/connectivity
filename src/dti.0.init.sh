#!/bin/bash

source "$(cd "$(dirname "$0")"&&pwd)/common.sh"

# Expected input files
depends_on "${DTIDATA:-'\$DTIDATA'}" "${BVECS:-'\$BVECS'}" "${BVALS:-'\$BVALS'}"

# Expected output files
set +e
read -r -d '' REQUIRED_FILES <<- EOM
	${ORIGDIR}/original_data.nii.gz
	${ORIGDIR}/bvecs
	${ORIGDIR}/bvals
EOM
set -e

# Check if we need to run this stage
check_already_run
remove_expected_output


mkdir "${ORIGDIR}"

run_and_log 1.copy_data cp "${DTIDATA}" "${ORIGDIR}/original_data.nii.gz"
run_and_log 2.copy_bvecs cp "${BVECS}" "${ORIGDIR}/bvecs"
run_and_log 3.copy_bvals cp "${BVALS}" "${ORIGDIR}/bvals"

