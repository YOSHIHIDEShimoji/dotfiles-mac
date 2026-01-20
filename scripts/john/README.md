# PDF Password Cracker Wizard

PDFのパスワードをM4チップに最適化されたHashcatで解析するウィザード形式のツール。

## 環境情報
- **Python venv**: `/Users/yoshihide/dotfiles-mac/scripts/.venv`
- **Hashcat Rules**: `/opt/homebrew/opt/hashcat/share/doc/hashcat/rules/`
- **Wordlist**: `scripts/john/wordlists/rockyou.txt`

## セットアップ
このスクリプトは `inquirer` ライブラリを使用します。
```bash
source /Users/yoshihide/dotfiles-mac/scripts/.venv/bin/activate
pip install inquirer