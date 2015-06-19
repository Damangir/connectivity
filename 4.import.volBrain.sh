#!/bin/bash -e

STAGE=4.vol

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}/common.sh"

if ! [ -d "${VOLBRAIN}" ]
then
echo "${VOLBRAIN} is not a valid directory" >&2
exit 1
fi

mkdir -p "${STRDIR}"

run_and_log 1.copy_t1 cp "${VOLBRAIN}"/native_n_mmni_* "${STRDIR}/volbrain_t1.nii.gz"
run_and_log 2.copy_label cp "${VOLBRAIN}"/native_lab_n_mmni_* "${STRDIR}/volbrain_labels.nii.gz"
run_and_log 3.copy_mask cp "${VOLBRAIN}"/native_mask_n_mmni_* "${STRDIR}/volbrain_t1_brain_mask.nii.gz"
run_and_log 4.mask_brain ${FSLPRE}fslmaths "${STRDIR}/volbrain_t1.nii.gz" -mas "${STRDIR}/volbrain_t1_brain_mask.nii.gz" "${STRDIR}/volbrain_t1_brain.nii.gz"

