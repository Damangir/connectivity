#!/bin/bash

source "$(cd "$(dirname "$0")/../SSP"&&pwd)/ssp.sh"

# Expected input files
LABELS_SEED="${DATA_DIR}/labels_seed.txt"
WHEIGHT_IMG="${STR_IMPORTDIR}/flair.wml_mask.nii.gz"
PVAL_IMG="${STR_IMPORTDIR}/flair.pval.nii.gz"

depends_on "${LABELS_SEED}" "${WHEIGHT_IMG}" "${PVAL_IMG}"

grep . ${LABELS_SEED} | while read -r name
do
	track_volume="${ATLAS_ON_FLAIR}/${name}.paths.nii.gz"
	depends_on "${track_volume}"
done

report_tracts=${REPORTDIR}/wml.tract.txt
report_vols=${REPORTDIR}/wml.vol.txt

expects ${report_tracts} ${report_vols}

# Check if we need to run this stage
check_already_run
remove_expected_output


WEIGHTED_VOLUME=${CON_TEMPDIR}/weighted_volume.value
function measure_volume {
  ${FSLPRE}fslstats "${weighted}"  -M -V | awk '{ printf "%f\n", $1 * $3}' >${WEIGHTED_VOLUME}
}

>${report_tracts}
grep . ${LABELS_SEED} | while read -r name
do
	track_volume="${ATLAS_ON_FLAIR}/${name}.paths.nii.gz"
	weighted="${CON_TEMPDIR}/weighted.${name}.paths.nii.gz"
	run_and_log 0.${name}.weight cp "${track_volume}" "${weighted}"
	run_and_log 0.${name}.report measure_volume
	max_weight=$(cat "${WEIGHTED_VOLUME}")
	run_and_log 1.${name}.weight ${FSLPRE}fslmaths "${WHEIGHT_IMG}" -mul "${track_volume}" "${weighted}"
	run_and_log 1.${name}.report measure_volume
	mask_weight=$(cat "${WEIGHTED_VOLUME}")
	run_and_log 2.${name}.weight ${FSLPRE}fslmaths "${PVAL_IMG}" -thr 0.85 -mul "${track_volume}" "${weighted}"
	run_and_log 2.${name}.report measure_volume
	pval_weight=$(cat "${WEIGHTED_VOLUME}")
	printf "%s %s %s %s\n" "${name}" "$max_weight" "$mask_weight" "$pval_weight" >> ${report_tracts}
done

weighted="${CON_TEMPDIR}/weighted.nii.gz"
run_and_log 3.weight cp "${WHEIGHT_IMG}" "${weighted}"
run_and_log 3.report measure_volume
cat "${WEIGHTED_VOLUME}" > ${report_vols}
run_and_log 4.weight ${FSLPRE}fslmaths "${PVAL_IMG}" -thr 0.85 "${weighted}"
run_and_log 4.report measure_volume
cat "${WEIGHTED_VOLUME}" >> ${report_vols}
