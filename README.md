# KlabSkills

Klab の MRI 処理バッチスクリプト生成を支援するスキル群を管理するリポジトリです。

現在の中心コンテンツは [`.claude/skills/klab-proc-batch/SKILL.md`](./.claude/skills/klab-proc-batch/SKILL.md) で、Klab の処理マシン向けに `proc` / `sync` 系の実行スクリプトを対話的に組み立てるためのスキルを定義しています。

## このリポジトリが提供するもの

`klab-proc-batch` スキルは、ユーザーとの対話を通じて以下を順に確認し、最終的に実行可能なバッチスクリプトを生成します。

- 担当者 ID
- 処理タイプ
- コホート ID
- 使用する処理マシン
- スクリプト配備先パス
- 入出力パス
- 被験者リスト
- 処理オプション

対象となる処理タイプは次のとおりです。

- sMRI/fMRI 前処理
- dMRI 前処理
- LGI 算出・集計
- ssMRI NIDP Agg
- dMRI NIDP Agg
- SyncResults

スキルは処理依存関係、推奨マシン、SSH での確認コマンド、既知のコホートパス、テンプレート化されたコマンドライン引数を参照しながら、各処理に対応したシェルスクリプトを生成します。

## 主なディレクトリ構成

- [`.claude/skills/klab-proc-batch/SKILL.md`](./.claude/skills/klab-proc-batch/SKILL.md): スキル本体
- [`.claude/skills/klab-proc-batch/references/pipeline.md`](./.claude/skills/klab-proc-batch/references/pipeline.md): 処理依存関係、推奨マシン、SSH 確認コマンド、パス指定上の注意
- [`.claude/skills/klab-proc-batch/references/templates.md`](./.claude/skills/klab-proc-batch/references/templates.md): 処理タイプ別テンプレートと命名規則
- [`.claude/skills/klab-proc-batch/references/cohort_paths.md`](./.claude/skills/klab-proc-batch/references/cohort_paths.md): 実運用で確認済みのコホート別パス
- [`.claude/skills/klab-proc-batch/output/`](./.claude/skills/klab-proc-batch/output/): 生成済みスクリプトの出力先
- [`docs/20260426_introduction/skill-klab-proc-batch/`](./docs/20260426_introduction/skill-klab-proc-batch/): スキル紹介用ドキュメント
- [`key.env_template`](./key.env_template): 補助的な環境変数テンプレート

## スキルの入出力

入力は主に以下です。

- コホート ID 例: `2_11`, `2_16`, `2_108`
- 処理マシン 例: 52, 55, 56, 57, 59, 61
- 処理対象の共有ストレージパスとローカル作業パス
- 被験者 ID の一覧
- 処理タイプごとのオプション 例: `--dmri-proc-pttrn`, `--use-gpu`, `--mode`

出力は `.claude/skills/klab-proc-batch/output/` 配下に保存されるシェルスクリプトです。命名規則は `references/templates.md` に整理されており、たとえば以下のようなファイルが生成されます。

- `proc_2_16_On56M_20260424-170527.sh`
- `proc_2_108_On55M_MsmSulc_20260424.sh`
- `sync_2_16_On56M_Dmri_20260424-163603.sh`

## 補足

- 現在の README よりも `SKILL.md` が実態に近い一次情報です。
- `cohort_paths.md` には実作業で確認済みのパスが蓄積されていますが、最新状況は必ず実機・実ストレージで再確認する前提です。
- `pipeline.md` にある SSH コマンド群を使うことで、空き容量、GPU 有無、conda 環境、スクリプト配備状況を確認できます。
- `key.env_template` には `SSH_PASS` の雛形がありますが、機密情報はコミットしない運用を前提としています。
