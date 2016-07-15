#!/bin/bash

source "$(cd "$(dirname "$0")"&&pwd)/common.sh"

# Expected input files
depends_on "${STR_IMPORTDIR}/t1.nii.gz" "${STR_IMPORTDIR}/flair.normalized.nii.gz"

# Expected output files
set +e
read -r -d '' REQUIRED_FILES <<- EOM
	${TRANSDIR}/t1_to_flair.mat
	${TRANSDIR}/flair_to_t1.mat
EOM
set -e

# Check if we need to run this stage
check_already_run
remove_expected_output

mkdir -p "${TRANSDIR}"

run_and_log 1.linear_registration ${FSLPRE}flirt -ref "${STR_IMPORTDIR}/t1.brain.nii.gz" -in "${STR_IMPORTDIR}/flair.normalized.nii.gz" -dof 6 -omat "${TRANSDIR}/flair_to_t1.mat"  -out "${STR_REGDIR}/flair_to_t1.lin.nii.gz" 
run_and_log 2.invert ${FSLPRE}convert_xfm -omat "${TRANSDIR}/t1_to_flair.mat" -inverse "${TRANSDIR}/flair_to_t1.mat"
run_and_log 3.QC_linear ${FSLPRE}slices "${STR_IMPORTDIR}/t1.nii.gz" "${STR_REGDIR}/flair_to_t1.lin.nii.gz" -o "${QCDIR}/${STAGE}.flair_on_t1_lin.gif"



