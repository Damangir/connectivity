#!/bin/bash

source "$(cd "$(dirname "$0")/../SSP"&&pwd)/ssp.sh"

# Expected input files
depends_on "${CORRDIR}/data.nii.gz" "${CORRDIR}/nodif_brain_mask.nii.gz" "${ORIGDIR}/bvecs" "${ORIGDIR}/bvals"

# Expected output files
expects	${TFITDIR}/df_FA.nii.gz ${TFITDIR}/df_L1.nii.gz ${TFITDIR}/df_L2.nii.gz
expects	${TFITDIR}/df_L3.nii.gz ${TFITDIR}/df_MD.nii.gz ${TFITDIR}/df_MO.nii.gz
expects	${TFITDIR}/df_S0.nii.gz ${TFITDIR}/df_V1.nii.gz ${TFITDIR}/df_V2.nii.gz
expects ${TFITDIR}/df_V3.nii.gz

# Check if we need to run this stage
check_already_run
remove_expected_output

run_and_log dtifit ${FSLPRE}dtifit -k "${CORRDIR}/data" -m "${CORRDIR}/nodif_brain_mask" -r "${ORIGDIR}/bvecs" -b "${ORIGDIR}/bvals" -o "${TFITDIR}/df"
