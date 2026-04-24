#!/bin/bash
subjects=()
subjects+=("sub-K2010021630")
# 被験者を追加する場合は subjects+=("sub-XXXXXXXXXX") を続ける

previous_wd=$(pwd)
cd /mnt/qnapdata3/tamai/DMriPreprocForKlab

for sbjid in ${subjects[@]}; do
    ./run_dmri_preproc_pipelines_for_klab.sh \
        --subject-id=${sbjid} \
        --src-of-subjects-on-share=/mnt/synology4-1/HCP_RestingStateStats/03_Cohort04_Komaba/sourcedata \
        --drv-of-subjects-on-share=/mnt/synology4-1/HCP_RestingStateStats/03_Cohort04_Komaba/HCPstyle/derivatives/HCPpipeline \
        --drv-of-subjects-on-proc=/mnt/data5/Tamai/derivatives_dmri_proc \
        --dmri-proc-pttrn=hmhybrid \
        --use-gpu=true \
        --should-push-drv-to-share=true \
        --verbose
done

cd ${previous_wd}
