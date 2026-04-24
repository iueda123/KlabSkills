#!/bin/bash
conda activate env_for_dMRIAgg

subjects=()
subjects+=("sub-UTI_Prisma_CRHD_0002_001_MR1")

previous_wd=$(pwd)
cd /mnt/qnapdata3/iueda/Aggregate_dMRI_Features_on_MMP1

for sbjid in ${subjects[@]}; do
    ./agg_dMRI_NIDPs_on_MMP1.sh \
        --subject-id=${sbjid} \
        --drv-of-subjects-on-share=/mnt/synology1-4/HCP_RestingStateStats/2_108_IRCN/derivatives/HCPpipeline/ \
        --drv-of-subjects-on-proc=/mnt/data12/iueda/dwi_agg/2_108/derivatives \
        --should-push-rslt-to-share \
        --mode=msmall \
        --calc-noddi=YES \
        --noddi-d-par=1.1e-3 \
        --verbose
done

cd ${previous_wd}
