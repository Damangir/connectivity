
PROCDIR=${PROCDIR:-"${1?"You should specify PROCDIR or pass it as first var"}"}

SCRIPT_NAME=$( basename "${0}" )
SCRIPT_DIR=$( cd "$( dirname "${0}" )" && pwd )
DATA_DIR=$( cd "$( dirname "${SCRIPT_DIR}" )/data" && pwd )
if [ "$SCRIPT_NAME" = common.sh ]
then
  printf "common.sh is a utility to be sourced. You can not run it.\n" >&2
  return 1
fi

printf "#%.0s" {1..80};printf "\n"

STAGE=${SCRIPT_NAME%.*.*}
printf "# Stage $STAGE\n"

if [ -d $(dirname ${PROCDIR} 2>/dev/null) ]
then
  PROCDIR=$( cd "$( dirname "${PROCDIR}" )" && pwd )/$(basename "${PROCDIR}")
  printf "# ${SCRIPT_NAME}: PROCDIR is ${PROCDIR}\n"
  if ! [ -e ${PROCDIR} ]
  then
    printf "# Creating ${PROCDIR}\n"
    mkdir ${PROCDIR}
  fi
else
  printf "Directory (${PROCDIR}) does not exist and can not be created\n" >&2
  exit 1
fi

if [ -f "${SCRIPT_DIR}/directory_structure.sh" ]
then
  printf "# Loading diredtory structure at ${SCRIPT_DIR}/directory_structure.sh\n"
  source "${SCRIPT_DIR}/directory_structure.sh"
fi

if [ -e "${LOCK_FILE}" ]
then
  printf "${PROCDIR} is locked by another processor. Each subject can only be processed by one application at the same time.\n" >&2
  exit 1
fi


mkdir -p "${LOGDIR}" "${TOUCHDIR}" "${LOCKDIR}" "${QCDIR}"


function on_exit {
  local rv=$?
  printf "#%.0s" {1..80};printf "\n"
  # Process done without error. Now we check if all req. files is there.
  if [ ${rv} -eq 0 ]
  then
    while IFS= read -r req_f
    do
      if ! [ -e "${req_f}" ]
      then
        printf "${req_f} is expected but is not present. I assume the procedure failed.\n" >&2
        rv=1
      fi
    done <<<"$REQUIRED_FILES"
  fi

  if [ ${rv} -ne 0 ]
  then
    printf "# ${SCRIPT_NAME} failed on ${PROCDIR}. ERRNO: ${rv}\n"
    touch "${ERROR_FILE}"
    # Let's make sure there would be no done file from previous runs.
    rm -f "${DONE_FILE}"
  else
    touch "${DONE_FILE}"
    printf "# ${SCRIPT_NAME} succesed on ${PROCDIR}\n"
  fi

  rm -rf "${STARTED_FILE}"
  rm -rf "${LOCK_FILE}"
  rm -rf "${CON_TEMPDIR}"
  printf "#%.0s" {1..80}
  printf "\n\n"
  exit $rv
}

for s in $(printf "%d " {1..31})
do
  trap "exit $s" $s
done

trap on_exit EXIT

(umask 077 && mkdir "${CON_TEMPDIR}") || exit 1


function run_and_log {
  local run_name=$1
  shift
  printf "# Stage ${STAGE}: ${run_name}\n"
  printf "%s " "$@"
  printf "\n"
  $@ &>"${LOGDIR}"/log.${STAGE}.${run_name}.txt
  local rv=$?
  if [ "${rv}" -eq 0 ]
  then
    printf "# Success!\n"
    touch "${TOUCHDIR}/touch.${STAGE}.${run_name}.$(date +%Y%m%d.%H%M%S)"
  else
    printf "# Fail!\n"
    exit 1
  fi
}

function remove_expected_output {
    while IFS= read -r req_f
    do
      [ -e "${req_f}" ] && rm -r "${req_f}"
    done <<<"$REQUIRED_FILES"
    return 0
}

function check_updated {
  for file in "$@"
  do
    if [ "$file" -nt "${DONE_FILE}" ]
    then
      printf "$file has been updated since previous run. I will force the stage to re-run.\n" >&2
      rm -rf "${DONE_FILE}"
    fi
  done
}

function check_already_run {
  if [ -e "${DONE_FILE}" ]
  then
    printf "Stage ${STAGE} has already been done. Remove "${TOUCHDIR}"/stage.${STAGE}.done to force re-run\n" >&2
    exit 0
  fi
}

function depends_on {
  for file in "$@"
  do
    printf "# Dependency check: $file\n"
    if ! [ -f "$file" ]
    then
      printf "$file is required for running ${SCRIPT_NAME}.\n" >&2
      exit 1
    fi
  done
  if [ -e "${DONE_FILE}" ]
  then
    check_updated "$@"
  fi
}

rm -rf "${TOUCHDIR}"/stage.${STAGE}.error
rm -rf "${TOUCHDIR}"/touch.${STAGE}.*

touch "${LOCKDIR}/processing"
touch "${TOUCHDIR}/stage.${STAGE}.started"

printf "#%.0s" {1..80};printf "\n"