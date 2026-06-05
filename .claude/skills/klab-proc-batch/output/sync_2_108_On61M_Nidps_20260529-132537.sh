#!/bin/bash
previous_wd=$(pwd)
cd /mnt/qnapdata3/iueda/SyncResultsForKlab

./syncRslts.sh \
    --drv-of-subjects-on-src=/mnt/synology2-2/dMRI-Preprocessed/2_108/derivatives \
    --drv-of-subjects-on-dst=/mnt/qnapdata2/mri2024/hcp/mri4/ext2_108 \
    --mode=NIDPS \
    --run

cd ${previous_wd}
