#!/bin/bash -e

# Expected input files
[ ! -f "${FREESURFER_DIR:='not set'}" ] && printf "FREESURFER_DIR (${FREESURFER_DIR}) not found it.\n" >&2 && exit 1

SCRIPT_DIR=$( cd "$( dirname "${0}" )" && pwd )/src

export PROCDIR
export FREESURFER_DIR

${stage_runner} ${SCRIPT_DIR}/structural.0.import_freesurfer.sh
${stage_runner} ${SCRIPT_DIR}/structural.3.import_seed_volume.sh
${stage_runner} ${SCRIPT_DIR}/structural.1.register_to_mni.sh
${stage_runner} ${SCRIPT_DIR}/structural.2.register_to_dti.sh