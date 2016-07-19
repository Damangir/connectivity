#!/bin/bash

source "$(cd "$(dirname "$0")"&&pwd)/common.sh"

# Expected input files
LABELS_SEED="${DATA_DIR}/labels_seed.txt"
WHEIGHT_IMG="${STR_IMPORTDIR}/flair.pval.nii.gz"

depends_on "${LABELS_SEED}" "${WHEIGHT_IMG}"

grep . ${LABELS_SEED} | while read -r name
do
	track_volume="${ATLAS_ON_FLAIR}/${name}.paths.nii.gz"
	depends_on "${track_volume}"
done

set +e
read -r -d '' REQUIRED_FILES <<- EOM
	${REPORTDIR}/wml.txt
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

>${REPORTDIR}/wml.txt
grep . ${LABELS_SEED} | while read -r name
do
	track_volume="${ATLAS_ON_FLAIR}/${name}.paths.nii.gz"
	weighted="${CON_TEMPDIR}/weighted.${name}.paths.nii.gz"
	run_and_log 1.${name}.weight ${FSLPRE}fslmaths "${WHEIGHT_IMG}" -thr 0.85 -mul "${track_volume}" "${weighted}"
	run_and_log 2.${name}.report measure_volume
	printf "%s %s\n" "${name}" "$(cat "${WEIGHTED_VOLUME}")" >> ${REPORTDIR}/wml.txt
done
