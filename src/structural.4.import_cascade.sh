#!/bin/bash

source "$(cd "$(dirname "$0")"&&pwd)/common.sh"

CASCADE_MASK=${CASCADE_MASK:-"wml_mask*.nii.gz"}
for f in "${CASCADE_DIR}"/${CASCADE_MASK}; do
	# Cascade_mask should not exist
	if [ -f "${CURRENT_CASCADE_MASK}" ]
	then
		printf "${CASCADE_MASK} matches multiple files in ${CASCADE_DIR}.\n" >&2
		exit 1
	fi
	[ -f "$f" ] && CURRENT_CASCADE_MASK="${f}"
done

# Expected input files
depends_on "${CASCADE_DIR}/flair.normalized.nii.gz" "${CASCADE_DIR}/flair.modelfree.pval.nii.gz" "${CURRENT_CASCADE_MASK}"

# Expected output files
set +e
read -r -d '' REQUIRED_FILES <<- EOM
	${STR_IMPORTDIR}/flair.normalized.nii.gz
	${STR_IMPORTDIR}/flair.pval.nii.gz
	${STR_IMPORTDIR}/flair.wml_mask.nii.gz
EOM
set -e

# Check if we need to run this stage
check_already_run
remove_expected_output

mkdir -p "${STR_IMPORTDIR}"

run_and_log 1.copy_flair cp "${CASCADE_DIR}/flair.normalized.nii.gz" ${STR_IMPORTDIR}/flair.normalized.nii.gz
run_and_log 2.copy_pval cp "${CASCADE_DIR}/flair.modelfree.pval.nii.gz" ${STR_IMPORTDIR}/flair.pval.nii.gz
run_and_log 2.copy_mask cp "${CURRENT_CASCADE_MASK}" ${STR_IMPORTDIR}/flair.wml_mask.nii.gz



