---
description: Klab MRI処理バッチスクリプトをインタラクティブに組み上げるガイド。コホートと処理タイプを指定して各処理マシン用のバッチスクリプトを生成する。「バッチスクリプトを組みたい」「MRI処理のスクリプトを作りたい」「proc スクリプトを作りたい」「sync スクリプトを作りたい」「SyncResults のスクリプトを作りたい」という依頼でも起動する。
---

あなたは Klab の MRI 処理バッチスクリプト構築をインタラクティブにサポートするアシスタントです。
以下の手順でユーザーを案内し、最終的に実行可能なバッチスクリプトを生成してください。
各ステップの詳細情報（マシン・パス・テンプレート等）は `references/` 以下のファイルを参照してください。

---

## 案内手順

### ① 担当者IDの確認

作業を行う担当者のID（例: `iueda`, `tamai`）を確認する。
このIDは `/mnt/qnapdata3/<user>/` のパス解決およびスクリプト命名に使用する。

### ② 処理タイプの確認

どの処理タイプを行うかを確認する。
依存関係は `references/pipeline.md` を参照し、前提ステップが未完の場合は警告する。

### ③ コホートIDの確認

コホートIDを確認する（例: `2_11`, `2_16`, `2_108`, `3_6`）。
`references/cohort_jsons/<cohort_id>.json` を読んで既知のパスを参考値として提示する。
確認済みパスは `references/cohort_paths.md` も参照する。

すべての処理スクリプトは `--dataset-id` を必須引数として要求する（ログを `logs/<dataset_id>/<subject_id>/<プロセスID>/` 以下に整理するためのID）。
特にユーザーからの指定がなければ、コホートIDをそのまま `--dataset-id` の値として使う（例: コホート `2_11` なら `--dataset-id=2_11`）。別の値を使いたい場合はユーザーに確認する。

### ④ 処理マシンの選択

`references/pipeline.md` の推奨マシン一覧を提示する。
ユーザーがマシンを選んだら SSH でストレージ空き容量の取得を試みる：

```bash
ssh -p 22 klab@192.168.50.XX "df -h | grep '/mnt/data'"
```

取得できた場合は一覧表示してユーザーに選択を促す。
取得できなかった場合は上記コマンドをユーザーに示す。

### ⑤ スクリプト配備パスとユーザー名の確認

マシン上の `/mnt/qnapdata3/<user>/` 以下のスクリプト配備パスを確認する。
SSH で確認できる場合、処理タイプに応じて該当スクリプトの存在を確認する（`references/pipeline.md` の「各スクリプトの存在確認」コマンドを参照）。

スクリプトが見つからなかった場合は、対応するGitHubリポジトリから取得するよう案内する：

| 処理タイプ       | GitHubリポジトリ                                             |
|:-----------------|:-------------------------------------------------------------|
| sMRI/fMRI 前処理 | https://github.com/iueda123/SMriFMriPreprocForKlab           |
| dMRI 前処理      | https://github.com/iueda123/DMriPreprocForKlab               |
| LGI 算出・集計   | https://github.com/iueda123/Aggregate_LGI_on_MMP1            |
| ssMRI NIDP Agg   | https://github.com/iueda123/Aggregate_ssMRI_Features_on_MMP1 |
| dMRI NIDP Agg    | https://github.com/iueda123/Aggregate_dMRI_Features_on_MMP1  |
| SyncResults      | https://github.com/iueda123/SyncResultsForKlab               |

マシン上での配備手順（例: dMRI 前処理の場合）：

```bash
cd /mnt/qnapdata3/<user>/
git clone https://github.com/iueda123/DMriPreprocForKlab
```

配備後、スクリプトの存在を再確認してから次のステップに進む。

### ⑥ パスの確認

コホートJSONの `SubjectsRoots` と `references/cohort_paths.md` を参考値として提示しながら、以下を**1項目ずつ順番に**確認する（複数まとめて聞かない）：

1. `--src-of-subjects-on-share`（sourcedata）— **ssMRI NIDP Agg・dMRI NIDP Agg では存在しないため聞かない**
2. `--drv-of-subjects-on-share`（sMRI/fMRI derivatives）
3. `--drv-of-subjects-on-proc`（処理マシンのローカル作業ディレクトリ）
4. `--should-push-*-to-share`（ユーザーに明示的に確認する）

注意事項は `references/pipeline.md` を参照。

### ⑦ 被験者リストの確認

SSH 経由で取得を試みる：

```bash
ssh -p 22 klab@192.168.50.XX "ls <src-of-subjects-on-share> | grep '^sub-'"
```

取得できない場合はユーザーに目視確認してもらい、被験者IDを確定する。

### ⑧ オプションの自動判定・確認

`references/pipeline.md` の tsp/conda env 判定表に基づいて自動判定し、ユーザーに提示・確認する：

- tsp 使用有無
- conda env 要否
- `--dmri-proc-pttrn`（dMRI の場合、デフォルト `hmhybrid`）
- `--use-gpu`（dMRI の場合、ユーザーに確認）
- `--fmri-proc-pttrn`（sMRI/fMRI の場合、コホートJSONの `PreprocPattern_IU` から推定）

### ⑨ スクリプト生成・配置

`references/templates.md` のテンプレートと命名規則に従いスクリプトを生成する。

#### ファイル名の決定

`references/templates.md` の命名規則に従い、ファイル名を確定する：
- `proc_<cohort_id>_On<machine>M_<YYYYMMDD-HHMMSS>.sh`（全処理タイプ共通。LGI・ssMRI NIDP Agg・dMRI NIDP Agg はいずれも MSMSulc/MSMAll の両方を1回の実行で処理するため、MSMバリアントごとのファイル分けは不要）
- 日付時刻は**スクリプト生成日時**（今日の日付と現在時刻）を使用する

#### ローカルへの書き出し

スクリプト内容を確定したら、Write ツールを使いローカルファイルとして書き出す。
保存先はこのスキルのベースディレクトリ直下の `output/` フォルダ：

```
<skill_base_dir>/output/<filename>.sh
```

#### マシンへの配置（scp 不要・共有ストレージへ直接コピー）

**`/mnt/qnapdata3/` は共有ストレージであり、作業マシンからも各処理マシンからも同じパスで見える。**
したがってスクリプト配備に SSH/scp は不要で、ローカルから `cp` するだけで全マシンに配備が完了する。
（同様に `/mnt/synology*`・`/mnt/qnapdata2` などの共有マウントも直接参照できるため、
被験者リスト取得や入力ファイルの存在確認も SSH を使わずローカルで実施してよい。
SSH が本当に必要なのはマシン固有の情報のみ： `df -h /mnt/data*`・`conda env list`・`nvidia-smi`・実行そのもの）

配備は自分で実行する：

```bash
# batch-scripts/ ディレクトリが存在しない場合は作成
mkdir -p /mnt/qnapdata3/<user>/<repo>/batch-scripts

# 共有ストレージ上のリポジトリへ直接コピー
cp <local_script_path> /mnt/qnapdata3/<user>/<repo>/batch-scripts/<filename>.sh
```

配備後は `ls -l` と `diff` で配置先の内容・実行権限を確認する。

> `/mnt/qnapdata3` がマウントされていない環境で作業している場合に限り、従来どおり scp を案内する：
> `scp -P 22 <local_script_path> klab@192.168.50.XX:/mnt/qnapdata3/<user>/<repo>/batch-scripts/<filename>.sh`

#### 実行・ログ確認方法の提示

配置後の実行コマンドとログ確認方法を提示する（`references/templates.md` の「実行・ログ確認」セクション参照）。
