#!/bin/bash

source "$(cd "$(dirname "$0")"&&pwd)/common.sh"

# Expected input files
depends_on "${CORRDIR}/data.nii.gz" "${CORRDIR}/nodif_brain_mask.nii.gz" "${ORIGDIR}/bvecs" "${ORIGDIR}/bvals"

# Expected output files
set +e
read -r -d '' REQUIRED_FILES <<- EOM
	${TFITDIR}/df_FA.nii.gz
	${TFITDIR}/df_L1.nii.gz
	${TFITDIR}/df_L2.nii.gz
	${TFITDIR}/df_L3.nii.gz
	${TFITDIR}/df_MD.nii.gz
	${TFITDIR}/df_MO.nii.gz
	${TFITDIR}/df_S0.nii.gz
	${TFITDIR}/df_V1.nii.gz
	${TFITDIR}/df_V2.nii.gz
	${TFITDIR}/df_V3.nii.gz
EOM
set -e

# Check if we need to run this stage
check_already_run
remove_expected_output

mkdir "${TFITDIR}"

run_and_log dtifit ${FSLPRE}dtifit -k "${CORRDIR}/data" -m "${CORRDIR}/nodif_brain_mask" -r "${ORIGDIR}/bvecs" -b "${ORIGDIR}/bvals" -o "${TFITDIR}/df"
