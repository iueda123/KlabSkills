#!/bin/bash
conda activate env_for_dMRIAgg

subjects=()
subjects+=("sub-K1812261700")
subjects+=("sub-K1901171800")
subjects+=("sub-K1901251800")
subjects+=("sub-K1901301700")
subjects+=("sub-K1902041630")
subjects+=("sub-K1902061800")
subjects+=("sub-K1902071800")
subjects+=("sub-K1902081800")
subjects+=("sub-K1902131700")
subjects+=("sub-K1902191700")
subjects+=("sub-K1902221700")
subjects+=("sub-K1902271700")
subjects+=("sub-K1902271800")
subjects+=("sub-K1902281700")
subjects+=("sub-K1902281800")
subjects+=("sub-K1903141700")
subjects+=("sub-K1903261000")
subjects+=("sub-K1903271100")
subjects+=("sub-K1903271630")
subjects+=("sub-K1903291100")
subjects+=("sub-K1903291530")
subjects+=("sub-K1904021530")
subjects+=("sub-K1904021630")
subjects+=("sub-K1904031000")
subjects+=("sub-K1904031100")
subjects+=("sub-K1904031530")
subjects+=("sub-K1904031630")
subjects+=("sub-K1904041630")
subjects+=("sub-K1904051530")
subjects+=("sub-K1904111800")

previous_wd=$(pwd)
cd /mnt/qnapdata3/iueda2/Aggregate_dMRI_Features_on_MMP1

for sbjid in ${subjects[@]}; do
    ./agg_dMRI_NIDPs_on_MMP1.sh \
        --dataset-id=2_10_Legacy \
        --subject-id=${sbjid} \
        --drv-of-subjects-on-share=/mnt/synology2-2/dMRI-Preprocessed/2_10_Legacy/derivatives \
        --drv-of-subjects-on-share-secondary=/mnt/synology1-4/HCP_RestingStateStats/03_Cohort03_Komaba_2day/LegacyStyle_WithTopupOnly/derivatives/HCPpipeline/ \
        --drv-of-subjects-on-proc=/mnt/data12/iueda2/dwi_agg/2_10_Legacy/derivatives \
        --should-push-rslt-to-share \
        --verbose
done

cd ${previous_wd}
