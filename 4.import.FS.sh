#!/bin/bash -e

STAGE=4.fs

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}/common.sh"

if ! [ -d "${FSDIR}" ]
then
echo "${FSDIR} is not a valid input DTI file" >&2
exit 1
fi


rm -rf "${ORIGDIR}"
mkdir "${ORIGDIR}"

run_and_log 1.copy_data cp "${DTIDATA}" "${ORIGDIR}/original_data.nii.gz"
run_and_log 2.copy_bvecs cp "${BVECS}" "${ORIGDIR}/bvecs"
run_and_log 3.copy_bvals cp "${BVALS}" "${ORIGDIR}/bvals"

