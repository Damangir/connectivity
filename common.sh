LOGDIR=${PROCDIR}/Log
TOUCHDIR=${PROCDIR}/Touch
LOCKDIR=${PROCDIR}/Lock

if [ -e "${LOCKDIR}/processing" ]
then
  echo "{PROCDIR}" is locked by another processor. Each subject can only be processed by one application at the same time. >&2
  exit 1
fi

if [ -d "$(dirname ${PROCDIR} 2>/dev/null)" ]
then
  mkdir -p ${PROCDIR}
else
  echo "Directory (${PROCDIR}) does not exist and can not be created" >&2
  exit 1
fi


ORIGDIR=${PROCDIR}/0.Original
CORRDIR=${PROCDIR}/1.Correct
TFITDIR=${PROCDIR}/2.TensorFit
DIFPDIR=${PROCDIR}/3.DiffusionParameters
STRDIR=${PROCDIR}/4.Structural
TRANDIR=${PROCDIR}/5.Registration
TRACDIR=${PROCDIR}/6.Tractography

QCDIR=${PROCDIR}/QC

mkdir -p "${LOGDIR}" "${TOUCHDIR}" "${LOCKDIR}" "${QCDIR}"


function on_exit {
  local rv=$?
  if [ ${rv} -ne 0 ]
  then
    touch "${TOUCHDIR}/stage.${STAGE}.error"
  else
    touch "${TOUCHDIR}/stage.${STAGE}.done"
  fi
  rm -rf "${TOUCHDIR}/stage.${STAGE}.started"
  rm -rf "${LOCKDIR}/processing"
  exit $rv
}

for s in $(echo {1..31})
do
  trap "exit $s" $s
done

trap on_exit EXIT

function run_and_log {
  local run_name=$1
  shift
  echo "# Stage ${STAGE}: ${run_name}"
  echo $@
  $@ &>"${LOGDIR}"/log.${STAGE}.${run_name}.txt
  local rv=$?
  if [ "${rv}" -eq 0 ]
  then
    echo "# Success!"
    touch "${TOUCHDIR}/touch.${STAGE}.${run_name}.$(date +%Y%m%d.%H%M%S)"
  else
    echo "# Fail!"
    exit 1
  fi
}

if [ -e "${TOUCHDIR}"/stage.${STAGE}.done ]
then
  echo Stage ${STAGE} has already been done. Remove "${TOUCHDIR}"/stage.${STAGE}.done to force re-run >&2
  exit 0
fi

rm -rf "${TOUCHDIR}"/stage.${STAGE}.error
rm -rf "${TOUCHDIR}"/touch.${STAGE}.*

set -- "${TOUCHDIR}"/stage.[*].error "${TOUCHDIR}"/stage.*.error
case $1$2 in
  ("${TOUCHDIR}"/stage.'[*]'.error"${TOUCHDIR}"/stage.'*'.error);;
  (*) echo There are some unresolved errors from previous runs in the directory structure; exit 1;
esac

touch "${LOCKDIR}/processing"
touch "${TOUCHDIR}/stage.${STAGE}.started"