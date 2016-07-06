#!/bin/bash -e

SCRIPT_DIR=$( cd "$( dirname "${0}" )" && pwd )/src

export PROCDIR

${stage_runner} ${SCRIPT_DIR}/dti.4.tractography.sh
${stage_runner} ${SCRIPT_DIR}/dti.5.register_tractography.sh