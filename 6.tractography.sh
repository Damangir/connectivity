#!/bin/bash -e

STAGE=6

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}/common.sh"

# Depends on diffusion parameters
if ! [ -e "${TOUCHDIR}/stage.3.done" ]
then
  echo Stage 3 should be run before >&2
  exit 1
fi

rm -rf ${PROCDIR}
mkdir -p ${PROCDIR}
