#!/bin/bash -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

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

export PROCDIR
export DTIDATA
export BVECS
export BVALS

${DIR}/0.init.sh
${DIR}/1.correct.sh
${DIR}/2.tensor_fit.sh
${DIR}/3.diffusion_parameters.sh
