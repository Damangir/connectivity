#!/bin/bash

source "$(cd "$(dirname "$0")/../SSP"&&pwd)/ssp.sh"

# Expected input files
LABELS_SEED="${DATA_DIR}/labels_seed.txt"
MNI_BRAIN="${MNIDIR}/MNI152_T1_2mm_brain.nii.gz"
depends_on "${LABELS_SEED}" "${MNI_BRAIN}" "${TRANSDIR}/t1_to_mni_coef.nii.gz"

grep . ${LABELS_SEED} | while read -r name
do
	track_volume="${TRACKDIR}/${name}.paths.nii.gz"
	depends_on "${track_volume}"
done
# Expected output files

grep . ${LABELS_SEED} | while read -r name
do
	mni_track_volume="${MNI_TRACKDIR}/${name}.paths.nii.gz"
    expects ${mni_track_volume}
done

# Check if we need to run this stage
check_already_run
remove_expected_output

grep . ${LABELS_SEED} | while read -r name
do
	track_volume="${TRACKDIR}/${name}.paths.nii.gz"
	mni_track_volume="${MNI_TRACKDIR}/${name}.paths.nii.gz"
	run_and_log 1.${name}.register_paths ${FSLPRE}applywarp --ref="${MNI_BRAIN}" \
                                                            --in="${track_volume}" \
                                                            --out="${mni_track_volume}" \
                                                            --warp="${TRANSDIR}/t1_to_mni_coef.nii.gz"

done
