# コホート別確認済みパス

実際に作業で確認・使用したパスを記録する。
新しいコホート・マシンの組み合わせで作業したら追記すること。

---

## 2_11 (Keio)

| 項目                            | パス                                                                  |
|:--------------------------------|:----------------------------------------------------------------------|
| sourcedata（主系）              | `/mnt/synology4-1/HCP_RestingStateStats/2_11/sourcedata`              |
| sourcedata（旧系A）             | `/mnt/synology3-2/HCP_OrigVer/Keio/sourcedata/`                       |
| sourcedata（旧系B）             | `/mnt/synology3-2/HCP_OrigVer/Keio_ShowaG/sourcedata/`                |
| sourcedata（旧系C）             | `/mnt/synology3-2/HCP_OrigVer/Keio_TakahashiLab/sourcedata/`          |
| drv-on-share（sMRI/fMRI、主系） | `/mnt/synology4-1/HCP_RestingStateStats/2_11/derivatives/HCPpipeline` |
| drv-on-share（sMRI/fMRI、旧系） | `/mnt/synology1-4/HCP_RestingStateStats/2_11/derivatives/HCPpipeline` |
| drv-on-share（NIDPs共有先）     | `/mnt/qnapdata2/mri2024/hcp/mri4/ext2_11`                             |
| drv-on-proc（59号機/iueda）     | `/mnt/data2/iueda/2_11/derivatives`                                   |
| drv-on-proc（dMRI、52号機）     | `/mnt/data3/iueda/dwi_preproc/Pttrn_NormalGpu/2_11/derivatives`       |
| drv-on-proc（dMRI、55号機）     | `/mnt/data11/<user>/dwi_preproc/Pttrn_hmhybrid/2_11/derivatives`      |

---

## 2_16 (03_Cohort04_Komaba)

確認日: 2026-04-08

| 項目                        | パス                                                                                         |
|:----------------------------|:---------------------------------------------------------------------------------------------|
| sourcedata（主系）          | `/mnt/synology4-1/HCP_RestingStateStats/03_Cohort04_Komaba/sourcedata`                       |
| sourcedata（旧系）          | `/mnt/synology3-2/HCP_OrigVer/03_Cohort04_Komaba/sourcedata`                                 |
| drv-on-share（sMRI/fMRI）   | `/mnt/synology4-1/HCP_RestingStateStats/03_Cohort04_Komaba/HCPstyle/derivatives/HCPpipeline` |
| drv-on-share（旧系）        | `/mnt/synology3-2/HCP_OrigVer/03_Cohort04_Komaba/HCPstyle/derivatives/HCPpipeline`           |
| スクリプト（56号機/tamai）  | `/mnt/qnapdata3/tamai/DMriPreprocForKlab/`                                                   |
| drv-on-proc（56号機/tamai） | `/mnt/data5/Tamai/derivatives_dmri_proc`                                                     |
| drv-on-proc（52号機/iueda） | `/mnt/data3/iueda/dwi_preproc/Pttrn_HcppMrtrxHybrid/2_16/derivatives`                        |

---

## 2_108 (IRCN)

確認日: 2026-04-08

| 項目                                       | パス                                                                         |
|:-------------------------------------------|:-----------------------------------------------------------------------------|
| sourcedata（主系）                         | `/mnt/synology1-4/HCP_RestingStateStats/2_108_IRCN/sourcedata`               |
| drv-on-share（sMRI/fMRI）                  | `/mnt/synology1-4/HCP_RestingStateStats/2_108_IRCN/derivatives/HCPpipeline/` |
| drv-on-proc（dMRI NIDP Agg、61号機/iueda） | `/mnt/data11/iueda/dwi_agg/2_108/derivatives`                                |
| drv-on-proc（dMRI NIDP Agg、55号機/iueda） | `/mnt/data12/iueda/dwi_agg/2_108/derivatives`                                |
| drv-on-share（dMRI前処理出力、55号機）      | `/mnt/data11/iueda/dwi_preproc/Pttrn_hmhybrid/2_108/derivatives`             |
| drv-on-share（SyncResults 同期先）         | `/mnt/qnapdata2/mri2024/hcp/mri4/ext2_108/`                                  |
| drv-on-share（dMRI前処理保管先）           | `/mnt/synology2-2/dMRI-Preprocessed/2_108/derivatives`                       |

---

## 3_17 (03_Cohort01_Yaesu_Parent)

確認日: 2026-04-30

| 項目                            | パス                                                                                          |
|:--------------------------------|:----------------------------------------------------------------------------------------------|
| drv-on-share（LGI/HCP_postFS）  | `/mnt/synology4-1/HCP_postFS/03_Cohort01_Yaesu_Parent/derivatives/HCPpipeline/`              |
| drv-on-proc（LGI、53号機/iueda）| `/mnt/data2/iueda/3_17/lgi_proc/derivatives`                                                  |

---

## スクリプト配備パス

  * /mnt/qnapdata3/iueda/SMriFMriPreprocForKlab
  * /mnt/qnapdata3/iueda/DMriPreprocForKlab
  * /mnt/qnapdata3/iueda/Aggregate_LGI_on_MMP1
  * /mnt/qnapdata3/iueda/Aggregate_dMRI_Features_on_MMP1
  * /mnt/qnapdata3/iueda/Aggregate_ssMRI_Features_on_MMP1
  * /mnt/qnapdata3/iueda/SyncResultsForKlab

