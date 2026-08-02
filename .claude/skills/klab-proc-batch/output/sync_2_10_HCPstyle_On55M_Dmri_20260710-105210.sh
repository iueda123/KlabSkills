#!/bin/bash
subjects=()
subjects+=("sub-K1812251700")

previous_wd=$(pwd)
cd /mnt/qnapdata3/iueda/SyncResultsForKlab

for sbjid in ${subjects[@]}; do
    ./syncRslts.sh \
        --subject-id=${sbjid} \
        --drv-of-subjects-on-src=/mnt/data12/iueda/dwi_preproc/Pttrn_hmhybrid/2_10_HCPstyle/derivatives \
        --drv-of-subjects-on-dst=/mnt/synology2-2/dMRI-Preprocessed/2_10_HCPstyle/derivatives \
        --mode=DMRI \
        --run
done

cd ${previous_wd}
