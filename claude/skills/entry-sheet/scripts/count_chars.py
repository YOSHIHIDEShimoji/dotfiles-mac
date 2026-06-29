#!/usr/bin/env python3
"""ES（エントリーシート）の文字数を正確にカウントするクロスプラットフォーム・スクリプト。

Windows / macOS / Linux で同一に動作する。標準ライブラリのみ使用。
入力は UTF-8 として読む（Windows の cp932 既定を回避するため encoding を明示）。

カウント規則（既定）:
  - 全角・半角を問わず 1 文字 = 1（Python の文字＝Unicodeコードポイント単位）
  - 句読点・記号・スペースはカウントする
  - 改行（\\n, \\r）はカウントしない（多くの ES 入力欄に準拠）

使い方:
  python count_chars.py <file> --limit 400
  python count_chars.py --text "本文..." --limit 300
  echo "本文" | python count_chars.py --limit 400          # 標準入力
  python count_chars.py draft.md --limit 400 --json        # 機械可読出力

オプション:
  --limit N         文字数上限。指定すると残り・充足率・判定を表示
  --count-newlines  改行もカウントに含める
  --no-spaces       スペース（半角/全角）をカウントから除外する
  --min-ratio R     合格とみなす最低充足率（既定 0.9 = 9割）
  --json            JSON で出力

終了コード:
  0  上限内かつ充足率 >= min-ratio（提出可）/ または --limit 未指定
  1  上限内だが充足率 < min-ratio（短すぎ・要加筆）
  2  上限超過（要削減）
"""
import argparse
import json
import sys
import unicodedata


def read_input(args):
    """テキストを取得する。優先順位: --text > ファイル > 標準入力。"""
    if args.text is not None:
        return args.text
    if args.file:
        with open(args.file, "r", encoding="utf-8") as f:
            return f.read()
    # 標準入力（パイプ）から読む。Windows でも UTF-8 を強制。
    data = sys.stdin.buffer.read()
    return data.decode("utf-8", errors="replace")


def count_chars(text, count_newlines=False, count_spaces=True):
    """文字数を数える。改行・スペースの扱いはフラグで制御。"""
    chars = []
    for ch in text:
        if ch in ("\n", "\r"):
            if not count_newlines:
                continue
        # スペース類（半角スペース U+0020・全角スペース U+3000・タブ等）
        elif ch.isspace() and not count_spaces:
            continue
        chars.append(ch)
    return len(chars)


def main():
    p = argparse.ArgumentParser(description="ES の文字数を正確にカウントする")
    p.add_argument("file", nargs="?", help="本文ファイル（UTF-8）")
    p.add_argument("--text", help="本文を直接渡す")
    p.add_argument("--limit", type=int, help="文字数上限")
    p.add_argument("--count-newlines", action="store_true", help="改行もカウントする")
    p.add_argument("--no-spaces", action="store_true", help="スペースを除外する")
    p.add_argument("--min-ratio", type=float, default=0.9, help="合格最低充足率（既定 0.9）")
    p.add_argument("--json", action="store_true", help="JSON で出力する")
    args = p.parse_args()

    try:
        text = read_input(args)
    except FileNotFoundError:
        print(f"[error] ファイルが見つかりません: {args.file}", file=sys.stderr)
        return 2
    # 正規化（全角・合成文字を安定させてから数える）
    text = unicodedata.normalize("NFC", text)

    count = count_chars(text, args.count_newlines, not args.no_spaces)

    result = {"count": count}
    exit_code = 0
    status = "OK"
    if args.limit:
        remaining = args.limit - count
        ratio = count / args.limit if args.limit else 0
        result.update(
            {
                "limit": args.limit,
                "remaining": remaining,
                "ratio": round(ratio, 4),
                "min_ratio": args.min_ratio,
            }
        )
        if count > args.limit:
            status = "OVER"
            exit_code = 2
        elif ratio < args.min_ratio:
            status = "UNDER"
            exit_code = 1
        else:
            status = "OK"
            exit_code = 0
    result["status"] = status

    if args.json:
        print(json.dumps(result, ensure_ascii=False))
        return exit_code

    # 人間向け出力
    if args.limit:
        bar_icon = {"OK": "✅", "UNDER": "🟡", "OVER": "🔴"}[status]
        print(f"{bar_icon} {status}  {count} / {args.limit} 文字  "
              f"（充足率 {round(result['ratio']*100, 1)}%・残り {result['remaining']}）")
        if status == "OVER":
            print(f"   → {abs(result['remaining'])} 文字オーバー。削減が必要。")
        elif status == "UNDER":
            need = int(args.limit * args.min_ratio) - count
            print(f"   → 9割（{int(args.limit*args.min_ratio)}文字）まであと {need} 文字。加筆推奨。")
    else:
        print(f"{count} 文字")
    return exit_code


if __name__ == "__main__":
    sys.exit(main())
