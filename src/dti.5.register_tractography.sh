#!/bin/bash

source "$(cd "$(dirname "$0")"&&pwd)/common.sh"

# Expected input files
LABELS_SEED="${DATA_DIR}/labels_seed.txt"

depends_on "${LABELS_SEED}" "${TRANSDIR}/t1_to_mni_coef.nii.gz"
(cat ${LABELS_SEED}; echo) | while read -r name
do
	track_volume="${TRACKDIR}/${name}.paths.nii.gz"
	depends_on "${track_volume}"
done < "${LABELS_SEED}"
# Expected output files

set +e
(cat ${LABELS_SEED}; echo) | while read -r name
do
	mni_track_volume="${MNI_TRACKDIR}/${name}.paths.nii.gz"
    read -r -d '' REQUIRED_FILES <<- EOM
${REQUIRED_FILES}
${mni_track_volume}
EOM
done < "${LABELS_SEED}"
set -e

# Check if we need to run this stage
check_already_run
remove_expected_output

mkdir -p "${MNI_TRACKDIR}"

(cat ${LABELS_SEED}; echo) | while read -r name
do
	track_volume="${TRACKDIR}/${name}.paths.nii.gz"
	mni_track_volume="${MNI_TRACKDIR}/${name}.paths.nii.gz"
	run_and_log 1.${name}.register_paths ${FSLPRE}applywarp --ref="${MNIDIR}/MNI152_T1_2mm_brain.nii.gz" \
                                                            --in="${track_volume}" \
                                                            --out="${mni_track_volume}" \
                                                            --warp="${TRANSDIR}/t1_to_mni_coef.nii.gz"

done < "${LABELS_SEED}"
