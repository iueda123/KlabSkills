#!/bin/bash
previous_wd=$(pwd)
cd /mnt/qnapdata3/iueda/SyncResultsForKlab

./syncRslts.sh \
    --drv-of-subjects-on-src=/mnt/data12/iueda/dwi_preproc/Pttrn_hmhybrid/2_11/derivatives \
    --drv-of-subjects-on-dst=/mnt/synology2-2/dMRI-Preprocessed/2_11/derivatives \
    --mode=DMRI \
    --run

cd ${previous_wd}
