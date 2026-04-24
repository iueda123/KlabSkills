[INDEX](./INDEX.md)

*docs/20260401_proc-helper/research.md*

**━━━━━━━━━━━━━━━━━━━━━━━━**

# Klab Proc Helper — 調査資料

> 作成日: 2026-04-01  
> 目的: 実装計画書作成の前段階としての調査・整理

---

## 1. 解決したい問題

Klab の MRI 前処理パイプラインを適切に走らせるためのバッチスクリプト構築は、以下の要素を人手で整合させる必要があり、ミスやコストが大きい。

- 複数のネットワークストレージにまたがるデータ
- コホートによって異なるデータパス・前処理パターン
- 処理マシンごとに異なる役割・空きリソース・ソフトウェア整備状況
- ジョブキューへの投入形式（tsp 使用有無など）
- 被験者ごとのデータ欠落・処理失敗の有無

**目標**: 必要な情報をインタラクティブに確認しながら、指定コホート・指定被験者に対する処理バッチスクリプトを自動生成する CLI ツールまたは SKILL を構築する。スクリプトを組み上げる過程でユーザーが判断に迷いやすいポイント（パスの選択・tsp の要否・push オプションの判断など）を丁寧にサポートする設計とする。

---

## 2. 処理パイプライン全体像

NIDPs（神経画像由来表現型）を得るまでの処理フロー。各ステップは独立して走らせられ、依存関係さえ満たせば済んでいるステップはスキップ可能。

```
[ソースデータ (DICOM/NIfTI)]
        ↓
[Step 1] sMRI/fMRI 前処理        ← HcpPipelinesForKlab (SMriFMriPreprocForKlab/)
        │
        ├──→ [Step 2] dMRI 前処理          ← HcpPipelinesForKlab (DMriPreprocForKlab/)
        │              │
        │              └──→ [Step 5] dMRI NIDP Agg  ← Aggregate_dMRI_Features_on_MMP1
        │
        ├──→ [Step 3] LGI 算出・集計（一気通貫）  ← Aggregate_LGI_on_MMP1
        │
        └──→ [Step 4] ssMRI NIDP Agg       ← Aggregate_ssMRI_Features_on_MMP1
```

依存関係まとめ:

| ステップ | 前提ステップ |
|:---------|:-------------|
| Step 2   | Step 1       |
| Step 3   | Step 1       |
| Step 4   | Step 1       |
| Step 5   | Step 2       |

**注**: HcpPipelinesForKlab リポジトリには sMRI/fMRI 処理スクリプト群（`SMriFMriPreprocForKlab/`）と dMRI 処理スクリプト群（`DMriPreprocForKlab/`）の２群が含まれる。

---

## 3. 処理スクリプト群

### 3.1 sMRI / fMRI 前処理

- **リポジトリ**: https://github.com/iueda123/HcpPipelinesForKlab
- **エントリポイント**: `SMriFMriPreprocForKlab/run_hcppipelines_for_klab.sh`
- **配備パス例**: `/mnt/qnapdata3/${USER_NAME}/HcpPipelinesForKlab/SMriFMriPreprocForKlab/`
  - `${USER_NAME}` 部分はマシンごとに異なるため、CLI アプリとのインタラクション中にユーザー名を確認してパスを特定する。
- **処理マシン**: 主に 57号機、59号機
- **ジョブ管理**: tsp を使用

**引数一覧**:

```bash
run_hcppipelines_for_klab.sh \
    --subject-id=<subject_id> \
    --src-of-subjects-on-share=<path> \
    --drv-of-subjects-on-proc=<path> \
    [--drv-of-subjects-on-share=<path>] \
    [--skip-list=<step_range>] \
    [--fmri-proc-pttrn=<auto|single|double|triple|no>] \
    [--should-pull-src-from-share=<true|false>] \
    [--should-pull-drv-from-share=<false|true>] \
    [--should-push-drv-to-share=<false|true>]  # ← インタラクション中にユーザーへ確認する
    [--should-save-intermediates=<false|true>]  # ← false 推奨（ストレージ節約）
    [--verbose]
```

**バッチスクリプトの典型的な構造** (2_11 コホート、59号機の場合の例):

```bash
#!/bin/bash
subjects=()
subjects+=("sub-K2303271400")
subjects+=("sub-K2304101230")
# ...（被験者 ID は sourcedata/ 直下のフォルダ名から取得する。詳細は § 6 参照）

previous_wd=$(pwd)
cd /mnt/qnapdata3/${USER_NAME}/HcpPipelinesForKlab/SMriFMriPreprocForKlab

for sbjid in ${subjects[@]}; do
    tsp ./run_hcppipelines_for_klab.sh \
        --subject-id=${sbjid} \
        --src-of-subjects-on-share=/mnt/synology4-1/HCP_RestingStateStats/2_11/sourcedata \
        --drv-of-subjects-on-proc=/mnt/data1/${USER_NAME}/2_11/derivatives \
        --drv-of-subjects-on-share=/mnt/synology1-4/HCP_RestingStateStats/2_11/derivatives/HCPpipeline \
        --should-push-drv-to-share=false \
        --should-save-intermediates=false \
        --verbose
done

cd ${previous_wd}
```

スクリプトの配置場所: `SMriFMriPreprocForKlab/notes/proc_<cohort_id>_on_<machine>Machine.sh`

### 3.2 dMRI 前処理

- **リポジトリ**: https://github.com/iueda123/HcpPipelinesForKlab
- **エントリポイント**: `DMriPreprocForKlab/run_dmri_preproc_pipelines_for_klab.sh`
- **配備パス例**: `/mnt/qnapdata3/${USER_NAME}/HcpPipelinesForKlab/DMriPreprocForKlab/`
- **処理マシン**: 主に 52号機、55号機、56号機、61号機
- **ジョブ管理**: tsp 不使用（GPU との競合があるため）

**引数一覧**:

```bash
run_dmri_preproc_pipelines_for_klab.sh \
    --subject-id=<subject_id> \
    --src-of-subjects-on-share=<path> \
    --drv-of-subjects-on-share=<path> \
    --drv-of-subjects-on-proc=<path> \
    --dmri-proc-pttrn=<pattern>          # ← 下記パターン表参照
    [--use-gpu=<true|false>] \
    [--should-push-drc-to-share=<true|false>] \
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

**バッチスクリプトの典型的な構造** (2_108 コホート、55号機の場合の例):

```bash
#!/bin/bash
subjects=()
subjects+=("sub-K2010061630")
subjects+=("sub-K2103311000")
# ...

previous_wd=$(pwd)
cd /mnt/qnapdata3/${USER_NAME}/HcpPipelinesForKlab/DMriPreprocForKlab

for sbjid in ${subjects[@]}; do
    ./run_dmri_preproc_pipelines_for_klab.sh \
        --subject-id=${sbjid} \
        --src-of-subjects-on-share=/mnt/synology1-4/HCP_RestingStateStats/2_108_IRCN/sourcedata \
        --drv-of-subjects-on-share=/mnt/synology1-4/HCP_RestingStateStats/2_108_IRCN/derivatives/HCPpipeline \
        --drv-of-subjects-on-proc=/mnt/data11/${USER_NAME}/dwi_preproc/Pttrn_hmhybrid/2_108/derivatives \
        --dmri-proc-pttrn=hmhybrid \
        --use-gpu=true \
        --should-push-drc-to-share=true \
        --verbose
done

cd ${previous_wd}
```

### 3.3 LGI 算出・集計（一気通貫）

LGI 計算と MMP1 アトラスへの集計は `startAggregationOfLgiOnMmp1ForKlab.sh` が**一気通貫**で担う（別スクリプトへの分割はなく、このスクリプト1本で完結）。

- **リポジトリ**: https://github.com/iueda123/Aggregate_LGI_on_MMP1
- **エントリポイント**: `startAggregationOfLgiOnMmp1ForKlab.sh`
- **配備パス例**: `/mnt/qnapdata3/${USER_NAME}/Aggregate_LGI_on_MMP1/`
- **処理マシン**: 59号機（確認済み。53号機の役割は不明）
- **ジョブ管理**: tsp を使用

**引数一覧**:

```bash
startAggregationOfLgiOnMmp1ForKlab.sh \
    --subject-id=<SUBJECT_ID> \
    --drv-of-subjects-on-share=<SHARE_FOLDER_PATH> \
    --drv-of-subjects-on-proc=<PROCESSING_FOLDER_PATH> \
    [--regname=<MSMAll|MSMSulc>] \           # デフォルト: MSMAll
    [--should-push-drv-to-share=<false|true>] \
    [--overwrite] \
    [--debug] \
    [--verbose] \
    [--help]
```

**バッチスクリプトの典型的な構造** (3_6 コホートの場合の例):

```bash
#!/bin/bash
subjects=("sub-0001T" "sub-0002T" ...)

previous_wd=$(pwd)
cd /mnt/qnapdata3/${USER_NAME}/Aggregate_LGI_on_MMP1

for subject in ${subjects[@]}; do
    tsp bash startAggregationOfLgiOnMmp1ForKlab.sh \
        --subject-id=${subject} \
        --drv-of-subjects-on-share=/mnt/synology1-4/HCP_postFS/3_6_TS_SRPBYaesu/derivatives/HCPpipeline/ \
        --drv-of-subjects-on-proc=/mnt/data2/${USER_NAME}/3_6/derivatives \
        --should-push-drv-to-share=true \
        --regname=MSMSulc \
        --verbose
done

cd ${previous_wd}
```

> **注意**: `--drv-of-subjects-on-share` には `HCP_postFS` マウントポイントを使う（`HCP_RestingStateStats` ではない）。コホートによって異なる場合があるため、インタラクション中にユーザーに確認する。

スクリプトの配置場所: `notes/proc_<cohort_id>.sh` / `notes/proc_<cohort_id>_MSMAll.sh` 等

### 3.4 ssMRI NIDP Agg

- **リポジトリ**: https://github.com/iueda123/Aggregate_ssMRI_Features_on_MMP1
- **エントリポイント**: `agg_sMRI_NIDPs_on_MMP1.sh`
- **配備パス例**: `/mnt/qnapdata3/${USER_NAME}/Aggregate_ssMRI_Features_on_MMP1/`
- **処理マシン**: 主に 59号機
- **ジョブ管理**: tsp 不使用（for ループ逐次実行）
  - `agg_sMRI_NIDPs_on_MMP1.sh` は被験者間独立なため tsp 並列化は原理的に可能だが、後続の `syncAggRslts.sh` を各 agg 完了後に走らせる必要があり依存キューが複雑になる。まず逐次版で構築し、並列化は後から検討。

**引数一覧**:

```bash
agg_sMRI_NIDPs_on_MMP1.sh \
    --subject-id=<subject_id> \
    --drv-of-subjects-on-share=<path> \
    --drv-of-subjects-on-proc=<path> \
    [--should-push-rslt-to-share] \
    [--mode=<msmsulc|msmall>] \
    [--verbose]
```

**バッチスクリプトの典型的な構造**:

```bash
#!/bin/bash
subjects=("sub-K2404261500" "sub-K2405171500" ...)

previous_wd=$(pwd)
cd /mnt/qnapdata3/${USER_NAME}/Aggregate_ssMRI_Features_on_MMP1

for subject in ${subjects[@]}; do
    echo ${subject}
    ./agg_sMRI_NIDPs_on_MMP1.sh \
        --subject-id=${subject} \
        --drv-of-subjects-on-share=<共有サーバー derivatives パス> \
        --drv-of-subjects-on-proc=<処理マシン derivatives パス> \
        --should-push-rslt-to-share \
        --mode=msmsulc \
        --verbose

    ./syncAggRslts.sh \
        --subject-id=${subject} \
        --drv-of-subjects-on-proc=<処理マシン derivatives パス> \
        --drv-of-subjects-on-share=<qnapdata2 共有先パス> \
        --keep-structure \
        --run
done

cd ${previous_wd}
```

スクリプトの配置場所: `Notes/proc_<cohort_id>_msmsulc.sh` / `Notes/proc_<cohort_id>_msmall.sh`

### 3.5 dMRI NIDP Agg

- **リポジトリ**: https://github.com/iueda123/Aggregate_dMRI_Features_on_MMP1
- **エントリポイント**: `agg_dMRI_NIDPs_on_MMP1.sh`
- **配備パス例**: `/mnt/qnapdata3/${USER_NAME}/Aggregate_dMRI_Features_on_MMP1/`
- **処理マシン**: 主に 52号機、55号機、61号機
- **ジョブ管理**: tsp 不使用
- **conda environment 必要**: `env_for_dMRIAgg`（python=3.11 + dmri-amico）
  - 実行前に `conda activate env_for_dMRIAgg` が必要

**引数一覧**:

```bash
agg_dMRI_NIDPs_on_MMP1.sh \
    --subject-id=<subject_id> \
    --drv-of-subjects-on-share=<path> \
    [--drv-of-subjects-on-share-secondary=<path>] \
    --drv-of-subjects-on-proc=<path> \
    [--should-push-rslt-to-share] \
    [--mode=<msmsulc|msmall>] \
    [--species=<0|1|2>] \    # 0=Human（デフォルト）, 1=Macaque, 2=Marmoset
    [--calc-noddi=<YES|NO>] \
    [--noddi-d-par=<value>] \  # デフォルト 1.1e-3（皮質灰白質向け）
    [--verbose]
```

**バッチスクリプトの典型的な構造** (2_11 コホート、55号機の場合の例):

```bash
#!/bin/bash
subjects=()
subjects+=("sub-K1904081330")
# ...

previous_wd=$(pwd)
cd /mnt/qnapdata3/${USER_NAME}/Aggregate_dMRI_Features_on_MMP1

for sbjid in ${subjects[@]}; do
    ./agg_dMRI_NIDPs_on_MMP1.sh \
        --subject-id=${sbjid} \
        --drv-of-subjects-on-share=/mnt/data11/${USER_NAME}/dwi_preproc/Pttrn_hmhybrid/2_11/derivatives \
        --drv-of-subjects-on-share-secondary=/mnt/synology1-4/HCP_RestingStateStats/2_11/derivatives/HCPpipeline \
        --drv-of-subjects-on-proc=/mnt/data11/${USER_NAME}/dwi_agg/Pttrn_hmhybrid_on55M/2_11/derivatives \
        --mode=msmall \
        --verbose
done

cd ${previous_wd}
```

> **注意**: `--drv-of-subjects-on-share` には dMRI 前処理の出力先（`dwi_preproc/...`）を指定し、`--drv-of-subjects-on-share-secondary` に HCPpipeline の derivatives を指定する。作業フォルダ（`--drv-of-subjects-on-proc`）は `dwi_agg/` 以下に別途作成する。

スクリプトの配置場所: `Notes/proc_<cohort_id>_on_<machine>M.sh`

---

## 4. 処理マシン一覧

ノート類の記述から確認できた用途を整理した。

| 号機 | IPアドレス    | 確認できた用途                             | 根拠ファイル                                          |
|:-----|:--------------|:-------------------------------------------|:------------------------------------------------------|
| 52   | 192.168.50.52 | sMRI/fMRI前処理、dMRI前処理、dMRI NIDP Agg | 2_11/Note_04, 2_11/Note_06, 2_16/Note_03              |
| 53   | 192.168.50.53 | 用途不明（LGI 推定だったが 59 で確認）     | -                                                     |
| 55   | 192.168.50.55 | dMRI前処理、dMRI NIDP Agg                  | 2_11/Note_03, 2_11/Note_04, 2_108/Note_03             |
| 56   | 192.168.50.56 | dMRI前処理                                 | 2_16/Note_03                                          |
| 57   | 192.168.50.57 | sMRI/fMRI前処理                            | 2_11/Note_02                                          |
| 59   | 192.168.50.59 | sMRI/fMRI前処理、ssMRI NIDP Agg、LGI算出   | 2_11/Note_02, 2_11/Note_04, 3_6/Note_02, 5_26/Note_04 |
| 61   | 192.168.50.61 | dMRI前処理、dMRI NIDP Agg                  | 2_11/Note_03                                          |

> 51, 54, 58, 60 は記録中に登場しておらず用途不明。

### 処理マシンへの SSH アクセスと事前確認

CLI アプリはインタラクション中にユーザーへ SSH パスワードを尋ね、それを使ってワークステーションの状況を確認する。調査・開発段階では `key.env`（git 管理外）にパスワードを記載して利用する。

```bash
# 開発時のみ: key.env に SSH_USER と SSH_PASSWORD を設定後 source する
source key.env

# ストレージ空き容量（作業フォルダ選択に使用）
ssh -p 22 ${SSH_USER}@192.168.50.59 "df -h | grep '/mnt/data'"

# GPU 有無（dMRI に必要）
ssh -p 22 ${SSH_USER}@192.168.50.59 "nvidia-smi -L 2>/dev/null || echo 'No GPU'"

# conda environment の確認
ssh -p 22 ${SSH_USER}@192.168.50.59 "conda env list"

# ユーザー名確認（スクリプト配備パス特定のため）
ssh -p 22 ${SSH_USER}@192.168.50.59 "whoami && ls /mnt/qnapdata3/"

# 各スクリプトの存在確認（ワイルドカードでユーザー名をカバー）
ssh -p 22 ${SSH_USER}@192.168.50.59 \
    "ls /mnt/qnapdata3/*/HcpPipelinesForKlab/SMriFMriPreprocForKlab/run_hcppipelines_for_klab.sh"
ssh -p 22 ${SSH_USER}@192.168.50.59 \
    "ls /mnt/qnapdata3/*/Aggregate_LGI_on_MMP1/startAggregationOfLgiOnMmp1ForKlab.sh"
ssh -p 22 ${SSH_USER}@192.168.50.59 \
    "ls /mnt/qnapdata3/*/Aggregate_dMRI_Features_on_MMP1/agg_dMRI_NIDPs_on_MMP1.sh"

# tsp の有無
ssh -p 22 ${SSH_USER}@192.168.50.59 "which tsp"
```

---

## 5. ストレージ構成

### ネットワークストレージ（共有）

| マウントポイント                          | 役割                                              |
|:------------------------------------------|:--------------------------------------------------|
| `/mnt/synology4-1/HCP_RestingStateStats/` | sMRI/fMRI 処理済みデータバックアップ（主系）      |
| `/mnt/synology1-4/HCP_RestingStateStats/` | sMRI/fMRI 処理済みデータバックアップ（旧/移行中） |
| `/mnt/synology1-4/HCP_postFS/`            | LGI 処理に使われる derivatives の別マウント       |
| `/mnt/synology3-2/HCP_OrigVer/`           | 旧バージョン処理済みデータ                        |
| `/mnt/qnapdata2/mri2024/hcp/mri4/`    | MSMSulc/MSMAll 共有先（ssMRI NIDP Agg 出力先）    |
| `/mnt/KLab_DataVol3/iueda/`               | NIDPs 計算プロジェクトフォルダ                    |

> マウントスクリプト（`~/Dropbox/BashScripts/mountKlabQnap.sh` 等）は 59 号機上でも見つからなかった。マウント方法の詳細は別途確認が必要。

### 処理マシンのローカル作業ストレージ

どのストレージを作業フォルダとして使うかはコホートや時期によって異なる。CLI アプリはインタラクション中に以下を行う:

1. `df -h | grep /mnt/data` で各ストレージの空き容量を SSH 経由で取得・提示
2. 処理タイプごとのおおよその必要容量（下表）と比較してユーザーの選択を助ける
3. ユーザーが選択した `/mnt/dataX/` 配下に作業フォルダを作成

**59号機のストレージ状況** (2026-04-01 時点):

| ストレージ   | 容量 | 使用率 | 空き  |
|:-------------|:----:|:------:|:-----:|
| `/mnt/data1` | 15T  |  97%   | 488G  |
| `/mnt/data2` | 15T  |  93%   | 1006G |

**処理タイプ別のおおよその必要容量** (要精査・SSH 接続後に実データから確認):

| 処理タイプ       | 1被験者あたりの概算 | 備考                       |
|:-----------------|:-------------------:|:---------------------------|
| sMRI/fMRI 前処理 |       〜10 GB       | 中間ファイル保存なしの場合 |
| dMRI 前処理      |       〜20 GB       | パターンや保存設定による   |
| LGI 算出・集計   |       〜1 GB        | -                          |
| ssMRI NIDP Agg   |      〜数百 MB      | -                          |
| dMRI NIDP Agg    |      〜数百 MB      | -                          |

---

## 6. コホートデータ構造

コホートの設定情報は以下の2種類のリポジトリで管理されている。いずれもあくまで過去の作業記録であり、確定値ではないことに注意する。SSH 接続が可能になった際に実フォルダを確認し、コホートごとの実パスを別ファイル（例: `docs/20260401_proc-helper/cohort_paths.md`）として整備することを推奨する。

### (A) ProcessingStatus cohort JSON (`settings/ProcessingStatus/cohort_jsons/<cohort_id>.json`)

データパス（`SubjectsRoots`）、前処理パターン（`PreprocPattern`）、おおよその被験者数が記録されている。スクリプトのパス情報を確認する際の参考値として使う。

```json
{
  "Information_From_SpreadSheet": {
    "DATASET_ID": "2_11",
    "PreprocPattern_IU": "T2W-Extant_SEF-Extant",
    "n": "527"
  },
  "SubjectsRoots": {
    "SRC_OF_SUBJECTS_ON_SHARE_1": "/mnt/synology4-1/HCP_RestingStateStats/2_11/sourcedata",
    "DRV_OF_SUBJECTS_ON_SHARE_1": "/mnt/synology1-4/HCP_RestingStateStats/2_11/derivatives/HCPpipeline",
    "DRV_OF_SUBJECTS_ON_SHARE_4": "/mnt/qnapdata2/mri2024/hcp/mri4/ext2_11"
  }
}
```

### (B) ProcCompletionChecker2 Config (`KlabProcCompletionChecker/settings/ProcCompletionChecker2/Config_<cohort_id>.json`)

より詳細な被験者リスト（`SubjectList`）と、各処理ステップで確認すべき成果物のパス（`FolderToBeScanned`）が記録されている。被験者 ID の網羅的な一覧として参考になる。

```json
{
  "DatasetName": "2_11",
  "SubjectList": ["sub-K2009231530", "sub-K2009241500", ...],
  "FolderToBeScanned": {
    "HCP_PIPE_01_TO_03": "/mnt/synology4-1/HCP_RestingStateStats/2_11/derivatives/HCPpipeline/",
    "NIDP_AGG_SSMRI_MSMSULC": "/mnt/qnapdata2/mri2024/hcp/mri4/ext2_11",
    "LGI_CALC_STEP": "/mnt/synology4-1/HCP_RestingStateStats/2_11/derivatives/HCPpipeline/"
  }
}
```

### 被験者リストの取得方針

JSON の `SubjectList` / `Subjects` は参考値にとどめ、**実際の実装では `sourcedata/` 直下のフォルダ名からリアルタイムに取得**することを優先する。JSON と実データの乖離がしばしば発生しているため。

被験者フォルダの自動判定方針:
- `sourcedata/` の子フォルダの中には管理用フォルダ（スクリプト、ログ等）が混在する場合がある
- 被験者フォルダの判別には以下の基準を組み合わせる:
  1. **命名パターン**: `sub-` プレフィックス、または `sub-K` + 日付時刻形式などの正規表現マッチ
  2. **内部構造**: `anat/`、`func/`、`dwi/` などの BIDS 標準サブフォルダの存在確認

### 前処理パターン種別

| PreprocPattern_IU                      | 内容                             |
|:---------------------------------------|:---------------------------------|
| `T2W-Extant_SEF-Extant` / `T2wY_TpUpY` | HCPstyle（T1w + T2w + SEF あり） |
| `HCPstyle_T1w_T2w_only`                | HCPstyle（T1w + T2w のみ）       |
| `LegacyStyle_with_Topup`               | LegacyStyle + Topup              |
| `LegacyStyle_T1w_only`                 | LegacyStyle + T1w のみ           |

---

## 7. ジョブ管理とログ参照

tsp（task spooler）による並列実行が必要かどうかは処理タイプによって異なる:

| 処理タイプ       |  tsp   |     conda env     | 備考                                  |
|:-----------------|:------:|:-----------------:|:--------------------------------------|
| sMRI/fMRI 前処理 |  使用  |       不要        | GPU 等を並列に占有して高速化          |
| LGI 算出・集計   |  使用  |       不要        | 同上                                  |
| dMRI 前処理      | 不使用 |       不要        | GPU との競合があるため tsp 非対応     |
| ssMRI NIDP Agg   | 不使用 |       不要        | for ループ逐次（sync タイミング制御） |
| dMRI NIDP Agg    | 不使用 | `env_for_dMRIAgg` | dmri-amico ライブラリが必要           |

### ログ参照の工夫

tsp を使う場合はジョブログが埋もれる問題がある。各スクリプト群は `log/` ディレクトリにログを別途出力する機構を持っているため、CLI アプリから以下を提供したい:

- tsp キューの状況表示: `tsp` コマンドの出力を整形して提示
- 最新ログの表示: `log/` 以下の最新ファイルを SSH 経由で `tail -f` 相当で参照できる仕組み
- エラー検出: ログ中の ERROR/FAILED キーワードを自動抽出してユーザーに通知

---

## 8. バッチスクリプト構築の典型的フローとユーザー支援ポイント

CLIアプリはユーザーが判断に迷いやすい各ステップで適切な情報を提示し、入力を補助する。

```
① コホート ID 指定 (例: 2_11)
   ▶ サポート: ProcessingStatus cohort JSON / ProcCompletionChecker2 Config に記録されている
     コホート一覧を表示し、選択を補助する。
        ↓
② 処理タイプ選択
     (sMRI/fMRI 前処理 / dMRI 前処理 / LGI 算出・集計 / ssMRI NIDP Agg / dMRI NIDP Agg)
   ▶ サポート: 依存関係（§2）を表示し、前提ステップが未完の場合は警告する。
        ↓
③ 処理マシン選択
   ▶ サポート: 処理タイプに対応するマシン候補（§4）を提示し、SSH 接続して
     各ストレージの空き容量（df -h）を取得・表示する。
     処理タイプ別の概算必要容量（§5）と比較してユーザーの選択を助ける。
        ↓
④ SSH パスワード入力 & マシン状況確認
   ▶ サポート: 入力されたパスワードで SSH 接続し以下を自動確認・提示する:
     - ストレージ空き容量
     - スクリプトの配備状況（存在する/しない）
     - conda env の有無（dMRI NIDP Agg の場合）
     - ユーザー名（${USER_NAME} の特定）
     - tsp の有無
        ↓
⑤ パス確認
   ▶ サポート: コホート JSON の SubjectsRoots / FolderToBeScanned を参考値として
     提示し、実在するパスをユーザーに確認させる（SSH で ls して検証）。
   - src-of-subjects-on-share / drv-of-subjects-on-share / drv-of-subjects-on-proc
   - --should-push-drv-to-share の true/false をユーザーに確認する
        ↓
⑥ 被験者リスト確定
   ▶ サポート: sourcedata/ 直下のフォルダ名から被験者 ID を自動取得。
     子フォルダが被験者フォルダかどうかは命名パターン（`sub-` プレフィックス等）と
     内部構造（anat/, func/, dwi/ の存在）で自動判定する。
     ProcCompletionChecker2 Config の SubjectList をフォールバックとして提示。
     - 特定被験者のみ指定するオプション（ID リスト入力 or ファイル指定）
     - 処理済み除外オプション（ProcCompletionChecker2 との連携）
        ↓
⑦ オプション確認
   ▶ サポート: 処理タイプから tsp 使用有無・conda env 要否を自動判断して提示。
   - skip-list（処理ステップ範囲）: 既存成果物がある場合に有用。スキップ範囲を提案。
   - fmri-proc-pttrn: sourcedata の構造から auto 判断を試みる。
   - dmri-proc-pttrn: マシンの GPU 有無から推奨パターン（hmhybrid 等）を提案。
        ↓
⑧ バッチスクリプト出力 & 実行確認
   ▶ サポート: スクリプトの配置場所（notes/、Notes/）と命名規則も合わせて提示。
     出力後に「このスクリプトを実行しますか？」と確認してから投入する。
     実行後はログ参照コマンドをユーザーに提示する（§7 参照）。
```

---

## 9. 既存の関連ツール

| ツール                        | 場所                                                         | 役割                                 |
|:------------------------------|:-------------------------------------------------------------|:-------------------------------------|
| ProcCompletionChecker2        | KlabWorkNotes（このリポジトリ）                              | 処理完了状況の一覧・確認             |
| ProcessingStatus cohort JSONs | `settings/ProcessingStatus/cohort_jsons/`                    | コホートのパス・被験者情報（参考値） |
| ProcCompletionChecker2 Config | `KlabProcCompletionChecker/settings/ProcCompletionChecker2/` | より詳細な被験者リストと成果物パス   |

---

## 10. 未整理・要調査事項

- [ ] コホートごとの実パス整備（SSH 接続時に実フォルダを確認し `cohort_paths.md` として整備）
- [ ] 処理タイプ別の必要ストレージ容量の精査（実データから確認）
- [ ] 53号機の用途・IP アドレスの確認
- [ ] conda environment（`env_for_dMRIAgg`）の各マシン整備状況確認
- [ ] ネットワークストレージのマウントスクリプトの場所確認

---

## 11. 範囲外（このツールでは扱わない）

- 処理進捗把握 → ProcCompletionChecker2 が担当
- 結果の QC（異常値チェック、HexTileMap 等）
- NIDPs 生成後の統計解析

**━━━━━━━━━━━━━━━━━━━━━━━━**

*docs/20260401_proc-helper/research.md*

[INDEX](./INDEX.md)
