#!/bin/bash

source "$(cd "$(dirname "$0")"&&pwd)/common.sh"

# Expected input files
depends_on "${ORIGDIR}/original_data.nii.gz" 

# Expected output files
set +e
read -r -d '' REQUIRED_FILES <<- EOM
	${CORRDIR}/data.nii.gz
	${CORRDIR}/nodif.nii.gz
	${CORRDIR}/nodif_brain_mask.nii.gz
EOM
set -e
# Check if we need to run this stage
check_already_run

rm -rf "${CORRDIR}"
mkdir "${CORRDIR}"

cp -r ${PROCDIR}/__Cache_1/* "${CORRDIR}"
exit 0

run_and_log 1.eddy_correct ${FSLPRE}eddy_correct "${ORIGDIR}/original_data.nii.gz" "${CORRDIR}/data" 0 
run_and_log 2.roi ${FSLPRE}fslroi "${CORRDIR}/data" "${CORRDIR}/nodif" 0 1
run_and_log 3.bet ${FSLPRE}bet "${CORRDIR}/nodif" "${CORRDIR}/nodif_brain"  -f 0.3 -g 0 -m
run_and_log 4.QC ${FSLPRE}slices "${CORRDIR}/nodif" "${CORRDIR}/nodif_brain_mask" -o "${QCDIR}"/${STAGE}.nodif_brain_mask.gif