#!/bin/bash

source "$(cd "$(dirname "$0")"&&pwd)/common.sh"

# Expected input files
depends_on "${CORRDIR}"/data.nii.gz "${CORRDIR}"/nodif_brain_mask.nii.gz "${ORIGDIR}"/bvals "${ORIGDIR}"/bvecs

# Expected output files
set +e
read -r -d '' REQUIRED_FILES <<- EOM
	${DIFPDIR}/dti.bedpostX/merged_f1samples.nii.gz
	${DIFPDIR}/dti.bedpostX/merged_ph1samples.nii.gz
	${DIFPDIR}/dti.bedpostX/merged_th1samples.nii.gz
	${DIFPDIR}/dti.bedpostX/mean_f1samples.nii.gz
	${DIFPDIR}/dti.bedpostX/mean_ph1samples.nii.gz
	${DIFPDIR}/dti.bedpostX/mean_th1samples.nii.gz
	${DIFPDIR}/dti.bedpostX/dyads1_dispersion.nii.gz
	${DIFPDIR}/dti.bedpostX/dyads1.nii.gz
	${DIFPDIR}/dti.bedpostX/merged_f2samples.nii.gz
	${DIFPDIR}/dti.bedpostX/merged_ph2samples.nii.gz
	${DIFPDIR}/dti.bedpostX/merged_th2samples.nii.gz
	${DIFPDIR}/dti.bedpostX/mean_f2samples.nii.gz
	${DIFPDIR}/dti.bedpostX/mean_ph2samples.nii.gz
	${DIFPDIR}/dti.bedpostX/mean_th2samples.nii.gz
	${DIFPDIR}/dti.bedpostX/dyads2_dispersion.nii.gz
	${DIFPDIR}/dti.bedpostX/dyads2.nii.gz
	${DIFPDIR}/dti.bedpostX/mean_dsamples.nii.gz
	${DIFPDIR}/dti.bedpostX/mean_S0samples.nii.gz
EOM
set -e

# Check if we need to run this stage
check_already_run


rm -rf "${DIFPDIR}"
mkdir "${DIFPDIR}"
mkdir "${DIFPDIR}/dti"

cp -r ${PROCDIR}/__Cache_3/* "${DIFPDIR}"
exit 0

run_and_log 1.organize.files cp "${CORRDIR}"/data.nii.gz "${CORRDIR}"/nodif_brain_mask.nii.gz "${ORIGDIR}"/bvals "${ORIGDIR}"/bvecs "${DIFPDIR}/dti"

run_and_log 2.bedpostx ${FSLPRE}bedpostx "${DIFPDIR}/dti" --nf=2 --fudge=1  --bi=1000 --model=2
