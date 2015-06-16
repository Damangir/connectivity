#!/bin/bash -e

STAGE=1

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}/common.sh"

if ! [ -e "${TOUCHDIR}/stage.0.done" ]
then
  echo >&2
  exit 1
fi

rm -rf "${CORRDIR}"
mkdir "${CORRDIR}"

run_and_log 1.eddy_correct ${FSLPRE}eddy_correct "${ORIGDIR}/original_data.nii.gz" "${CORRDIR}/data" 0 
run_and_log 2.bet ${FSLPRE}bet "${CORRDIR}/data" "${CORRDIR}/nodif_brain"  -f 0.3 -g 0 -n -m