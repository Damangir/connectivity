#!/bin/bash -e

STAGE=2

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}/common.sh"

# Depends on corrected dti data
if ! [ -e "${TOUCHDIR}/stage.1.done" ]
then
  echo >&2
  exit 1
fi


rm -rf "${TFITDIR}"
mkdir "${TFITDIR}"

run_and_log dtifit ${FSLPRE}dtifit -k "${CORRDIR}/data" -m "${CORRDIR}/nodif_brain_mask" -r "${ORIGDIR}/bvecs" -b "${ORIGDIR}/bvals" -o "${TFITDIR}/df"
