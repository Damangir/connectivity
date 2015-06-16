#!/bin/bash -e

STAGE=0

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}/common.sh"

if ! [ -f "${DTIDATA}" ]
then
echo "${DTIDATA} is not a valid input DTI file" >&2
exit 1
fi

if ! [ -f "${BVECS}" ]
then
echo "${BVECS} is not a valid file for bvals" >&2
exit 1
fi

if ! [ -f "${BVALS}" ]
then
echo "${BVALS} is not a valid file for bvals" >&2
exit 1
fi



rm -rf "${ORIGDIR}"
mkdir "${ORIGDIR}"

run_and_log 1.copy_data cp "${DTIDATA}" "${ORIGDIR}/original_data.nii.gz"
run_and_log 2.copy_bvecs cp "${BVECS}" "${ORIGDIR}/bvecs"
run_and_log 3.copy_bvals cp "${BVALS}" "${ORIGDIR}/bvals"

