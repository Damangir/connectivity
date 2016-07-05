#!/bin/bash -e

# Expected input files
[ ! -f "${FREESURFER:='not set'}" ] && printf "FREESURFER (${FREESURFER}) not found it.\n" >&2 && exit 1

SCRIPT_DIR=$( cd "$( dirname "${0}" )" && pwd )/src

export PROCDIR

mytmpdir=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`
function cleanup {
  rm -rf "$mytmpdir"
}
# register the cleanup function to be called on the EXIT signal
trap cleanup EXIT

tar xzf "${FREESURFER}" -C "$mytmpdir"
export FREESURFER_DIR=$mytmpdir/$(basename "${FREESURFER}" .tar.gz)

${stage_runner} ${SCRIPT_DIR}/structural.0.import_freesurfer.sh
${stage_runner} ${SCRIPT_DIR}/structural.3.import_seed_volume.sh
${stage_runner} ${SCRIPT_DIR}/structural.1.register_to_mni.sh
${stage_runner} ${SCRIPT_DIR}/structural.2.register_to_dti.sh