#!/bin/bash
subjects=()
subjects+=("sub-0001T")
subjects+=("sub-0002T")
subjects+=("sub-0003T")
subjects+=("sub-0004T")
subjects+=("sub-0007T")
subjects+=("sub-0051T")
subjects+=("sub-0052T")
subjects+=("sub-0053T")
subjects+=("sub-0054T")
subjects+=("sub-0055T")
subjects+=("sub-0056T")
subjects+=("sub-0057T")
subjects+=("sub-0059T")
subjects+=("sub-0061T")
subjects+=("sub-0062T")
subjects+=("sub-0063T")
subjects+=("sub-0064T")
subjects+=("sub-0065T")
subjects+=("sub-0066T")
subjects+=("sub-0067T")
subjects+=("sub-0069T")
subjects+=("sub-0070T")

previous_wd=$(pwd)
cd /mnt/qnapdata3/iueda/SyncResultsForKlab

for sbjid in ${subjects[@]}; do
    ./syncRslts.sh \
        --subject-id=${sbjid} \
        --drv-of-subjects-on-proc=/mnt/synology1-4/HCP_postFS/3_6_TS_SRPBYaesu/derivatives/HCPpipeline \
        --drv-of-subjects-on-share=/mnt/qnapdata2/mri2024/hcp/mri4/ext3_6 \
        --mode=LGI \
        --run
done

cd ${previous_wd}
