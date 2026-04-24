#!/bin/bash
conda activate env_for_dMRIAgg

subjects=()
subjects+=("sub-K2009231730")
subjects+=("sub-K2009281630")
subjects+=("sub-K2009291630")
subjects+=("sub-K2009301630")
subjects+=("sub-K2010011730")
subjects+=("sub-K2010021630")
subjects+=("sub-K2010021730")
subjects+=("sub-K2010051630")
subjects+=("sub-K2010071630")
subjects+=("sub-K2010071730")
subjects+=("sub-K2010081730")
subjects+=("sub-K2010091730")
subjects+=("sub-K2010131630")
subjects+=("sub-K2010141730")
subjects+=("sub-K2010151730")
subjects+=("sub-K2010161630")
subjects+=("sub-K2010201630")
subjects+=("sub-K2010221730")
subjects+=("sub-K2010231730")
subjects+=("sub-K2010271630")

previous_wd=$(pwd)
cd /mnt/qnapdata3/iueda/Aggregate_dMRI_Features_on_MMP1

for sbjid in ${subjects[@]}; do
    ./agg_dMRI_NIDPs_on_MMP1.sh \
        --subject-id=${sbjid} \
        --drv-of-subjects-on-share=/mnt/synology2-2/dMRI-Preprocessed/2_16/derivatives \
        --drv-of-subjects-on-share-secondary=/mnt/synology4-1/HCP_RestingStateStats/03_Cohort04_Komaba/HCPstyle/derivatives/HCPpipeline \
        --drv-of-subjects-on-proc=/mnt/data12/iueda/dwi_agg/2_16/derivatives \
        --should-push-rslt-to-share \
        --mode=msmall \
        --verbose
done

cd ${previous_wd}
