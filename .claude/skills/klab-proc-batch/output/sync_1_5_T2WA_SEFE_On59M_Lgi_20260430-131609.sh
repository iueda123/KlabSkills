#!/bin/bash
subjects=()
subjects+=("sub-K1708311200")
subjects+=("sub-K1709121200")
subjects+=("sub-K1709121700")
subjects+=("sub-K1709141700")
subjects+=("sub-K1709201200")
subjects+=("sub-K1709221200")
subjects+=("sub-K1709261700")
subjects+=("sub-K1709271700")
subjects+=("sub-K1710111200")
subjects+=("sub-K1710111700")
subjects+=("sub-K1710161700")
subjects+=("sub-K1710241700")
subjects+=("sub-K1710251700")
subjects+=("sub-K1710311700")
subjects+=("sub-K1711201700")
subjects+=("sub-K1712071700")
subjects+=("sub-K1712121700")
subjects+=("sub-K1712191700")
subjects+=("sub-K1712281700")
subjects+=("sub-K1801051200")
subjects+=("sub-K1801091700")
subjects+=("sub-K1801151700")
subjects+=("sub-K1801291800")
subjects+=("sub-K1801301700")
subjects+=("sub-K1802021800")
subjects+=("sub-K1802081700")
subjects+=("sub-K1802091700")
subjects+=("sub-K1802211800")
subjects+=("sub-K1803021700")
subjects+=("sub-K1803221700")
subjects+=("sub-K1803271700")
subjects+=("sub-K1803291300")

previous_wd=$(pwd)
cd /mnt/qnapdata3/iueda/SyncResultsForKlab

for sbjid in ${subjects[@]}; do
    ./syncRslts.sh \
        --subject-id=${sbjid} \
        --drv-of-subjects-on-src=/mnt/synology4-1/HCP_postFS/03_Adolescence_taste/LegacyStyle_with_Topup/derivatives/HCPpipeline/ \
        --drv-of-subjects-on-dst=/mnt/qnapdata2/mri2024/hcp/mri4/ext1_5 \
        --mode=LGI \
        --run
done

cd ${previous_wd}
