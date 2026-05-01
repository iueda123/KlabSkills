#!/bin/bash
subjects=()
subjects+=("sub-K1802281700")

previous_wd=$(pwd)
cd /mnt/qnapdata3/iueda/SyncResultsForKlab

for sbjid in ${subjects[@]}; do
    ./syncRslts.sh \
        --subject-id=${sbjid} \
        --drv-of-subjects-on-src=/mnt/synology4-1/HCP_postFS/03_Adolescence_taste/LegacyStyle_T1w_only/derivatives/HCPpipeline/ \
        --drv-of-subjects-on-dst=/mnt/qnapdata2/mri2024/hcp/mri4/ext1_5 \
        --mode=LGI \
        --run
done

cd ${previous_wd}
