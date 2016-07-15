#!/bin/bash

source "$(cd "$(dirname "$0")"&&pwd)/common.sh"

# ATLAS_DIR is the directory where the atlas of track reside.
# ATLAS_DIR should be exported before

# Expected input files
LABELS_SEED="${DATA_DIR}/labels_seed.txt"

depends_on "${LABELS_SEED}" "${TRANSDIR}/mni_to_t1_coef.nii.gz" "${CORRDIR}/nodif.nii.gz" "${TRANSDIR}/t1_to_dti.mat"
(cat ${LABELS_SEED}; echo) | while read -r name
do
	mni_track_volume="${ATLAS_DIR}/${name}.paths.nii.gz"
	depends_on "${mni_track_volume}"
done
# Expected output files

set +e
(cat ${LABELS_SEED}; echo) | while read -r name
do
	track_volume="${ATLAS_ON_DTI}/${name}.paths.nii.gz"
    read -r -d '' REQUIRED_FILES <<- EOM
${REQUIRED_FILES}
${track_volume}
EOM
done
set -e

# Check if we need to run this stage
check_already_run
remove_expected_output

mkdir -p "${ATLAS_ON_DTI}"

(cat ${LABELS_SEED}; echo) | while read -r name
do
	track_volume="${ATLAS_ON_DTI}/${name}.paths.nii.gz"
	mni_track_volume="${ATLAS_DIR}/${name}.paths.nii.gz"
	run_and_log 1.${name}.register_paths ${FSLPRE}applywarp --ref="${CORRDIR}/nodif.nii.gz" \
                                                            --in="${mni_track_volume}" \
                                                            --out="${track_volume}" \
                                                            --warp="${TRANSDIR}/mni_to_t1_coef.nii.gz"
                                                            --postmat="${TRANSDIR}/t1_to_dti.mat"



done < "${LABELS_SEED}"
