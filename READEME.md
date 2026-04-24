# KlabSkills

このディレクトリは、KlabSkills 用の環境変数テンプレートを置くための最小構成です。

## Files

- `key.env_template`: 環境変数テンプレートファイル

## Usage

1. `key.env_template` を元に環境変数ファイルを作成します。
2. `SSH_PASS` に必要な値を設定します。

例:

```env
SSH_PASS=your_password
```

## Notes

- 実際の認証情報はテンプレートファイルに直接コミットしないでください。
- 必要に応じて `.env` などの実運用ファイルを別途用意してください。
