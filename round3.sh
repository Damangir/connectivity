#!/bin/bash -e

SCRIPT_DIR=$( cd "$( dirname "${0}" )" && pwd )/src

${stage_runner} ${SCRIPT_DIR}/dti.4.tractography.sh
