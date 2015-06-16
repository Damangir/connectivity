#!/bin/bash -e

STAGE=3

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}/common.sh"

# Depends on corrected dti data
if ! [ -e "${TOUCHDIR}/stage.1.done" ]
then
  echo >&2
  exit 1
fi

rm -rf "${DIFPDIR}"
mkdir "${DIFPDIR}"

mkdir "${DIFPDIR}/dti"

run_and_log 1.organize.files cp "${CORRDIR}"/data.nii.gz "${CORRDIR}"/nodif_brain_mask.nii.gz "${ORIGDIR}"/bvals "${ORIGDIR}"/bvecs "${DIFPDIR}/dti"

run_and_log 2.bedpostx ${FSLPRE}bedpostx "${DIFPDIR}/dti" --nf=2 --fudge=1  --bi=1000 --model=2
