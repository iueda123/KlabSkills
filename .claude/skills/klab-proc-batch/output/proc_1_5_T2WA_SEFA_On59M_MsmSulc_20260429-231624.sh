#!/bin/bash
subjects=()
subjects+=("sub-K1802281700")

previous_wd=$(pwd)
cd /mnt/qnapdata3/iueda/Aggregate_LGI_on_MMP1

for sbjid in ${subjects[@]}; do
    tsp bash startAggregationOfLgiOnMmp1ForKlab.sh \
        --subject-id=${sbjid} \
        --drv-of-subjects-on-share=/mnt/synology4-1/HCP_postFS/03_Adolescence_taste/LegacyStyle_T1w_only/derivatives/HCPpipeline/ \
        --drv-of-subjects-on-proc=/mnt/data2/iueda/1_5_T2WA_SEFA/derivatives \
        --should-push-drv-to-share=true \
        --regname=MSMSulc \
        --verbose
done

cd ${previous_wd}
