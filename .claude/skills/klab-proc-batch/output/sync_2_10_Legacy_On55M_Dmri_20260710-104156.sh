#!/bin/bash
subjects=()
subjects+=("sub-K1812261700")
subjects+=("sub-K1901171800")
subjects+=("sub-K1901251800")
subjects+=("sub-K1901301700")
subjects+=("sub-K1902041630")
subjects+=("sub-K1902061800")
subjects+=("sub-K1902071800")
subjects+=("sub-K1902081800")
subjects+=("sub-K1902131700")
subjects+=("sub-K1902191700")
subjects+=("sub-K1902221700")
subjects+=("sub-K1902271700")
subjects+=("sub-K1902271800")
subjects+=("sub-K1902281700")
subjects+=("sub-K1902281800")
subjects+=("sub-K1903141700")
subjects+=("sub-K1903261000")
subjects+=("sub-K1903271100")
subjects+=("sub-K1903271630")
subjects+=("sub-K1903291100")
subjects+=("sub-K1903291530")
subjects+=("sub-K1904021530")
subjects+=("sub-K1904021630")
subjects+=("sub-K1904031000")
subjects+=("sub-K1904031100")
subjects+=("sub-K1904031530")
subjects+=("sub-K1904031630")
subjects+=("sub-K1904041630")
subjects+=("sub-K1904051530")
subjects+=("sub-K1904111800")

previous_wd=$(pwd)
cd /mnt/qnapdata3/iueda/SyncResultsForKlab

for sbjid in ${subjects[@]}; do
    ./syncRslts.sh \
        --subject-id=${sbjid} \
        --drv-of-subjects-on-src=/mnt/data12/iueda/dwi_preproc/Pttrn_hmhybrid/2_10_Legacy/derivatives \
        --drv-of-subjects-on-dst=/mnt/synology2-2/dMRI-Preprocessed/2_10_Legacy/derivatives \
        --mode=DMRI \
        --run
done

cd ${previous_wd}
