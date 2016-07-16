#!/bin/bash

source "$(cd "$(dirname "$0")"&&pwd)/common.sh"

# ATLAS_DIR is the directory where the atlas of track reside.
# ATLAS_DIR should be exported before

# Expected input files
LABELS_SEED="${DATA_DIR}/labels_seed.txt"

depends_on "${LABELS_SEED}" "${TRANSDIR}/mni_to_t1_coef.nii.gz" "${STR_IMPORTDIR}/flair.normalized.nii.gz" "${TRANSDIR}/t1_to_flair.mat"
grep . ${LABELS_SEED} | while read -r name
do
	mni_track_volume="${ATLAS_DIR}/${name}.paths.nii.gz"
	depends_on "${mni_track_volume}"
done
# Expected output files

set +e
grep . ${LABELS_SEED} | while read -r name
do
	track_volume="${ATLAS_ON_FLAIR}/${name}.paths.nii.gz"
    read -r -d '' REQUIRED_FILES <<- EOM
${REQUIRED_FILES}
${track_volume}
EOM
done
set -e

# Check if we need to run this stage
check_already_run
remove_expected_output

mkdir -p "${ATLAS_ON_FLAIR}"

grep . ${LABELS_SEED} | while read -r name
do
	track_volume="${ATLAS_ON_FLAIR}/${name}.paths.nii.gz"
	mni_track_volume="${ATLAS_DIR}/${name}.paths.nii.gz"
	run_and_log 1.${name}.register_paths ${FSLPRE}applywarp --ref="${STR_IMPORTDIR}/flair.normalized.nii.gz" \
                                                            --in="${mni_track_volume}" \
                                                            --out="${track_volume}" \
                                                            --warp="${TRANSDIR}/mni_to_t1_coef.nii.gz" \
                                                            --postmat="${TRANSDIR}/t1_to_flair.mat"



done
