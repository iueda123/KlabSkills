# パイプライン・マシン・ストレージ参照

## 処理パイプラインの依存関係

```
Step 1: sMRI/fMRI 前処理  (SMriFMriPreprocForKlab)
  ├─ Step 2: dMRI 前処理     (DMriPreprocForKlab)
  │    └─ Step 5: dMRI NIDP Agg  (Aggregate_dMRI_Features_on_MMP1)
  ├─ Step 3: LGI 算出・集計  (Aggregate_LGI_on_MMP1)
  └─ Step 4: ssMRI NIDP Agg  (Aggregate_ssMRI_Features_on_MMP1)

Step 6: SyncResults  (SyncResultsForKlab)
  ※ Step 1〜5 のいずれかの完了後に実行。対象データに応じて --mode を選ぶ。
```

## dataset-id とログパスの規則

全処理タイプの主要スクリプトは `--dataset-id`（英数字・`.`・`_`・`-` のみ）を必須引数として要求する。
ログはスクリプトと同じリポジトリ内の `logs/<dataset_id>/<subject_id>/<プロセスID>/` 以下に生成される。
特にユーザーからの指定がない限り、`--dataset-id` にはコホートIDをそのまま使う。

## ジョブ管理・conda env

| 処理タイプ       |  tsp   |     conda env     |
|:-----------------|:------:|:-----------------:|
| sMRI/fMRI 前処理 |  使用  |       不要        |
| LGI 算出・集計   |  使用  |       不要        |
| dMRI 前処理      | 不使用 |       不要        |
| ssMRI NIDP Agg   | 不使用 |       不要        |
| dMRI NIDP Agg    | 不使用 | `env_for_dMRIAgg` |
| SyncResults      | 不使用 |       不要        |

## 処理タイプ別の推奨マシン

| 処理タイプ       | 推奨マシン（号機）                 |
|:-----------------|:-----------------------------------|
| sMRI/fMRI 前処理 | 57, 59                             |
| dMRI 前処理      | 52, 55, 56, 61                     |
| LGI 算出・集計   | 59, 53                             |
| ssMRI NIDP Agg   | 59                                 |
| dMRI NIDP Agg    | 52, 55, 61                         |
| SyncResults      | 任意（対象データが存在するマシン） |

## マシンIPアドレスと確認済み用途

| 号機 | IP            | 確認済み用途                               |
|:-----|:--------------|:-------------------------------------------|
| 52   | 192.168.50.52 | sMRI/fMRI前処理、dMRI前処理、dMRI NIDP Agg |
| 53   | 192.168.50.53 | LGI算出（2026-04-30 コホート3_17で動作確認）|
| 55   | 192.168.52.55 | dMRI前処理、dMRI NIDP Agg                  |
| 56   | 192.168.50.56 | dMRI前処理                                 |
| 57   | 192.168.50.57 | sMRI/fMRI前処理                            |
| 59   | 192.168.50.59 | sMRI/fMRI前処理、ssMRI NIDP Agg、LGI算出   |
| 61   | 192.168.50.61 | dMRI前処理、dMRI NIDP Agg                  |

## 処理タイプ別の概算必要容量（1被験者あたり）

| 処理タイプ       |   概算   | 備考                       |
|:-----------------|:--------:|:---------------------------|
| sMRI/fMRI 前処理 | 〜10 GB  | 中間ファイル保存なしの場合 |
| dMRI 前処理      | 〜20 GB  | パターンや保存設定による   |
| LGI 算出・集計   |  〜1 GB  |                            |
| ssMRI NIDP Agg   | 〜数百MB |                            |
| dMRI NIDP Agg    | 〜数百MB |                            |

---

## SSH 経由のマシン状況確認コマンド

```bash
# ストレージ空き容量（作業フォルダ選択に使用）
ssh -p 22 klab@192.168.50.XX "df -h | grep '/mnt/data'"

# GPU 有無（dMRI に必要）
ssh -p 22 klab@192.168.50.XX "nvidia-smi -L 2>/dev/null || echo 'No GPU'"

# conda environment の確認
ssh -p 22 klab@192.168.50.XX "conda env list"

# ユーザー名確認（スクリプト配備パス特定のため）
ssh -p 22 klab@192.168.50.XX "whoami && ls /mnt/qnapdata3/"

# 各スクリプトの存在確認
ssh -p 22 klab@192.168.50.XX \
    "ls /mnt/qnapdata3/*/SMriFMriPreprocForKlab/run_smri_fmri_preproc_pipelines_for_klab.sh"
ssh -p 22 klab@192.168.50.XX \
    "ls /mnt/qnapdata3/*/DMriPreprocForKlab/run_dmri_preproc_pipelines_for_klab.sh"
ssh -p 22 klab@192.168.50.XX \
    "ls /mnt/qnapdata3/*/Aggregate_LGI_on_MMP1/startAggregationOfLgiOnMmp1ForKlab.sh"
ssh -p 22 klab@192.168.50.XX \
    "ls /mnt/qnapdata3/*/Aggregate_dMRI_Features_on_MMP1/agg_dMRI_NIDPs_on_MMP1.sh"
ssh -p 22 klab@192.168.50.XX \
    "ls /mnt/qnapdata3/*/Aggregate_ssMRI_Features_on_MMP1/agg_sMRI_NIDPs_on_MMP1.sh"
ssh -p 22 klab@192.168.50.XX \
    "ls /mnt/qnapdata3/*/SyncResultsForKlab/syncRslts.sh"

# tsp の有無
ssh -p 22 klab@192.168.50.XX "which tsp"
```

---

## ネットワークストレージ（共有）マウントポイント

| マウントポイント                          | 役割                                              |
|:------------------------------------------|:--------------------------------------------------|
| `/mnt/synology4-1/HCP_RestingStateStats/` | sMRI/fMRI 処理済みデータバックアップ（主系）      |
| `/mnt/synology1-4/HCP_RestingStateStats/` | sMRI/fMRI 処理済みデータバックアップ（旧/移行中） |
| `/mnt/synology1-4/HCP_postFS/`            | LGI 処理に使われる derivatives の別マウント       |
| `/mnt/synology3-2/HCP_OrigVer/`           | 旧バージョン処理済みデータ                        |
| `/mnt/qnapdata2/mri2024/hcp/mri4/`        | MSMSulc/MSMAll 共有先（ssMRI NIDP Agg 出力先）    |
| `/mnt/KLab_DataVol3/iueda/`               | NIDPs 計算プロジェクトフォルダ                    |
| `/mnt/synology2-2/dMRI-Preprocessed/<dataset>/derivatives` | dMRI前処理結果保管先              |

---

## パス指定の注意事項

- dMRI前処理の `--drv-of-subjects-on-share` には **sMRI/fMRI 処理済み derivatives** を指定する（dMRI自身の出力先ではない）。
- LGI の `--drv-of-subjects-on-share` には **`HCP_postFS` マウントポイント**を使う（`HCP_RestingStateStats` ではない）。コホートによって異なる場合があるためユーザーに確認する。
- dMRI NIDP Agg の `--drv-of-subjects-on-share` には dMRI前処理の出力先（`dwi_preproc/...`）を、`--drv-of-subjects-on-share-secondary` に HCPpipeline derivatives を指定する。

---

## 被験者ID判定ルール（sourcedata/ から自動取得する場合）

`sourcedata/` 直下には管理用フォルダが混在することがある。被験者フォルダの判定には以下を組み合わせる：

1. **命名パターン**: `sub-` プレフィックス、または `sub-K` + 日付時刻形式の正規表現マッチ
2. **内部構造**: `anat/`、`func/`、`dwi/` などの BIDS 標準サブフォルダの存在確認

SSH 経由で取得：
```bash
ssh -p 22 klab@192.168.50.XX "ls <src-of-subjects-on-share> | grep '^sub-'"
```

**JSON の SubjectList はあくまで参考値**。JSON と実データの乖離が生じることがあるため、実装では `sourcedata/` からのリアルタイム取得を優先する。

---

## PreprocPattern 種別

| PreprocPattern_IU                      | 内容                             |
|:---------------------------------------|:---------------------------------|
| `T2W-Extant_SEF-Extant` / `T2wY_TpUpY` | HCPstyle（T1w + T2w + SEF あり） |
| `HCPstyle_T1w_T2w_only`                | HCPstyle（T1w + T2w のみ）       |
| `LegacyStyle_with_Topup`               | LegacyStyle + Topup              |
| `LegacyStyle_T1w_only`                 | LegacyStyle + T1w のみ           |
