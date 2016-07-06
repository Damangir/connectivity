#!/bin/bash

source "$(cd "$(dirname "$0")"&&pwd)/common.sh"

# Expected input files
FREESURFER_DIR="${FREESURFER_DIR:-'\$FREESURFER_DIR'}"
LABELS_ASEG="${DATA_DIR}/labels_aseg.txt"
LABELS_PARC="${DATA_DIR}/labels_parc.txt"

depends_on "${LABELS_ASEG}" "${LABELS_PARC}"
depends_on "${FREESURFER_DIR}/mri/rawavg.mgz" "${FREESURFER_DIR}/mri/aseg.mgz" "${STR_IMPORTDIR}/t1.aseg.nii.gz"

# Expected output files
set +e
read -r -d '' REQUIRED_FILES <<- EOM
EOM
for hemi in lh rh
do
    for lab in $(cat "${LABELS_PARC}")
    do
    	vol="${STR_SEEDDIR}/$hemi.$lab.nii.gz"
		read -r -d '' REQUIRED_FILES <<- EOM
${REQUIRED_FILES}
${vol}
EOM
	done
done

(cat ${LABELS_ASEG}; echo) | while read -r index name
do
    vol="${STR_SEEDDIR}/$name.nii.gz"
    read -r -d '' REQUIRED_FILES <<- EOM
${REQUIRED_FILES}
${vol}
EOM
done
set -e

# Check if we need to run this stage
check_already_run
remove_expected_output

mkdir -p "${STR_IMPORTDIR}"
mkdir -p "${STR_SEEDDIR}"

for hemi in lh rh
do
	run_and_log 0.${hemi}.extract_labels mri_annotation2label --subject $(basename "${FREESURFER_DIR}") --hemi ${hemi} --outdir "${CON_TEMPDIR}/labels" --sd $(dirname "${FREESURFER_DIR}")

    for lab in $(cat "${LABELS_PARC}")
    do
        label="${CON_TEMPDIR}/labels/$hemi.$lab.label"
        vol="${STR_SEEDDIR}/$hemi.$lab.nii.gz"
        run_and_log 1.$hemi.$lab.extract_volume mri_label2vol \
            --label "${label}" \
            --temp "${FREESURFER_DIR}/mri/rawavg.mgz" \
            --o "${vol}" \
            --identity \
            --fillthresh 0.5
        run_and_log 2.$hemi.$lab.reorient_volume ${FSLPRE}fslreorient2std "${vol}" "${vol}"
    done
done

(cat ${LABELS_ASEG}; echo) | while read -r index name
do
    vol="${STR_SEEDDIR}/$name.nii.gz"
    run_and_log 3.${name}.extract_volume ${FSLPRE}fslmaths "${STR_IMPORTDIR}/t1.aseg.nii.gz" -thr ${index} -uthr ${index} "${vol}"
done
