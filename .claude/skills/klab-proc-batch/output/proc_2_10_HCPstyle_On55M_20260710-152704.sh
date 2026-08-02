#!/bin/bash
conda activate env_for_dMRIAgg

subjects=()
subjects+=("sub-K1812251700")

previous_wd=$(pwd)
cd /mnt/qnapdata3/iueda/Aggregate_dMRI_Features_on_MMP1

for sbjid in ${subjects[@]}; do
    ./agg_dMRI_NIDPs_on_MMP1.sh \
        --subject-id=${sbjid} \
        --drv-of-subjects-on-share=/mnt/synology2-2/dMRI-Preprocessed/2_10_HCPstyle/derivatives \
        --drv-of-subjects-on-share-secondary=/mnt/synology1-4/HCP_RestingStateStats/03_Cohort03_Komaba_2day/HCPstyle/derivatives/HCPpipeline/ \
        --drv-of-subjects-on-proc=/mnt/data12/iueda/dwi_agg/2_10_HCPstyle/derivatives \
        --should-push-rslt-to-share=true \
        --verbose
done

cd ${previous_wd}
