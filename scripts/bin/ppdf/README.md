# ppdf — PDF操作ツール群

ターミナルから使えるPDF操作コマンド群。`~/dotfiles-mac/scripts/` は `exports.sh` によって PATH に追加されているため、**ターミナルのどこからでもコマンド名だけで呼び出せる**（例: `ppdf_unlock file.pdf`）。

---

## 依存ツール

| ツール | インストール | 用途 |
|--------|------------|------|
| `qpdf` | `brew install qpdf` | unlock / extract / split |
| `pdfjam` | `brew install pdfjam` | split / make_num の N-up 処理 |
| `pikepdf` | `pip install pikepdf` | concatenate |
| `inquirer` | `pip install inquirer` | crack の対話UI |
| `hashcat` | `brew install hashcat` | crack のパスワード解析 |
| `pdf2john.py` | `scripts/john/src/` に配置済み | crack のハッシュ抽出 |
| `rockyou.txt` | `scripts/john/wordlists/` に配置済み | crack の辞書ファイル |

---

## コマンド一覧

| コマンド | 概要 |
|---------|------|
| `ppdf_unlock` | 暗号化解除（パスワード指定対応、クリーニング付き） |
| `ppdf_crack` | パスワード解析（辞書・マスク・総当たり） |
| `ppdf_extract` | 指定ページの抽出（odd/even指定対応） |
| `ppdf_split` | 指定枚数ごとに分割（N-up処理オプション付き） |
| `ppdf_concatenate` | ディレクトリ内PDFを結合（編集制限解除） |
| `ppdf_make_num` | N-upレイアウト適用（複数ページを1枚にまとめる） |

---

## ppdf_unlock

パスワード付きPDFの暗号化を解除する。デフォルトで内部データのクリーニングと非圧縮も行う。元ファイルは `/tmp` に一時退避され、処理後に元の場所へ上書きされる。

```
ppdf_unlock [OPTIONS] FILE.pdf [FILE.pdf ...]
```

### オプション

| オプション | 説明 |
|-----------|------|
| `-h`, `--help` | ヘルプ表示 |
| `-p`, `--password PASS` | PDFのパスワードを指定 |
| `-o`, `--output-dir DIR` | 出力先ディレクトリを指定（元ファイルは移動しない） |
| `-S`, `--simple` | シンプルモード：暗号化解除のみ（クリーニング・非圧縮を省略） |

### 動作

- **デフォルト（フルモード）**: `--decrypt` に加え、`--object-streams=disable`, `--stream-data=uncompress`, `--normalize-content=y`, `--coalesce-contents`, `--linearize` を適用
- **シンプルモード（`-S`）**: `--decrypt` のみ。ファイルサイズを抑えたい場合や表示崩れを防ぎたい場合に使用
- 出力先未指定時、元ファイルは `/tmp/{name}_{timestamp}_original.pdf` に退避して上書き。失敗時は元ファイルを復元する

### 使用例

```bash
# パスワードなし（パーミッション制限解除）
ppdf_unlock document.pdf

# パスワードあり
ppdf_unlock -p "mypassword" document.pdf

# シンプルモード + 出力先指定
ppdf_unlock -S -p "pass123" -o ./output/ document.pdf

# 複数ファイル
ppdf_unlock -p "pass" a.pdf b.pdf c.pdf
```

---

## ppdf_crack

PDFのパスワードを解析するインタラクティブウィザード。`pdf2john.py` でハッシュを抽出し、`hashcat` で攻撃する。

```
ppdf_crack [PDF_FILE]
```

### オプション

引数でPDFを渡すか、対話的に入力する（引数なし起動も可）。

### 攻撃モード

対話的に以下から選択：

| モード | 説明 |
|--------|------|
| 辞書攻撃 | `rockyou.txt` を使用。標準 / Best64ルール / 自動ステップアップから選択 |
| マスク攻撃 | パターン指定（例: `pass?d?d?d`）。`?d`=数字、`?l`=小文字など |
| 総当たり攻撃 | 文字セット（数字 / 数字+記号 / 英数字 / 全文字）と桁数を指定 |

### 動作

- PDF形式（1.7 Level 8 / 1.7 Level 3 / 1.4–1.6）を自動判定して hashcat モードを切り替え
- hashcat のキャッシュを確認し、解析済みなら即座に結果を返す
- 組み合わせ数が大きすぎる場合は警告を表示

### 使用例

```bash
ppdf_crack secret.pdf
# → 対話的に攻撃方法を選択
```

---

## ppdf_extract

PDFから指定ページを抽出して新しいPDFを生成する。

```
ppdf_extract [-o OUTPUT.pdf] [-n] INPUT.pdf PAGES.txt
```

### オプション

| オプション | 説明 |
|-----------|------|
| `-h`, `--help` | ヘルプ表示 |
| `-o OUTPUT.pdf` | 出力ファイル名を指定 |
| `-n`, `--no-sort` | ページ番号のソートを無効にする |

### ページ指定形式（PAGES.txt）

| 記法 | 意味 |
|------|------|
| `1, 3, 5` | 個別ページ指定 |
| `5-10` | ページ範囲 |
| `z` | 最終ページ |
| `r1` | 最後から1ページ目（`r2` で最後から2ページ目） |
| `1-10[odd]` | 奇数ページのみ |
| `z[even]` | 最終ページを含む偶数ページ |

`[odd]` / `[even]` を含む場合はPythonで計算、それ以外はシェルで高速処理。

### 使用例

```bash
# pages.txt の内容に基づいて抽出
ppdf_extract input.pdf pages.txt

# 出力ファイル名を指定
ppdf_extract -o extracted.pdf input.pdf pages.txt

# ソートなし（指定順を維持）
ppdf_extract -n input.pdf pages.txt
```

---

## ppdf_split

PDFを指定枚数ごとに分割する。オプションでN-up処理（複数ページを1枚にまとめる）も適用できる。

```
ppdf_split [OPTIONS] FILE.pdf [FILE.pdf ...]
```

### オプション

| オプション | 説明 |
|-----------|------|
| `-h` | ヘルプ表示 |
| `-s NUM` | 分割枚数（デフォルト: 24） |
| `-n GRID` | N-upレイアウト指定（`2`, `4`, `CxR` 形式）。例: `-n 2x3`（横2列×縦3行） |
| `-f` | 各ページに枠線をつける |
| `-o p\|l` | 向きを強制指定（`p`=縦、`l`=横） |

### 動作

1. `-n` 指定時、まず `pdfjam` でN-up処理
2. 指定枚数ごとに `qpdf` で分割
3. `{basename}_split_{num}_[{grid}in1]/` ディレクトリに `_part01.pdf`, `_part02.pdf`, ... で保存

`-n 2` は縦向き入力→横2列（2x1）、横向き入力→縦2行（1x2）と自動判定。

### 使用例

```bash
# 24ページごとに分割（デフォルト）
ppdf_split document.pdf

# 10ページごとに分割
ppdf_split -s 10 document.pdf

# 2in1にまとめてから24ページごとに分割
ppdf_split -n 2 document.pdf

# カスタムグリッド（2列×3行）+ 枠線あり
ppdf_split -n 2x3 -f document.pdf
```

---

## ppdf_concatenate

指定ディレクトリ内のすべてのPDFをアルファベット順に結合する。編集制限（印刷不可・コピー不可等）は自動で解除される。

```
ppdf_concatenate TARGET_DIR [-o OUTPUT_FILE]
```

### オプション

| オプション | 説明 |
|-----------|------|
| `TARGET_DIR` | PDFが格納されているディレクトリ（必須） |
| `-o`, `--output FILE` | 出力ファイル名（デフォルト: `combined_output.pdf`） |

### 動作

- `pikepdf.open()` で各PDFを開く。閲覧パスワードがなければ編集制限を無視して結合できる
- エラーが発生したファイルはスキップし、他のファイルの処理を継続
- 処理結果（成功数/失敗数）をまとめて表示

### 使用例

```bash
# カレントディレクトリのPDFを結合
ppdf_concatenate ./pdfs/

# 出力ファイル名を指定
ppdf_concatenate ./pdfs/ -o merged.pdf
```

---

## ppdf_make_num

PDFにN-upレイアウトを適用し、複数ページを1枚にまとめる。

```
ppdf_make_num [-n 2|4] [-x CxR] [-o p|l] [-f] INPUT.pdf [OUTPUT.pdf]
```

### オプション

| オプション | 説明 |
|-----------|------|
| `-h` | ヘルプ表示 |
| `-n 2\|4` | プリセット（2 or 4ページを1枚に） |
| `-x CxR` | カスタムグリッド（例: `2x3`=横2列×縦3行）。`-n` より優先 |
| `-o p\|l` | 出力向きを強制指定（`p`=縦、`l`=横）。省略時は自動判定 |
| `-f` | 各ページに枠線をつける |

### 動作

- `qpdf` で入力PDFのページサイズ・向きを分析して最適なレイアウトを自動決定
- `pdfjam` でN-up処理を実行
- 出力ファイル名のデフォルト: `-x` 指定時は `{basename}_{CxR}.pdf`、`-n` 指定時は `{basename}_{n}in1.pdf`

**自動レイアウト判定（`-n` プリセット時）:**

| 入力向き | `-n 2` の出力 | `-n 4` の出力 |
|---------|--------------|--------------|
| 縦向き | 横向き (2x1) | 横向き (2x2) |
| 横向き | 縦向き (1x2) | 縦向き (2x2) |

### 使用例

```bash
# 2in1（自動レイアウト）
ppdf_make_num -n 2 document.pdf

# 4in1 + 枠線あり
ppdf_make_num -n 4 -f document.pdf

# カスタムグリッド（3列×2行）、横向き強制
ppdf_make_num -x 3x2 -o l document.pdf

# 出力ファイル名を指定
ppdf_make_num -n 2 document.pdf output_2in1.pdf
```
