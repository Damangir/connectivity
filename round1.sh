#!/bin/bash -e

# Expected input files
[ ! -f "${DTIDATA:='not set'}" ] && printf "DTIDATA (${DTIDATA}) not found it.\n" >&2 && exit 1
[ ! -f "${BVECS:='not set'}" ] && printf "BVECS (${BVECS}) not found it.\n" >&2 && exit 1
[ ! -f "${BVALS:='not set'}" ] && printf "BVALS (${BVALS}) not found it.\n" >&2 && exit 1

SCRIPT_DIR=$( cd "$( dirname "${0}" )" && pwd )/src

export PROCDIR
export DTIDATA
export BVECS
export BVALS

${stage_runner} ${SCRIPT_DIR}/dti.0.init.sh
${stage_runner} ${SCRIPT_DIR}/dti.1.correct.sh
${stage_runner} ${SCRIPT_DIR}/dti.2.tensor_fit.sh
${stage_runner} ${SCRIPT_DIR}/dti.3.diffusion_parameters.sh
