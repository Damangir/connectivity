#!/bin/bash

source "$(cd "$(dirname "$0")"&&pwd)/common.sh"

# Expected input files
depends_on "${CASCADE_DIR}/flair.normalized.nii.gz"

# Expected output files
set +e
read -r -d '' REQUIRED_FILES <<- EOM
	${STR_IMPORTDIR}/flair.normalized.nii.gz
	${TRANSDIR}/flair_to_t1.mat
EOM
set -e

# Check if we need to run this stage
check_already_run
remove_expected_output

mkdir -p "${STR_IMPORTDIR}"

run_and_log 1.copy_flair cp "${CASCADE_DIR}/flair.normalized.nii.gz" ${STR_IMPORTDIR}/flair.normalized.nii.gz
run_and_log 2.copy_pval cp "${CASCADE_DIR}/flair.modelfree.pval.nii.gz" ${STR_IMPORTDIR}/flair.pval.nii.gz



