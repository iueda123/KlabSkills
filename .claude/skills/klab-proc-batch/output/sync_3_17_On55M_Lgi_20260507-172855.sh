#!/bin/bash
previous_wd=$(pwd)
cd /mnt/qnapdata3/iueda/SyncResultsForKlab

./syncRslts.sh \
    --drv-of-subjects-on-src=/mnt/synology4-1/HCP_postFS/03_Cohort01_Yaesu_Parent/derivatives/HCPpipeline/ \
    --drv-of-subjects-on-dst=/mnt/qnapdata2/mri2024/hcp/mri4/ext3_17/ \
    --mode=LGI \
    --run

cd ${previous_wd}
