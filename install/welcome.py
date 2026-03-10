#!/usr/bin/env python3
"""Ghostty-inspired welcome animation for dotfiles bootstrap completion."""

import colorsys
import math
import os
import select
import sys
import termios
import threading
import time
import tty

# ─── ASCII アート ──────────────────────────────────────────────────────────────
ASCII_ART = [
    "██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗",
    "██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝",
    "██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗",
    "██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║",
    "██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║",
    "╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝",
]

SUBTITLE = "✦  Setup complete.  ✦"
DIVIDER_CHAR = "─"
MSG_LINE = " Open a new terminal window to bring everything to life  ✨"
PROMPT_LINE = "[ Press any key to return to your shell ]"

# ─── カラー定義 ────────────────────────────────────────────────────────────────
BG = (13, 0, 21)
LAVENDER = (232, 216, 255)
DIM = (107, 92, 138)
CYAN = (0, 229, 255)


def rgb(r: int, g: int, b: int) -> str:
    return f"\x1b[38;2;{r};{g};{b}m"


def bg_rgb(r: int, g: int, b: int) -> str:
    return f"\x1b[48;2;{r};{g};{b}m"


RESET = "\x1b[0m"
BOLD = "\x1b[1m"


def neon_color(col: int, frame: int, total_cols: int) -> tuple[int, int, int]:
    """Purple→Magenta→Cyan の hue wave を返す."""
    phase = (col / max(total_cols, 1) + frame / 120.0) % 1.0
    # Purple hue≈0.77, Magenta≈0.85, Cyan≈0.50
    # 0→1 のフェーズで 0.77→0.77+0.73=1.50 → wrap → cyan
    hue = (0.77 + phase * 0.73) % 1.0
    # ease-out 近似: sin の前半で加速を落とす
    eased = math.sin(phase * math.pi / 2)
    hue = (0.77 + eased * 0.73) % 1.0
    r, g, b = colorsys.hsv_to_rgb(hue, 0.90, 1.0)
    return int(r * 255), int(g * 255), int(b * 255)


def divider_color(col: int, total: int) -> tuple[int, int, int]:
    """シアン→パープルのグラデーション."""
    t = col / max(total, 1)
    r = int(0 * (1 - t) + 123 * t)
    g = int(229 * (1 - t) + 47 * t)
    b = int(255 * (1 - t) + 247 * t)
    return r, g, b


# ─── ターミナルユーティリティ ──────────────────────────────────────────────────
def get_terminal_size() -> tuple[int, int]:
    size = os.get_terminal_size()
    return size.columns, size.lines


def clear_screen(tty_file) -> None:
    tty_file.write("\x1b[2J")


def move_cursor(tty_file, row: int, col: int) -> None:
    tty_file.write(f"\x1b[{row};{col}H")


def hide_cursor(tty_file) -> None:
    tty_file.write("\x1b[?25l")


def show_cursor(tty_file) -> None:
    tty_file.write("\x1b[?25h")


# ─── 描画関数 ──────────────────────────────────────────────────────────────────
def colored_line(text: str, frame: int) -> str:
    """テキストの各文字に neon_color を適用した文字列を返す."""
    total = len(text)
    out = []
    for i, ch in enumerate(text):
        r, g, b = neon_color(i, frame, total)
        out.append(f"{rgb(r, g, b)}{ch}")
    out.append(RESET)
    return "".join(out)


def colored_divider(length: int) -> str:
    """シアン→パープルのグラデーション区切り線."""
    out = []
    for i in range(length):
        r, g, b = divider_color(i, length)
        out.append(f"{rgb(r, g, b)}{DIVIDER_CHAR}")
    out.append(RESET)
    return "".join(out)


def center_x(text_visible_len: int, cols: int) -> int:
    return max(1, (cols - text_visible_len) // 2 + 1)


# ─── フェードイン（タイプライター） ────────────────────────────────────────────
FADE_COLORS = [
    (40, 10, 60),
    (70, 25, 110),
    (100, 35, 160),
    (140, 45, 210),
    (180, 55, 240),
]


def typewriter_intro(tty_file) -> None:
    """ASCII アートを行ごとに暗色→本色でフェードイン."""
    cols, rows = get_terminal_size()
    art_width = max(len(line) for line in ASCII_ART)
    art_start_col = center_x(art_width, cols)
    total_rows = len(ASCII_ART)
    art_start_row = max(1, (rows - total_rows) // 2 - 4)

    bg_str = bg_rgb(*BG)
    full_bg = bg_str + " " * cols

    # 背景を塗りつぶす
    for r in range(1, rows + 1):
        move_cursor(tty_file, r, 1)
        tty_file.write(full_bg)

    # 各行をフェードイン
    for line_idx, line in enumerate(ASCII_ART):
        row = art_start_row + line_idx
        for fade_rgb in FADE_COLORS:
            move_cursor(tty_file, row, art_start_col)
            tty_file.write(bg_str + rgb(*fade_rgb) + line + RESET)
            tty_file.flush()
            time.sleep(0.015)
        time.sleep(0.04)

    tty_file.flush()


# ─── メインフレーム描画 ────────────────────────────────────────────────────────
def render_frame(tty_file, frame: int, blink: bool) -> None:
    cols, rows = get_terminal_size()
    bg_str = bg_rgb(*BG)
    art_width = max(len(line) for line in ASCII_ART)
    art_start_col = center_x(art_width, cols)
    total_art_rows = len(ASCII_ART)

    # レイアウト: アート中央、その下に各要素
    art_start_row = max(1, (rows - total_art_rows) // 2 - 4)

    # ASCII アート（neon wave）
    for line_idx, line in enumerate(ASCII_ART):
        row = art_start_row + line_idx
        move_cursor(tty_file, row, art_start_col)
        tty_file.write(bg_str + BOLD + colored_line(line, frame) + RESET)

    # サブタイトル
    sub_row = art_start_row + total_art_rows + 1
    sub_col = center_x(len(SUBTITLE), cols)
    move_cursor(tty_file, sub_row, sub_col)
    tty_file.write(bg_str + rgb(*LAVENDER) + SUBTITLE + RESET)

    # 区切り線
    div_len = min(len(MSG_LINE) + 4, cols - 4)
    div_row = sub_row + 2
    div_col = center_x(div_len, cols)
    move_cursor(tty_file, div_row, div_col)
    tty_file.write(bg_str + colored_divider(div_len))

    # メッセージ行
    msg_row = div_row + 1
    msg_col = center_x(len(MSG_LINE), cols)
    move_cursor(tty_file, msg_row, msg_col)
    tty_file.write(bg_str + rgb(*LAVENDER) + MSG_LINE + RESET)

    # 区切り線（下）
    div2_row = msg_row + 1
    move_cursor(tty_file, div2_row, div_col)
    tty_file.write(bg_str + colored_divider(div_len))

    # プロンプト（blink）
    prompt_row = div2_row + 2
    prompt_col = center_x(len(PROMPT_LINE), cols)
    move_cursor(tty_file, prompt_row, prompt_col)
    if blink:
        tty_file.write(bg_str + rgb(*CYAN) + PROMPT_LINE + RESET)
    else:
        tty_file.write(bg_str + " " * len(PROMPT_LINE))

    tty_file.flush()


# ─── キー入力スレッド ──────────────────────────────────────────────────────────
def key_listener(tty_fd: int, stop_event: threading.Event) -> None:
    while not stop_event.is_set():
        r, _, _ = select.select([tty_fd], [], [], 0.033)
        if r:
            try:
                os.read(tty_fd, 16)
            except OSError:
                pass
            stop_event.set()
            return


# ─── メイン ────────────────────────────────────────────────────────────────────
def main() -> None:
    tty_path = "/dev/tty"
    tty_fd = os.open(tty_path, os.O_RDWR | os.O_NOCTTY)
    tty_file = os.fdopen(tty_fd, "r+b", buffering=0)

    # raw mode 保存
    old_attrs = termios.tcgetattr(tty_fd)
    try:
        tty.setraw(tty_fd)

        # ラッパー（write は bytes か str どちらも受け付けるように）
        class TtyWriter:
            def write(self, s):
                if isinstance(s, str):
                    tty_file.write(s.encode())
                else:
                    tty_file.write(s)

            def flush(self):
                tty_file.flush()

        tw = TtyWriter()

        hide_cursor(tw)
        bg_str = bg_rgb(*BG)

        # 画面全体を背景色で塗る
        cols, rows = get_terminal_size()
        tw.write("\x1b[2J")
        for r in range(1, rows + 1):
            move_cursor(tw, r, 1)
            tw.write(bg_str + " " * cols)
        tw.flush()

        # フェードイントロ
        typewriter_intro(tw)

        # キー入力スレッド起動
        stop_event = threading.Event()
        listener = threading.Thread(
            target=key_listener, args=(tty_fd, stop_event), daemon=True
        )
        listener.start()

        # アニメーションメインループ
        frame = 0
        blink = True
        last_blink_time = time.monotonic()
        BLINK_INTERVAL = 0.6
        FRAME_INTERVAL = 1 / 30  # 30fps

        while not stop_event.is_set():
            loop_start = time.monotonic()

            now = time.monotonic()
            if now - last_blink_time >= BLINK_INTERVAL:
                blink = not blink
                last_blink_time = now

            render_frame(tw, frame, blink)
            frame += 1

            elapsed = time.monotonic() - loop_start
            sleep_time = FRAME_INTERVAL - elapsed
            if sleep_time > 0:
                time.sleep(sleep_time)

    finally:
        # 後処理
        termios.tcsetattr(tty_fd, termios.TCSADRAIN, old_attrs)

        class TtyWriter:
            def write(self, s):
                if isinstance(s, str):
                    tty_file.write(s.encode())
                else:
                    tty_file.write(s)

            def flush(self):
                tty_file.flush()

        tw = TtyWriter()
        show_cursor(tw)
        tw.write("\x1b[2J\x1b[H")
        tw.flush()
        tty_file.close()


if __name__ == "__main__":
    main()
