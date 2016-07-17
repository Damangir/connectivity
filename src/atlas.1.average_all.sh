#!/bin/bash

source "$(cd "$(dirname "$0")"&&pwd)/common.sh"

# Expected input files
LABELS_SEED="${DATA_DIR}/labels_seed.txt"

set -e
depends_on "${LABELS_SEED}"
depends_on "${ATLAS_LIST}"

function get_path_for_subject {
	(
		PROCDIR=$1
		source "${SCRIPT_DIR}/directory_structure.sh"
		eval echo "$2"
	)
}
grep . ${LABELS_SEED} | while read -r name
do
	grep . ${ATLAS_LIST} | while read -r subj_procdir
	do
		mni_track_volume=$(get_path_for_subject "${subj_procdir}" '${MNI_TRACKDIR}'"/${name}.paths.nii.gz")
		depends_on "${mni_track_volume}"
	done
done
# Expected output files

set +e
grep . ${LABELS_SEED} | while read -r name
do
	atlas_track_volume="${PROCDIR}/${name}.paths.nii.gz"
  read -r -d '' REQUIRED_FILES <<- EOM
${REQUIRED_FILES}
${atlas_track_volume}
EOM
done
set -e

# Check if we need to run this stage
check_already_run
remove_expected_output

grep . ${LABELS_SEED} | while read -r name
do
	atlas_track_volume="${PROCDIR}/${name}.paths.nii.gz"
	fslmaths_param=
	count=0
	while read -r subj_procdir
	do
		mni_track_volume=$(get_path_for_subject "${subj_procdir}" '${MNI_TRACKDIR}'"/${name}.paths.nii.gz")
		fslmaths_param+=" ${mni_track_volume}"
	    (( count++ ))&&:
	done < <(grep . ${ATLAS_LIST})
	fslmaths_param="$(join ' -add ' ${fslmaths_param}) -div ${count} ${atlas_track_volume}"
	run_and_log 1.averaging.${name} ${FSLPRE}fslmaths $fslmaths_param
done
