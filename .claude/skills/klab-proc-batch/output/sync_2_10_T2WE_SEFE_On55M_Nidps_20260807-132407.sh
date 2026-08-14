#!/bin/bash
subjects=()
subjects+=("sub-K1812251700")

previous_wd=$(pwd)
cd /mnt/qnapdata3/iueda2/SyncResultsForKlab

for sbjid in ${subjects[@]}; do
    ./syncRslts.sh \
        --dataset-id=2_10_T2WE_SEFE \
        --subject-id=${sbjid} \
        --drv-of-subjects-on-src=/mnt/synology2-2/dMRI-Preprocessed/2_10_HCPstyle/derivatives \
        --drv-of-subjects-on-dst=/mnt/qnapdata2/mri2024/hcp/mri4/ext2_10_HCPstyle \
        --mode=NIDPS \
        --run
done

cd ${previous_wd}
