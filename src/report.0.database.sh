#!/bin/bash

source "$(cd "$(dirname "$0")"&&pwd)/common.sh"

# Expected input files
LABELS_SEED="${DATA_DIR}/labels_seed.txt"
# TODO: get the reporting item from user
REPORT_ITEMS="${DATA_DIR}/report_items.txt"

set -e
depends_on "${LABELS_SEED}"
depends_on "${REPORT_LIST}"
depends_on "${REPORT_ITEMS}"
function get_path_for_subject {
	(
		PROCDIR=$1
		source "${SCRIPT_DIR}/directory_structure.sh"
		eval echo "$2"
	)
}
grep . ${REPORT_LIST} | while read -r subj_procdir
do
	grep . ${REPORT_ITEMS} | while read -r to_report
	do
		report_file=$(get_path_for_subject "${subj_procdir}" '${REPORTDIR}'"/${to_report}.txt")
		depends_on "${report_file}"
	done
done
# Expected output files
set +e
grep . ${LABELS_SEED} | while read -r name
do
	grep . ${REPORT_ITEMS} | while read -r to_report
	do
		csv_file=${PROCDIR}/${to_report}.csv
    	read -r -d '' REQUIRED_FILES <<- EOM
${REQUIRED_FILES}
${csv_file}
EOM
    done
done
set -e

# Check if we need to run this stage
check_already_run
remove_expected_output

read -r a_procdir < <(grep . ${REPORT_LIST})

function ensure_consistency {
	grep . ${REPORT_ITEMS} | while read -r to_report
	do
		report_file=$(get_path_for_subject "${a_procdir}" '${REPORTDIR}'"/${to_report}.txt")
		prev=$(cut -d ' ' -f 1 "${report_file}" | tr '\n' ';')
		while read -r subj_procdir
		do
			report_file=$(get_path_for_subject "${subj_procdir}" '${REPORTDIR}'"/${to_report}.txt")
			current_labels=$(cut -d ' ' -f 1 "${report_file}" | tr '\n' ';')
			if [ "${prev}" = "${current_labels}" ]
			then
				prev=${current_labels}
				printf "${current_labels}\n" >> ${QCDIR}/labels.${to_report}.txt
			else
		  	    printf "Headers in ${report_file} does not match headers in other files.\n" >&2
		        exit 1
			fi
		done< <(grep . ${REPORT_LIST})
	done
}

function extract_values {
	report_file=$(get_path_for_subject "${1}" '${REPORTDIR}'"/${to_report}.txt")
	current_values=$(cut -d ' ' -f 2 "${report_file}" | tr '\n' ';')
	current_id=$(basename "${1}")
    printf "${current_id};${current_values}\n" >> "${csv_file}"
}

run_and_log 0.consistency_check ensure_consistency

grep . ${REPORT_ITEMS} | while read -r to_report
do
	csv_file=${PROCDIR}/${to_report}.csv

	report_file=$(get_path_for_subject "${a_procdir}" '${REPORTDIR}'"/${to_report}.txt")
	current_labels=$(cut -d ' ' -f 1 "${report_file}" | tr '\n' ';')

	printf "id;${current_labels}\n" > "${csv_file}"
	grep . ${REPORT_LIST} | while read -r subj_procdir
	do
		run_and_log 1.extract_values extract_values "${subj_procdir}"
	done
done