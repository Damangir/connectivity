#!/bin/bash

source "$(cd "$(dirname "$0")"&&pwd)/common.sh"

# Expected input files
LABELS_SEED="${DATA_DIR}/labels_seed.txt"

depends_on "${LABELS_SEED}"
depends_on "${CORRDIR}/nodif_brain_mask.nii.gz"
depends_on "${TRANSDIR}/t1_to_dti.mat"
depends_on "${TRANSDIR}/dti_to_t1.mat"

(cat ${LABELS_SEED}; echo) | while read -r name
do
	seed_volume="${STR_SEEDDIR}/${name}.nii.gz"
	depends_on "${seed_volume}"
done
# Expected output files

set +e
(cat ${LABELS_SEED}; echo) | while read -r name
do
	track_volume="${TRACKDIR}/${name}.paths.nii.gz"
	log_file="${TRACKDIR}/${name}.probtrackx.log"
	way_total="${TRACKDIR}/${name}.waytotal"
    read -r -d '' REQUIRED_FILES <<- EOM
${REQUIRED_FILES}
${track_volume}
${log_file}
${way_total}
EOM
done
set -e

# Check if we need to run this stage
check_already_run
remove_expected_output

mkdir -p "${TRACKDIR}"

(cat ${LABELS_SEED}; echo) | while read -r name
do
	seed_volume="${STR_SEEDDIR}/${name}.nii.gz"
	track_volume="${name}.paths.nii.gz"
	run_and_log 1.${name}.track_paths ${FSLPRE}probtrackx2 --samples="${DIFPDIR}/dti.bedpostX/merged" \
	                                              --mask="${CORRDIR}/nodif_brain_mask.nii.gz" \
	                                              --xfm="${TRANSDIR}/t1_to_dti.mat" \
	                                              --invxfm="${TRANSDIR}/dti_to_t1.mat" \
	                                              --seed="${seed_volume}" \
	                                              --out="${track_volume}" \
	                                              --dir="${TRACKDIR}" \
	                                              --forcedir \
	                                              --opd \
	                                              --verbose=2 \
	                                              --nsamples=500 \
	                                              --nsteps=200

	run_and_log 2.${name}.rename_log mv "${TRACKDIR}/probtrackx.log" "${TRACKDIR}/${name}.probtrackx.log"
	run_and_log 2.${name}.rename_way mv "${TRACKDIR}/waytotal" "${TRACKDIR}/${name}.waytotal"

done
