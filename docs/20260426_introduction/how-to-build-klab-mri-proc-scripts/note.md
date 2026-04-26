# KLab で MRI 処理 batch スクリプトを手動で組む方法

この文書は、KLab で MRI 処理用の batch スクリプトを**人手で組めるようになる**ための導入資料です。
このレポジトリ自体はAI用ですが、メイン文書 [`.claude/skills/klab-proc-batch/SKILL.md`](/media/iu/STORAGE/__GitHub__/KlabSkills/.claude/skills/klab-proc-batch/SKILL.md) に集約されている実務知識を新メンバーが理解できる形で表現したものになります。


## 1. まず理解すべきこと

klab MRI 処理の batch スクリプト作成は、単位単にテンプレートへ文字列を埋める作業ではない。
実際には、次の 4 つを毎回正しく判断する必要がある。

1. どの処理を走らせるのか
2. どのマシンで走らせるのか
3. どの入力パスと出力パスを使うのか
4. どの被験者に対して実行するのか

この 4 つの判断を誤ると、典型的には次の問題が起こる。

- 前段の処理が終わっていないのに次段の処理を始めてしまう
- 共有ストレージ上の `sourcedata` と `derivatives` を取り違える
- dMRI の入力に dMRI 自身の出力先を入れてしまう
- 処理対象外のフォルダまで subject として回してしまう
- 結果の push/sync 先を誤る

つまり、batch スクリプト作成とは「研究室の処理ルールを shell script に落とす作業」になります。

## 2. 処理パイプラインの全体像

KLab で想定している主な処理系列は次の通りである。

```text
Step 1: sMRI/fMRI 前処理
  ├─ Step 2: dMRI 前処理
  │    └─ Step 5: dMRI NIDP Agg
  ├─ Step 3: LGI 算出・集計
  └─ Step 4: ssMRI NIDP Agg

Step 6: SyncResults
```

重要なのは、**後段の処理ほど前段の成果物に依存する**という点である。

- dMRI 前処理は、sMRI/fMRI 前処理の derivatives を参照する
- LGI は、HCP 系の postFS 出力を参照する
- ssMRI NIDP Agg は、sMRI/fMRI 前処理の結果を集計する
- dMRI NIDP Agg は、dMRI 前処理結果に加えて HCP pipeline derivatives も参照する
- SyncResults は、どこかで生成済みの結果を共有先へ同期するための後処理である

この依存関係を理解せずに script を書くと、引数自体は正しく見えても処理は破綻する。

## 3. 手動作成の基本原則

手動で組むときは、必ず次の順番で情報を確定させる。

1. 担当者 ID を決める
2. 処理タイプを決める
3. コホート ID を決める
4. 処理マシンを決める
5. マシン上のスクリプト配備先を確認する
6. 入出力パスを 1 項目ずつ確認する
7. 被験者リストを確定する
8. 処理オプションを確定する
9. shell script として整形する
10. 転送、実行、ログ確認を行う

この順番が大事である。

## 4. 処理タイプごとの特徴

### 4.1 sMRI/fMRI 前処理

- 研究室のパイプラインの起点になる処理
- `tsp` を使って投げても良い。
- 主に 57 号機、59 号機が候補
- `--should-save-intermediates=false` を基本にする。このオプションはデバック用。

### 4.2 dMRI 前処理

- sMRI/fMRI 前処理の derivatives を参照する
- `tsp` は使わない（並列処理方法未確立のため）
- 52, 55, 56, 61 号機が候補
- GPU 利用可否や `--dmri-proc-pttrn` を確認する必要がある

### 4.3 LGI 算出・集計

- HCP 系の postFS 出力を使う
- `tsp` を使う
- 主に 59 号機
- `--regname` は `MSMAll` または `MSMSulc`

### 4.4 ssMRI NIDP Agg

- `tsp` は使わない
- 各 subject の集計後に `syncAggRslts.sh` を回すことが多い
- 主に 59 号機

### 4.5 dMRI NIDP Agg

- `conda activate env_for_dMRIAgg` が必要
- dMRI 前処理出力と HCP pipeline derivatives の両方を使う
- 52, 55, 61 号機が候補


### 4.6 SyncResults

- 既存の計算結果を同期する後処理
- `--mode` によって同期対象が変わる
- dry-run か本実行かを意識する

## 5. 作業の実際

ログ確認がしやすいように共有ストレージサーバー qnapdata3 に処理スクリプトを置き、実際の処理は5X号機、6X号機上でやることをおすすめします。

### 5.1 担当者 ID を決める

担当者 ID は、主に `/mnt/qnapdata3/<user>/` 以下のパス解決に使う。

例:

- `iueda`
- `tamai`

ここを間違えると、スクリプト本体があるリポジトリの場所も、`cd` 先も全部ずれる。

### 5.2 処理タイプを決める

まず「何をやりたいのか」を明確にする。

- sMRI/fMRI を前処理したい
- dMRI を前処理したい
- LGI を集計したい
- ssMRI NIDP を集計したい
- dMRI NIDP を集計したい
- 結果を同期したい

この時点で、必要な入力と出力の種類がほぼ決まる。

### 5.3 コホート ID を決める

コホート ID は、共有ストレージ上のパスを引く起点になる。
具体的な番号はラボ内共有スプレッドシートを参照すること。
以下も参考になる： [`.claude/skills/klab-proc-batch/references/cohort_paths.md`](/media/iu/STORAGE/__GitHub__/KlabSkills/.claude/skills/klab-proc-batch/references/cohort_paths.md) を参照する。

例:

- `2_11`
- `2_16`
- `2_108`

注意:

- `SKILL.md` では `cohort_jsons` 参照も前提にしているが、このリポジトリには現時点でそのディレクトリがない
- したがって実務上は `cohort_paths.md` を参考にしつつ、最終的には実機のディレクトリを確認する

### 5.4 処理マシンを決める

推奨マシンは [`.claude/skills/klab-proc-batch/references/pipeline.md`](/media/iu/STORAGE/__GitHub__/KlabSkills/.claude/skills/klab-proc-batch/references/pipeline.md) に整理されている。

目安は次の通り。

| 処理タイプ | 主な候補 |
|:--|:--|
| sMRI/fMRI 前処理 | 57, 59 |
| dMRI 前処理 | 52, 55, 56, 61 |
| LGI 算出・集計 | 59 |
| ssMRI NIDP Agg | 59 |
| dMRI NIDP Agg | 52, 55, 61 |
| SyncResults | 対象データがあるマシン |

選ぶときは、必ず空き容量や GPU の有無を確認する。

```bash
ssh -p 22 klab@192.168.50.XX "df -h | grep '/mnt/data'"
ssh -p 22 klab@192.168.50.XX "nvidia-smi -L 2>/dev/null || echo 'No GPU'"
ssh -p 22 klab@192.168.50.XX "which tsp"
```

考え方:

- sMRI/fMRI は `tsp` のあるマシンが望ましい
- dMRI は GPU を使う設定にするなら `nvidia-smi` が通るかを確認する
- NIDP 集計は巨大ではないが、入力と出力の置き場の整合性が大事

### 5.5 マシン上のスクリプト配備先を確認する

手元で batch スクリプトを書いても、マシン上に呼び出し先 script がなければ動かない。
そのため、まず本体 repository の存在を確認する。

```bash
ssh -p 22 klab@192.168.50.XX \
  "ls /mnt/qnapdata3/*/SMriFMriPreprocForKlab/run_hcppipelines_for_klab.sh"

ssh -p 22 klab@192.168.50.XX \
  "ls /mnt/qnapdata3/*/DMriPreprocForKlab/run_dmri_preproc_pipelines_for_klab.sh"
```

見つからない場合は、対象 repository を `/mnt/qnapdata3/<user>/` 配下へ clone する。

例:

```bash
cd /mnt/qnapdata3/<user>/
git clone https://github.com/iueda123/DMriPreprocForKlab
```

## 6. パスをどう決めるか

### 6.1 最重要の考え方

手動作成で一番事故が多いのはパス指定である。
そのため、次の順で **1 項目ずつ** 確認する。

1. `--src-of-subjects-on-share`
2. `--drv-of-subjects-on-share`
3. `--drv-of-subjects-on-proc`
4. `--should-push-*-to-share`

一度に全部決めない。
1 個ずつ「これは何の置き場か」を言葉で説明しながら埋めるのが安全である。

### 6.2 `--src-of-subjects-on-share`

これは通常、共有ストレージ上の `sourcedata` を指す。

例:

```text
/mnt/synology4-1/HCP_RestingStateStats/2_11/sourcedata
```

ただし、次の処理では **そもそも存在しない**。なぜ存在しないかは各スクリプトの役割を考えてください。

- ssMRI NIDP Agg
- dMRI NIDP Agg

つまり、その 2 種類の script を書くときに `src` を入れ始めたら、最初から認識がずれている。

### 6.3 `--drv-of-subjects-on-share`

これは「共有側の derivatives」だが、処理タイプごとに中身が違う。

- sMRI/fMRI 前処理では、共有先の HCP pipeline derivatives
- dMRI 前処理では、**sMRI/fMRI 前処理済み derivatives**
- LGI では、**`HCP_postFS` マウント**
- dMRI NIDP Agg では、**dMRI 前処理の出力先**

特に dMRI 前処理と dMRI NIDP Agg は混同しやすい。

- dMRI 前処理の `drv-on-share` は「dMRI の入力として参照する HCP 系 derivatives」
- dMRI NIDP Agg の `drv-on-share` は「dMRI 前処理の結果」

### 6.4 `--drv-of-subjects-on-share-secondary`

これは dMRI NIDP Agg で使う追加入力で、HCP pipeline derivatives を入れる。
つまり dMRI NIDP Agg は、一次入力と二次入力の 2 系統を使う。

### 6.5 `--drv-of-subjects-on-proc`

これは処理マシン上のローカル作業ディレクトリである。
共有ストレージではなく、各号機の `/mnt/data*` 以下を使うことが多い。

例:

```text
/mnt/data5/Tamai/derivatives_dmri_proc
/mnt/data11/iueda/dwi_preproc/Pttrn_hmhybrid/2_108/derivatives
/mnt/data11/iueda/dwi_agg/2_108/derivatives
```

ここは、処理タイプごとにディレクトリ設計が違う。
過去の script や [`.claude/skills/klab-proc-batch/output/`](/media/iu/STORAGE/__GitHub__/KlabSkills/.claude/skills/klab-proc-batch/output) の実例も参考にしてよい。

## 7. 被験者リストの作り方

### 7.1 基本方針

subject list は JSON やメモだけに頼らず、なるべく実データから取る。

```bash
ssh -p 22 klab@192.168.50.XX "ls <src_path> | grep '^sub-'"
```

ただし、`sourcedata/` 直下には管理用フォルダが混ざることがある。
そのため、次の観点で subject らしさを判断する。

1. `sub-` で始まるか
2. BIDS 的な `anat/`, `func/`, `dwi/` があるか

### 7.2 script への書き方

batch script では、subject を bash 配列で持つことが多い。

```bash
subjects=()
subjects+=("sub-XXXXXXXXXX")
subjects+=("sub-YYYYYYYYYY")
```

この形式にしておくと、for ループへ自然に流し込める。

## 8. 処理オプションの決め方

### 8.1 `tsp` を使うか

処理タイプによって異なる。

| 処理タイプ | tsp |
|:--|:--:|
| sMRI/fMRI 前処理 | 使用 |
| LGI 算出・集計 | 使用 |
| dMRI 前処理 | 不使用 |
| ssMRI NIDP Agg | 不使用 |
| dMRI NIDP Agg | 不使用 |
| SyncResults | 不使用 |

### 8.2 conda environment が必要か

通常は不要だが、dMRI NIDP Agg だけは `env_for_dMRIAgg` を使う。

```bash
conda activate env_for_dMRIAgg
```

### 8.3 dMRI 前処理の `--dmri-proc-pttrn`

候補はいくつかあるが、研究室での現行標準は `hmhybrid` である。

```text
hmhybrid
normal_no_gpu
normal_gpu
mrtrxbased
hcpporig
stepbystep
allatonce
```

特別な理由がなければ、まず `hmhybrid` を疑う。

### 8.4 dMRI 前処理の `--use-gpu`

GPU があるマシンで、かつその run が GPU 利用前提なら `true` を入れる。
曖昧なときは `nvidia-smi -L` を確認してから決める。

### 8.5 LGI / NIDP の MSM バリアント

LGI、ssMRI NIDP Agg、dMRI NIDP Agg では、`MSMAll` または `MSMSulc` を選ぶ場面がある。
これは script 名や `--mode` / `--regname` に反映される。

### 8.6 SyncResults の `--mode`

代表的には次のような分類で考える。

- `NIDPS`
- `DMRI`
- `SSMRI_NIDP`
- `LGI`
- `ALL`

同期したい成果物の種類を、先に日本語で説明できることが重要である。

## 9. script の骨格

### 9.1 dMRI 前処理の典型例

```bash
#!/bin/bash
subjects=()
subjects+=("sub-XXXXXXXXXX")

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

この形が重要である。

- 最初に `subjects` 配列を作る
- script repository へ `cd` する
- `for sbjid in ${subjects[@]}; do ... done` で回す
- 最後に元の working directory へ戻す

### 9.2 sMRI/fMRI 前処理の典型例

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

違いは `tsp` を使う点と、`--should-save-intermediates=false` を入れやすい点である。

### 9.3 dMRI NIDP Agg の典型例

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
        --mode=<msmsulc|msmall> \
        --verbose
done

cd ${previous_wd}
```

ここでは `src` を書かないこと、secondary input があること、conda 環境を先に入れることがポイントである。

## 10. ファイル名の付け方

生成スクリプトの命名は、後から見返したときに「何をどこで回したか」が分かるようにする。
`references/templates.md` では、概ね次の規則が整理されている。

- MSM バリアントなし:
  `proc_<cohort_id>_On<machine>M_<YYYYMMDD-HHMMSS>.sh`
- MSM バリアントあり:
  `proc_<cohort_id>_On<machine>M_MsmAll_<YYYYMMDD-HHMMSS>.sh`
- sync 系:
  `sync_<cohort_id>_On<machine>M_<Mode>_<YYYYMMDD-HHMMSS>.sh`

ここで大事なのは、「人に見せるための名前」ではなく「後で事故調査できる名前」にすることである。

## 11. 転送と実行

ローカルで書いた script は、通常マシン上の `notes/` などへ転送して使う。

```bash
ssh -p 22 klab@192.168.50.XX "mkdir -p /mnt/qnapdata3/<user>/<repo>/notes"
scp -P 22 <local_script_path> \
  klab@192.168.50.XX:/mnt/qnapdata3/<user>/<repo>/notes/<filename>.sh
```

実行前に次を確認する。

- `cd` 先の repository が正しいか
- 呼び出し先 script 名が正しいか
- 対象 subject 数が想定通りか
- push/sync のフラグが意図通りか
- dry-run なのか本実行なのか

## 12. よくあるミス

### 12.1 処理依存関係の見落とし

dMRI なのに sMRI/fMRI 側の成果物が揃っていない、という失敗は典型的である。

### 12.2 `src` と `drv` の取り違え

一見もっともらしいパスでも、意味が違えば処理は正しく進まない。
「これは入力元か、共有先 derivatives か、処理機ローカル作業領域か」を毎回言語化する。

### 12.3 dMRI 系の入力の誤解

- dMRI 前処理が参照する `drv-on-share` は HCP 系 derivatives
- dMRI NIDP Agg が参照する `drv-on-share` は dMRI 前処理結果

同じ名前でも意味が違うため注意する。

### 12.4 LGI のマウントポイント誤り

LGI では `HCP_postFS` を使う。
`HCP_RestingStateStats` 系をそのまま入れると、期待する構造にならないことがある。

### 12.5 subject list を雑に作る

`ls` の結果をそのまま全部入れると、管理フォルダや中途半端なディレクトリが混ざることがある。

### 12.6 push/sync を無意識に有効化する

検証段階なのに `--should-push-*` や `--run` を本番向けで入れると、共有側を汚す危険がある。

## 13. 最低限の確認チェックリスト

script を保存する前に、最低限次を確認する。

1. どの処理タイプかを 1 文で説明できる
2. その処理の前提ステップが終わっている
3. 号機を選んだ理由がある
4. `src` と `drv` の意味を説明できる
5. subject list の取得元が分かっている
6. GPU、`tsp`、conda の要否が整理されている
7. push/sync の有無が意図通りである

## 14. まとめ

KLab の MRI 処理 batch スクリプト作成は、shell の書き方そのものよりも、**研究室の処理パイプラインとストレージ設計を理解しているか**で成否が決まる。

はじめのうちは、次の流れを崩さないのがよい。

1. 処理タイプを決める
2. 前提処理を確認する
3. コホートとマシンを決める
4. パスを 1 個ずつ確認する
5. subject list を確定する
6. オプションを決める
7. 最後に shell script として整形する

そしてAI 支援の `klab-proc-batch` スキルは、この判断を会話で補助するためのものに過ぎない。
この文書の流れを理解していれば、AI がなくても batch スクリプトを組めるようになる。
しかし以上のように非常にややこしい作業なので、claude code や codex cliを導入したほうが良い。
