#!/bin/bash
subjects=()
subjects+=("sub-K2002191800")
subjects+=("sub-K2002211100")
subjects+=("sub-K2002281000")
subjects+=("sub-K2003061000")
subjects+=("sub-K2003091600")
subjects+=("sub-K2003101000")
subjects+=("sub-K2003111400")
subjects+=("sub-K2003231400")
subjects+=("sub-K2007161000")
subjects+=("sub-K2007161630")
subjects+=("sub-K2008051430")
subjects+=("sub-K2008171230")
subjects+=("sub-K2008311100")
subjects+=("sub-K2009011500")
subjects+=("sub-K2009071500")
subjects+=("sub-K2009091630")
subjects+=("sub-K2009161500")
subjects+=("sub-K2009161630")
subjects+=("sub-K2009171430")
subjects+=("sub-K2009171630")
subjects+=("sub-K2111051230")
subjects+=("sub-K2111171430")
subjects+=("sub-K2111251430")
subjects+=("sub-K2112131100")
subjects+=("sub-K2112151430")
subjects+=("sub-K2201191330")
subjects+=("sub-K2201271430")
subjects+=("sub-K2202161430")
subjects+=("sub-K2203171430")
subjects+=("sub-K2204251230")
subjects+=("sub-K2306281430")
subjects+=("sub-K2307241430")

previous_wd=$(pwd)
cd /mnt/qnapdata3/iueda/SMriFMriPreprocForKlab

for sbjid in ${subjects[@]}; do
    tsp ./run_hcppipelines_for_klab.sh \
        --subject-id=${sbjid} \
        --src-of-subjects-on-share=/mnt/synology4-1/HCP_RestingStateStats/2_11/sourcedata \
        --drv-of-subjects-on-proc=/mnt/data2/iueda/2_11/derivatives \
        --drv-of-subjects-on-share=/mnt/synology4-1/HCP_RestingStateStats/2_11/derivatives/HCPpipeline \
        --should-push-drv-to-share=true \
        --should-save-intermediates=false \
        --verbose
done

cd ${previous_wd}
