declare -r DATA_DIR=$(cd "${SCRIPT_DIR}/../data"&&pwd)

declare -r QCDIR=${PROCDIR}/QC
declare -r REPORTDIR=${PROCDIR}/Report
declare -r TRANSDIR=${PROCDIR}/Transformations
declare -r IMAGEDIR=${PROCDIR}/Images
declare -r DTIDIR=${IMAGEDIR}/DTI
declare -r ORIGDIR=${DTIDIR}/0.Original
declare -r CORRDIR=${DTIDIR}/1.Correct
declare -r TFITDIR=${DTIDIR}/2.TensorFit
declare -r DIFPDIR=${DTIDIR}/3.DiffusionParameters
declare -r TRACKDIR=${DTIDIR}/4.Tractography
declare -r MNI_TRACKDIR=${TRACKDIR}/MNI
declare -r ATLAS_TRACKDIR=${DTIDIR}/5.TractographyFronAtlas
declare -r ATLAS_ON_FLAIR=${ATLAS_TRACKDIR}/flair
declare -r ATLAS_ON_DTI=${ATLAS_TRACKDIR}/DTI
declare -r ATLAS_ON_T1=${ATLAS_TRACKDIR}/t1
declare -r STRDIR=${IMAGEDIR}/structural
declare -r STR_IMPORTDIR=${STRDIR}/0.Original
declare -r STR_REGDIR=${STRDIR}/1.Registration
declare -r STR_SEEDDIR=${STRDIR}/3.TractographySeeds


mkdir -p "$QCDIR" "$REPORTDIR" "$TRANSDIR" "$IMAGEDIR"
mkdir -p "$DTIDIR" "$ORIGDIR" "$CORRDIR" "$TFITDIR" "$DIFPDIR" "$TRACKDIR"
mkdir -p "$MNI_TRACKDIR" "$ATLAS_TRACKDIR" "$ATLAS_ON_T1" "$ATLAS_ON_DTI" "$ATLAS_ON_FLAIR"
mkdir -p "$STRDIR" "$STR_IMPORTDIR" "$STR_SEEDDIR" "$STR_REGDIR"

mkdir -p "${DIFPDIR}/dti"

declare -r MNIDIR=${FSLDIR}/data/standard