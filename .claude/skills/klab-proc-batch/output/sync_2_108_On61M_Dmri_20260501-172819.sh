#!/bin/bash
previous_wd=$(pwd)
cd /mnt/qnapdata3/iueda/SyncResultsForKlab

./syncRslts.sh \
    --drv-of-subjects-on-src=/mnt/synology1-4/HCP_RestingStateStats/2_108_IRCN/derivatives/HCPpipeline/ \
    --drv-of-subjects-on-dst=/mnt/synology2-2/dMRI-Preprocessed/2_108/derivatives \
    --mode=DMRI \
    --run

cd ${previous_wd}
