#!/bin/bash -e

STAGE=5

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}/common.sh"

# Depends on corrected dti data
if ! [ -e "${TOUCHDIR}/stage.1.done" ]
then
  echo Stage 1 should be run before >&2
  exit 1
fi

mkdir -p "${TRANDIR}"

if [ -f "${STRDIR}"/volbrain_t1_brain.nii.gz ]
then

run_and_log volbrain.register ${FSLPRE}flirt -in "${CORRDIR}"/nodif_brain.nii.gz -ref "${STRDIR}"/volbrain_t1_brain.nii.gz -omat "${TRANDIR}"/fa2struct.mat -o "${TRANDIR}"/fa2struct.nii.gz
run_and_log volbrain.invrt ${FSLPRE}convert_xfm -omat "${TRANDIR}"/struct2fa.mat -inverse "${TRANDIR}"/fa2struct.mat
run_and_log volbrain.QC ${FSLPRE}slices "${STRDIR}"/volbrain_t1_brain.nii.gz "${TRANDIR}"/fa2struct.nii.gz -o "${QCDIR}"/${STAGE}.fa_on_volbrain.gif

fi
