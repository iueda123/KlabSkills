#!/bin/bash
subjects=()
subjects+=("sub-UTI_Prisma_CRHD_0001_001_MR1")
subjects+=("sub-UTI_Prisma_CRHD_0002_001_MR1")
subjects+=("sub-UTI_Prisma_CRHD_0003_001_MR1")
subjects+=("sub-UTI_Prisma_CRHD_0004_001_MR1")
subjects+=("sub-UTI_Prisma_CRHD_0005_001_MR1")
subjects+=("sub-UTI_Prisma_CRHD_0006_001_MR1")
subjects+=("sub-UTI_Prisma_CRHD_0007_001_MR1")
subjects+=("sub-UTI_Prisma_CRHD_0008_001_MR1")

previous_wd=$(pwd)
cd /mnt/qnapdata3/iueda/SyncResultsForKlab

for sbjid in ${subjects[@]}; do
    ./syncRslts.sh \
        --subject-id=${sbjid} \
        --drv-of-subjects-on-proc=/mnt/data12/iueda/dwi_agg/2_108/derivatives \
        --drv-of-subjects-on-share=/mnt/synology2-2/dMRI-Preprocessed/2_108/derivatives \
        --mode=DMRI \
        --run
done

cd ${previous_wd}
