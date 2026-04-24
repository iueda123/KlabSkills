#!/bin/bash

previous_wd=$(pwd)
cd /mnt/qnapdata3/iueda/SyncResultsForKlab

./syncRslts.sh \
    --drv-of-subjects-on-proc=/mnt/data2/iueda/2_11/derivatives \
    --drv-of-subjects-on-share=/mnt/qnapdata2/mri2024/hcp/mri4/ext2_11 \
    --mode=SSMRI_NIDP \
    --run

cd ${previous_wd}
