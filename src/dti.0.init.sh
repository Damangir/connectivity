#!/bin/bash

source "$(cd "$(dirname "$0")/../SSP"&&pwd)/ssp.sh"

# Expected input files
depends_on "${DTIDATA:-'\$DTIDATA'}" "${BVECS:-'\$BVECS'}" "${BVALS:-'\$BVALS'}"

# Expected output files
expects	${ORIGDIR}/original_data.nii.gz ${ORIGDIR}/bvecs ${ORIGDIR}/bvals

# Check if we need to run this stage
check_already_run
remove_expected_output

run_and_log 1.copy_data cp "${DTIDATA}" "${ORIGDIR}/original_data.nii.gz"
run_and_log 2.copy_bvecs cp "${BVECS}" "${ORIGDIR}/bvecs"
run_and_log 3.copy_bvals cp "${BVALS}" "${ORIGDIR}/bvals"

