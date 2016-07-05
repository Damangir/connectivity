#!/bin/bash

source "$(cd "$(dirname "$0")"&&pwd)/common.sh"

# Expected input files
FREESURFER_DIR="${FREESURFER_DIR:-'\$FREESURFER_DIR'}"
depends_on "${FREESURFER_DIR}/mri/rawavg.mgz" "${FREESURFER_DIR}/mri/aseg.mgz"

# Expected output files
set +e
read -r -d '' REQUIRED_FILES <<- EOM
	${STR_IMPORTDIR}/t1.nii.gz
	${STR_IMPORTDIR}/t1.brain.nii.gz
	${STR_IMPORTDIR}/t1.aseg.nii.gz
EOM
set -e

# Check if we need to run this stage
check_already_run
remove_expected_output

mkdir -p "${STR_IMPORTDIR}"


run_and_log 1.import_original_t1 mri_convert "${FREESURFER_DIR}/mri/rawavg.mgz" "${STR_IMPORTDIR}/t1.nii.gz"
run_and_log 2.import_aseg mri_label2vol --seg "${FREESURFER_DIR}/mri/aseg.mgz" --temp "${FREESURFER_DIR}/mri/rawavg.mgz" --o "${STR_IMPORTDIR}/t1.aseg.nii.gz" --regheader "${FREESURFER_DIR}/mri/aseg.mgz"
run_and_log 3.create_brain ${FSLPRE}fslmaths "${STR_IMPORTDIR}/t1.nii.gz" -mas "${STR_IMPORTDIR}/t1.aseg.nii.gz" "${STR_IMPORTDIR}/t1.brain.nii.gz"

run_and_log 4.reorient_t1 ${FSLPRE}fslreorient2std "${STR_IMPORTDIR}/t1.nii.gz" "${STR_IMPORTDIR}/t1.nii.gz"
run_and_log 5.reorient_t1_brain ${FSLPRE}fslreorient2std "${STR_IMPORTDIR}/t1.brain.nii.gz" "${STR_IMPORTDIR}/t1.brain.nii.gz"
run_and_log 6.reorient_t1_aseg ${FSLPRE}fslreorient2std "${STR_IMPORTDIR}/t1.aseg.nii.gz" "${STR_IMPORTDIR}/t1.aseg.nii.gz"
