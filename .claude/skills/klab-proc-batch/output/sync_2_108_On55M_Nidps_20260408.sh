#!/bin/bash
subjects=()
subjects+=("sub-UTI_Prisma_CRHD_0002_001_MR1")

previous_wd=$(pwd)
cd /mnt/qnapdata3/iueda/SyncResultsForKlab

for sbjid in ${subjects[@]}; do
    ./syncRslts.sh \
        --subject-id=${sbjid} \
        --drv-of-subjects-on-proc=/mnt/synology1-4/HCP_RestingStateStats/2_108_IRCN/derivatives/HCPpipeline/ \
        --drv-of-subjects-on-share=/mnt/qnapdata2/mri2024/hcp/mri4/ext2_108/ \
        --mode=NIDPS \
        --run
done

cd ${previous_wd}
