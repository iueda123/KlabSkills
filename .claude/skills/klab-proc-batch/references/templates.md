# バッチスクリプトテンプレート・命名規則

## dMRI 前処理（tsp不使用）

### 引数一覧

```bash
run_dmri_preproc_pipelines_for_klab.sh \
    --subject-id=<subject_id> \
    --src-of-subjects-on-share=<path> \          # sourcedata パス
    --drv-of-subjects-on-share=<path> \          # sMRI/fMRI derivatives パス（Step1の出力先）
    --drv-of-subjects-on-proc=<path> \           # 処理マシンのローカル作業ディレクトリ
    --dmri-proc-pttrn=<pattern> \                # 下記パターン表参照
    [--use-gpu=<true|false>] \
    [--should-push-drv-to-share=<true|false>] \
    [--verbose]
```

**処理パターン (`--dmri-proc-pttrn`)**:

| パターン名      | 内容                                 | 備考               |
|:----------------|:-------------------------------------|:-------------------|
| `hmhybrid`      | HCP Pipelines + MRtrix3 ハイブリッド | **研究室現行標準** |
| `normal_no_gpu` | GPU なし標準処理                     |                    |
| `normal_gpu`    | GPU あり標準処理                     |                    |
| `mrtrxbased`    | MRtrix3 ベース処理                   |                    |
| `hcpporig`      | HCP Pipelines オリジナル処理         |                    |
| `stepbystep`    | ステップバイステップ処理             |                    |
| `allatonce`     | 一括処理                             |                    |

### バッチスクリプトテンプレート

```bash
#!/bin/bash
subjects=()
subjects+=("sub-XXXXXXXXXX")
# 被験者を追加する場合は subjects+=("sub-XXXXXXXXXX") を続ける

previous_wd=$(pwd)
cd /mnt/qnapdata3/<user>/DMriPreprocForKlab

for sbjid in ${subjects[@]}; do
    ./run_dmri_preproc_pipelines_for_klab.sh \
        --subject-id=${sbjid} \
        --src-of-subjects-on-share=<src_path> \
        --drv-of-subjects-on-share=<smri_fmri_derivatives_path> \
        --drv-of-subjects-on-proc=<drv_proc_path> \
        --dmri-proc-pttrn=hmhybrid \
        --use-gpu=<true|false> \
        --should-push-drv-to-share=<true|false> \
        --verbose
done

cd ${previous_wd}
```

---

## sMRI/fMRI 前処理（tsp使用）

### 引数一覧

```bash
run_hcppipelines_for_klab.sh \
    --subject-id=<subject_id> \
    --src-of-subjects-on-share=<path> \              # sourcedata パス
    --drv-of-subjects-on-proc=<path> \               # 処理マシンのローカル作業ディレクトリ
    [--drv-of-subjects-on-share=<path>] \            # 共有先 derivatives パス
    [--skip-list=<step_range>] \                     # スキップするステップ範囲
    [--fmri-proc-pttrn=<auto|single|double|triple|no>] \
    [--should-pull-src-from-share=<true|false>] \
    [--should-pull-drv-from-share=<false|true>] \
    [--should-push-drv-to-share=<false|true>] \      # ユーザーに確認すること
    [--should-save-intermediates=<false|true>] \     # false 推奨（ストレージ節約）
    [--verbose]
```

### バッチスクリプトテンプレート

```bash
#!/bin/bash
subjects=()
subjects+=("sub-XXXXXXXXXX")

previous_wd=$(pwd)
cd /mnt/qnapdata3/<user>/SMriFMriPreprocForKlab

for sbjid in ${subjects[@]}; do
    tsp ./run_hcppipelines_for_klab.sh \
        --subject-id=${sbjid} \
        --src-of-subjects-on-share=<src_path> \
        --drv-of-subjects-on-proc=<drv_proc_path> \
        --drv-of-subjects-on-share=<drv_share_path> \
        --should-push-drv-to-share=<true|false> \
        --should-save-intermediates=false \
        --verbose
done

cd ${previous_wd}
```

---

## LGI 算出・集計（tsp使用）

### 引数一覧

```bash
startAggregationOfLgiOnMmp1ForKlab.sh \
    --subject-id=<SUBJECT_ID> \
    --drv-of-subjects-on-share=<SHARE_FOLDER_PATH> \     # HCP_postFS マウントを使うこと
    --drv-of-subjects-on-proc=<PROCESSING_FOLDER_PATH> \
    [--regname=<MSMAll|MSMSulc>] \                       # デフォルト: MSMAll
    [--should-push-drv-to-share=<false|true>] \
    [--overwrite] \
    [--debug] \
    [--verbose] \
    [--help]
```

### バッチスクリプトテンプレート

```bash
#!/bin/bash
subjects=()
subjects+=("sub-XXXXXXXXXX")

previous_wd=$(pwd)
cd /mnt/qnapdata3/<user>/Aggregate_LGI_on_MMP1

for sbjid in ${subjects[@]}; do
    tsp bash startAggregationOfLgiOnMmp1ForKlab.sh \
        --subject-id=${sbjid} \
        --drv-of-subjects-on-share=<HCP_postFS_path> \
        --drv-of-subjects-on-proc=<drv_proc_path> \
        --should-push-drv-to-share=<true|false> \
        --regname=<MSMAll|MSMSulc> \
        --verbose
done

cd ${previous_wd}
```

---

## ssMRI NIDP Agg（tsp不使用、逐次実行）

> **注意**: `--src-of-subjects-on-share` はこの処理タイプには存在しない。パス確認時に聞かないこと。

> **注意**: `--mode` オプションは廃止された。スクリプトは常に msmsulc・msmall の両モードを逐次実行し、さらに aseg.stats から subcortical volume (SubV.csv) を生成する。

### 引数一覧

```bash
agg_sMRI_NIDPs_on_MMP1.sh \
    --subject-id=<subject_id> \
    --drv-of-subjects-on-share=<path> \
    --drv-of-subjects-on-proc=<path> \
    [--should-push-rslt-to-share=<true|false>] \
    [--verbose]
```

**出力ファイル** (`<drv-of-subjects-on-proc>/<subject_id>/NIDPs/` 以下):
- `<SUBJECT_ID>_*_MSMSulc.csv` / `.pscalar.nii`
- `<SUBJECT_ID>_*_MSMAll.csv` / `.pscalar.nii`
- `<SUBJECT_ID>_SubV.csv`（aseg.stats から生成される subcortical volume）
- `<SUBJECT_ID>_aseg.stats`（アーカイブ）

**注意**: tsp 並列化は原理的に可能だが、各 agg 完了後に `syncAggRslts.sh` を走らせる必要があるため、まず逐次版で構築し並列化は後から検討する。

### バッチスクリプトテンプレート

```bash
#!/bin/bash
subjects=()
subjects+=("sub-XXXXXXXXXX")

previous_wd=$(pwd)
cd /mnt/qnapdata3/<user>/Aggregate_ssMRI_Features_on_MMP1

for sbjid in ${subjects[@]}; do
    echo ${sbjid}
    ./agg_sMRI_NIDPs_on_MMP1.sh \
        --subject-id=${sbjid} \
        --drv-of-subjects-on-share=<drv_share_path> \
        --drv-of-subjects-on-proc=<drv_proc_path> \
        --should-push-rslt-to-share=<true|false> \
        --verbose
done

cd ${previous_wd}
```

---

## dMRI NIDP Agg（tsp不使用、conda env必要）

> **注意**: `--src-of-subjects-on-share` はこの処理タイプには存在しない。パス確認時に聞かないこと。

### 引数一覧

```bash
agg_dMRI_NIDPs_on_MMP1.sh \
    --subject-id=<subject_id> \
    --drv-of-subjects-on-share=<path> \              # dMRI前処理の出力先（dwi_preproc/...）
    [--drv-of-subjects-on-share-secondary=<path>] \  # HCPpipeline derivatives
    --drv-of-subjects-on-proc=<path> \               # 作業フォルダ（dwi_agg/ 以下に別途作成）
    [--should-push-rslt-to-share=<true|false>] \
    [--species=<0|1|2>] \                            # 0=Human（デフォルト）, 1=Macaque, 2=Marmoset
    [--calc-noddi=<YES|NO>] \
    [--noddi-d-par=<value>] \                        # デフォルト 1.1e-3（皮質灰白質向け）
    [--overwrite] \
    [--verbose]
```

> **注意**: `--mode` オプションは廃止された（version 20260128〜）。スクリプトは常に MSMSulc・MSMAll の両モードを逐次実行する。

### バッチスクリプトテンプレート

```bash
#!/bin/bash
conda activate env_for_dMRIAgg

subjects=()
subjects+=("sub-XXXXXXXXXX")

previous_wd=$(pwd)
cd /mnt/qnapdata3/<user>/Aggregate_dMRI_Features_on_MMP1

for sbjid in ${subjects[@]}; do
    ./agg_dMRI_NIDPs_on_MMP1.sh \
        --subject-id=${sbjid} \
        --drv-of-subjects-on-share=<dwi_preproc_path> \
        --drv-of-subjects-on-share-secondary=<HCPpipeline_derivatives_path> \
        --drv-of-subjects-on-proc=<drv_proc_path> \
        --should-push-rslt-to-share=<true|false> \
        --verbose
done

cd ${previous_wd}
```

---

## SyncResults（tsp不使用）

### 引数一覧

```bash
syncRslts.sh \
    [--subject-id=<SUBJECT_ID>] \           # 省略時は全被験者を自動処理
    --drv-of-subjects-on-src=<path> \       # 同期元 SubjectsRoot（旧: --drv-of-subjects-on-proc）
    --drv-of-subjects-on-dst=<path> \       # 同期先 SubjectsRoot（旧: --drv-of-subjects-on-share）
    [--mode=<NIDPS|DMRI|SSMRI_NIDP|LGI|ALL>] \   # デフォルト: NIDPS
    [--keep-structure] \
    [--run] \                               # 省略時は dry-run
    [--help]
```

**同期モード（`--mode`）**:

| モード       | 同期対象                                                       |
|:-------------|:---------------------------------------------------------------|
| `NIDPS`      | `${SUBJECT_ID}/NIDPs/`（デフォルト）                           |
| `DMRI`       | dMRI関連（T1w/Diffusion/, Diffusion/, dMRI NIDPs csv/pscalar） |
| `SSMRI_NIDP` | structural MRI NIDPs（CT, CV, MM, NSA, SA, SubV等）            |
| `LGI`        | LGI NIDPs csv + stats ファイル                                 |
| `ALL`        | 上記4モードすべて                                              |

**注意**: デフォルトは dry-run。実際の同期には `--run` が必須。

### バッチスクリプトテンプレート

```bash
#!/bin/bash
subjects=()
subjects+=("sub-XXXXXXXXXX")
# 複数被験者は subjects+=("sub-XXXXXXXXXX") を続ける
# 全被験者対象なら subjects配列・ループを削除し --subject-id を省略する

previous_wd=$(pwd)
cd /mnt/qnapdata3/<user>/SyncResultsForKlab

for sbjid in ${subjects[@]}; do
    ./syncRslts.sh \
        --subject-id=${sbjid} \
        --drv-of-subjects-on-src=<drv_src_path> \
        --drv-of-subjects-on-dst=<drv_dst_path> \
        --mode=<NIDPS|DMRI|SSMRI_NIDP|LGI|ALL> \
        --run
done

cd ${previous_wd}
```

---

## スクリプト命名規則

| 処理タイプ       | 配置場所・ファイル名                                                                                                                        |
|:-----------------|:--------------------------------------------------------------------------------------------------------------------------------------------|
| dMRI 前処理      | `notes/proc_<cohort_id>_On<machine>M_<YYYYMMDD-HHMMSS>.sh`                                                                                  |
| sMRI/fMRI 前処理 | `notes/proc_<cohort_id>_On<machine>M_<YYYYMMDD-HHMMSS>.sh`                                                                                  |
| LGI              | `notes/proc_<cohort_id>_On<machine>M_MsmSulc_<YYYYMMDD-HHMMSS>.sh` または `notes/proc_<cohort_id>_On<machine>M_MsmAll_<YYYYMMDD-HHMMSS>.sh` |
| ssMRI NIDP Agg   | `notes/proc_<cohort_id>_On<machine>M_<YYYYMMDD-HHMMSS>.sh`（両モード一括実行のため MSM suffix なし）                                        |
| dMRI NIDP Agg    | `notes/proc_<cohort_id>_On<machine>M_<YYYYMMDD-HHMMSS>.sh`（両モード一括実行のため MSM suffix なし）                                        |
| SyncResults      | `notes/sync_<cohort_id>_On<machine>M_<Mode>_<YYYYMMDD-HHMMSS>.sh`（`<Mode>` は `Dmri`, `Nidps`, `SsmriNidp`, `Lgi`, `All` など）            |

例：
- `notes/proc_2_11_On56M_20260408-143022.sh`
- `notes/proc_2_11_On59M_MsmAll_20260408-143022.sh`
- `notes/proc_2_11_On61M_MsmSulc_20260408-143022.sh`
- `notes/sync_2_108_On55M_Dmri_20260408-143022.sh`

ディレクトリ構造（メインスクリプトと同階層）:

```
<repo>/
├── <main_script>.sh
├── logs/
├── notes/      
└── ...
```

---

## 実行・ログ確認

```bash
# 実行
bash <script_path>

# ログ確認（tsp使用の場合）
tsp

# ログ確認（log/ ディレクトリ）
ls /mnt/qnapdata3/<user>/<repo>/log/
tail -f /mnt/qnapdata3/<user>/<repo>/log/<subject_id>/<jobid>/...

# エラー検出
grep -r "ERROR\|FAILED" /mnt/qnapdata3/<user>/<repo>/log/<subject_id>/
```
