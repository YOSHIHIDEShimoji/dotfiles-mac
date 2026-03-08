# パスワード解析ツール (john/)

`john`（John the Ripper）と `hashcat` を使ったパスワード解析スクリプト群です。PDFをはじめ各種ファイルフォーマットのハッシュ抽出から、辞書攻撃・ルールベース攻撃によるクラックまでをサポートします。M4チップ（Apple Silicon）に最適化されています。

---

## 前提ツール

```bash
brew install john hashcat
```

---

## ディレクトリ構成

```
scripts/john/
├── src/                  # ハッシュ抽出スクリプト（各フォーマット対応）
│   ├── pdf2john.py       # PDF → ハッシュ（Python版、推奨）
│   ├── pdf2john.pl       # PDF → ハッシュ（Perl版）
│   ├── office2john.py    # Office（docx/xlsx/pptx）→ ハッシュ
│   ├── zip2john          # ZIP → ハッシュ（バイナリ）
│   ├── rar2john.py       # RAR → ハッシュ
│   ├── 7z2john.pl        # 7-Zip → ハッシュ
│   ├── dmg2john.py       # macOS DMG → ハッシュ
│   ├── keychain2john.py  # macOS Keychain → ハッシュ
│   └── itunes_backup2john.pl  # iTunes バックアップ → ハッシュ
└── wordlists/
    └── rockyou.txt       # ワードリスト（.gitignore対象、別途取得が必要）
```

---

## rockyou.txt とは

2009年にSNSサービス「RockYou.com」が不正アクセスを受け、約1,400万件の平文パスワードが流出した事件に起因するワードリストです。現実世界で実際に使われていたパスワードの集合であるため、辞書攻撃において非常に高い有効性を持ち、パスワード解析ツールの標準ワードリストとして広く使われています。

- **件数**: 約1,430万件
- **ファイルサイズ**: 約140MB
- **形式**: 平文テキスト、1行1パスワード
- **用途**: 辞書攻撃（Dictionary Attack）のワードリストとして `john` / `hashcat` に渡す

サイズが大きいため `.gitignore` 対象です。使用する場合は以下の手順で取得します。

### インストール

```bash
bash install/setup-john-wordlists.sh
```

`scripts/john/wordlists/rockyou.txt` に配置されます。

---

## src/ スクリプトの使い方

各スクリプトはパスワード付きファイルからハッシュ文字列を抽出し、`john` や `hashcat` が解析できる形式に変換します。

### PDF

```bash
# Python版（推奨）
python3 scripts/john/src/pdf2john.py locked.pdf > hash.txt

# Perl版
perl scripts/john/src/pdf2john.pl locked.pdf > hash.txt
```

### Office（docx / xlsx / pptx）

```bash
python3 scripts/john/src/office2john.py locked.docx > hash.txt
```

### ZIP

```bash
scripts/john/src/zip2john locked.zip > hash.txt
```

### RAR

```bash
python3 scripts/john/src/rar2john.py locked.rar > hash.txt
```

### 7-Zip

```bash
perl scripts/john/src/7z2john.pl locked.7z > hash.txt
```

### macOS DMG

```bash
python3 scripts/john/src/dmg2john.py locked.dmg > hash.txt
```

### macOS Keychain

```bash
python3 scripts/john/src/keychain2john.py login.keychain > hash.txt
```

### iTunes バックアップ

```bash
perl scripts/john/src/itunes_backup2john.pl /path/to/backup/ > hash.txt
```

---

## クラック手順

### John the Ripper で辞書攻撃

```bash
john --wordlist=scripts/john/wordlists/rockyou.txt hash.txt
```

### John the Ripper でルールベース攻撃

```bash
john --wordlist=scripts/john/wordlists/rockyou.txt --rules hash.txt
```

### クラック結果の確認

```bash
john --show hash.txt
```

### Hashcat で辞書攻撃（Apple Silicon向け、GPU使用）

```bash
# ハッシュタイプはファイル形式によって異なる（-m オプション）
# PDF 1.4〜1.6: -m 10500
# Office 2013以降: -m 9600
hashcat -m 10500 hash.txt scripts/john/wordlists/rockyou.txt
```

Hashcat のルールファイルは `/opt/homebrew/opt/hashcat/share/doc/hashcat/rules/` にあります。

---

## Python 環境セットアップ

一部スクリプト（`pdf2john.py` 等）の実行には `scripts/.venv` の Python 環境が必要です。

```bash
python3 -m venv scripts/.venv
source scripts/.venv/bin/activate
pip install inquirer
```

---

## 関連ツール

PDFのロック解除・解析は `scripts/ppdf/` の `ppdf_crack` / `ppdf_unlock` コマンドからも実行できます。詳細は [root README](../../README.md) の「PDFツール (ppdf/)」セクションを参照してください。
