#!/bin/bash

source "$(cd "$(dirname "$0")"&&pwd)/common.sh"

# Expected input files
LABELS_SEED="${DATA_DIR}/labels_seed.txt"
WHEIGHT_IMG="${STR_IMPORTDIR}/flair.wml_mask.nii.gz"

depends_on "${LABELS_SEED}" "${WHEIGHT_IMG}"

grep . ${LABELS_SEED} | while read -r name
do
	track_volume="${ATLAS_ON_FLAIR}/${name}.paths.nii.gz"
	depends_on "${track_volume}"
done

report_name=${REPORTDIR}/wml.txt
set +e
read -r -d '' REQUIRED_FILES <<- EOM
	${report_name}
EOM
set -e

# Check if we need to run this stage
check_already_run
remove_expected_output

mkdir -p "${REPORTDIR}"

WEIGHTED_VOLUME=${CON_TEMPDIR}/weighted_volume.value
function measure_volume {
  printf "${FSLPRE}fslstats \"${weighted}\"  -M -V | awk '{ printf "%f\n", $1 * $3}'\n"
  ${FSLPRE}fslstats "${weighted}"  -M -V | awk '{ printf "%f\n", $1 * $3}' >${WEIGHTED_VOLUME}
}

>${report_name}
grep . ${LABELS_SEED} | while read -r name
do
	track_volume="${ATLAS_ON_FLAIR}/${name}.paths.nii.gz"
	weighted="${CON_TEMPDIR}/weighted.${name}.paths.nii.gz"
	run_and_log 0.${name}.weight ${FSLPRE}fslmaths "${track_volume}" "${weighted}"
	run_and_log 0.${name}.report measure_volume
	max_weight=$(cat "${WEIGHTED_VOLUME}")
	run_and_log 1.${name}.weight ${FSLPRE}fslmaths "${WHEIGHT_IMG}" -mul "${track_volume}" "${weighted}"
	run_and_log 2.${name}.report measure_volume
	this_weight=$(cat "${WEIGHTED_VOLUME}")
	relative_weight=$(printf "$this_weight $max_weight" | awk '{printf "%f\n", $2 + 0 == 0 ? 0 : $1 / $2}' )
	printf "%s %s\n" "${name}" "$relative_weight" >> ${report_name}
done
