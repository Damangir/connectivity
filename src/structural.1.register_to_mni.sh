#!/bin/bash

source "$(cd "$(dirname "$0")"&&pwd)/common.sh"

MNIDIR=${FSLDIR}/data/standard
# Expected input files
depends_on "${STR_IMPORTDIR}/t1.nii.gz" "${STR_IMPORTDIR}/t1.brain.nii.gz" "${MNIDIR}/MNI152_T1_2mm_brain.nii.gz" "${MNIDIR}/MNI152_T1_2mm.nii.gz" "${MNIDIR}/MNI152_T1_2mm_brain_mask_dil.nii.gz"

# Expected output files
set +e
read -r -d '' REQUIRED_FILES <<- EOM
	${TRANSDIR}/t1_to_mni.mat
	${TRANSDIR}/coefficients.nii.gz
	${STR_REGDIR}/t1.in.mni.nii.gz
	${STR_REGDIR}/t1_to_mni.warp.nii.gz
EOM
set -e

# Check if we need to run this stage
check_already_run
remove_expected_output

mkdir -p "${STR_REGDIR}"
mkdir -p "${TRANSDIR}"

run_and_log 1.linear_registration ${FSLPRE}flirt -ref "${MNIDIR}/MNI152_T1_2mm_brain.nii.gz" -in ${STR_IMPORTDIR}/t1.brain.nii.gz -omat "${TRANSDIR}/t1_to_mni.mat" -out "${STR_REGDIR}/t1_to_mni.lin.nii.gz"

run_and_log 2.QC_linear ${FSLPRE}slices "${MNIDIR}/MNI152_T1_2mm.nii.gz" "${STR_REGDIR}/t1_to_mni.lin.nii.gz" -o "${QCDIR}/${STAGE}.t1_on_mni_lin.gif"

run_and_log 3.nonlinear_registration ${FSLPRE}fnirt --ref="${MNIDIR}/MNI152_T1_2mm_brain.nii.gz" --in=${STR_IMPORTDIR}/t1.nii.gz --aff="${TRANSDIR}/t1_to_mni.mat" --cout="${TRANSDIR}/coefficients.nii.gz" --iout="${STR_REGDIR}/t1.in.mni.nii.gz" --fout="${STR_REGDIR}/t1_to_mni.warp.nii.gz"  --config=T1_2_MNI152_2mm 

run_and_log 4.QC_nonlinear ${FSLPRE}slices "${STR_REGDIR}/t1.in.mni.nii.gz" "${MNIDIR}/MNI152_T1_2mm.nii.gz" -o "${QCDIR}/${STAGE}.t1_on_mni.gif"
