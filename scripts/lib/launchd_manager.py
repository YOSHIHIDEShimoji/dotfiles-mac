#!/usr/bin/env python3

import os
import re
import sys
import argparse
import plistlib
import subprocess
import getpass
import readline
import glob
import time
import textwrap

try:
    import inquirer
    from inquirer import errors
except ImportError:
    print("[ERROR] 'inquirer' ライブラリが必要です。")
    print("実行してください: pip install inquirer")
    sys.exit(1)

# --- 設定 ---
DOTFILES_PLIST_DIR = os.path.expanduser("~/dotfiles/LaunchAgents")
SYSTEM_LAUNCH_DIR = os.path.expanduser("~/Library/LaunchAgents")
LOG_DIR = os.path.expanduser("~/Library/Logs")
CURRENT_USER = getpass.getuser()
DEFAULT_PATH = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# --- ログ出力用ユーティリティ ---
def print_info(msg):
    print(f"[INFO] {msg}")

def print_success(msg):
    print(f"\033[32m[SUCCESS] {msg}\033[0m")

def print_error(msg):
    print(f"\033[31m[ERROR] {msg}\033[0m")

def print_warning(msg):
    print(f"\033[33m[WARNING] {msg}\033[0m")

# --- launchctl ドメインヘルパー ---
def _domain():
    return f"gui/{os.getuid()}"

def _service_target(label):
    return f"{_domain()}/{label}"

def load_agent(plist_path):
    return subprocess.run(
        ["launchctl", "bootstrap", _domain(), plist_path],
        capture_output=True, text=True
    )

def unload_agent(label):
    return subprocess.run(
        ["launchctl", "bootout", _service_target(label)],
        capture_output=True, text=True
    )

def kickstart_agent(label):
    return subprocess.run(
        ["launchctl", "kickstart", "-k", _service_target(label)],
        capture_output=True, text=True
    )

# --- ファイルパス補完ロジック ---
def path_completer(text, state):
    line = text
    if '~' in line:
        line = os.path.expanduser(line)
    candidates = glob.glob(line + '*')
    matches = []
    for x in candidates:
        if os.path.isdir(x):
            x += "/"
        if text.startswith('~'):
            user_home = os.path.expanduser('~')
            if x.startswith(user_home):
                x = x.replace(user_home, '~', 1)
        matches.append(x)
    try:
        return matches[state]
    except IndexError:
        return None

def setup_autocomplete():
    readline.set_completer(path_completer)
    if readline.__doc__ and 'libedit' in readline.__doc__:
        readline.parse_and_bind("bind ^I rl_complete")
    else:
        readline.parse_and_bind("tab: complete")

# --- Plist関連 ---
def get_plist_name(script_path):
    name = os.path.splitext(os.path.basename(script_path))[0]
    safe = re.sub(r'[^a-zA-Z0-9._-]', '-', name)
    return f"com.{CURRENT_USER}.{safe}"

def create_plist_content(label, script_path, schedule_type, schedule_value):
    plist_data = {
        "Label": label,
        "ProgramArguments": [script_path],
        "EnvironmentVariables": {"PATH": DEFAULT_PATH},
        "StandardOutPath": f"{LOG_DIR}/{label}.out",
        "StandardErrorPath": f"{LOG_DIR}/{label}.err",
        "RunAtLoad": False,
    }

    if schedule_type == "interval":
        plist_data["StartInterval"] = int(schedule_value)
    elif schedule_type == "calendar":
        hour, minute = map(int, schedule_value.split(":"))
        plist_data["StartCalendarInterval"] = {"Hour": hour, "Minute": minute}
    elif schedule_type == "login":
        plist_data["RunAtLoad"] = True

    return plist_data

# --- バリデーション ---
def validate_time(answers, current):
    if not current or ":" not in current:
        raise errors.ValidationError('', reason='HH:MM 形式で入力してください (例: 09:00)')
    parts = current.split(":")
    if len(parts) != 2 or not all(p.isdigit() for p in parts):
        raise errors.ValidationError('', reason='数値を入力してください。')
    h, m = int(parts[0]), int(parts[1])
    if not (0 <= h < 24 and 0 <= m < 60):
        raise errors.ValidationError('', reason='時刻が範囲外です (00:00–23:59)。')
    return True

def validate_seconds(answers, current):
    if not current.isdigit():
        raise errors.ValidationError('', reason='整数を入力してください。')
    if int(current) <= 0:
        raise errors.ValidationError('', reason='1以上の整数を入力してください。')
    return True

# --- 質問ロジック ---
def ask_schedule_formal():
    questions_type = [
        inquirer.List('type',
            message="実行タイミングを選択してください",
            choices=[
                ('Calendar (指定時刻に実行)', 'calendar'),
                ('Interval (一定間隔で実行)', 'interval'),
                ('RunAtLoad (ログイン時に実行)', 'login'),
            ],
            carousel=True
        ),
    ]
    answer_type = inquirer.prompt(questions_type)
    if not answer_type: sys.exit()

    sType = answer_type['type']
    sValue = None

    if sType == 'calendar':
        q_time = [inquirer.Text('time', message="実行時刻を入力 (HH:MM)", validate=validate_time)]
        ans = inquirer.prompt(q_time)
        sValue = ans['time']

    elif sType == 'interval':
        q_sec = [inquirer.Text('sec', message="実行間隔を入力 (秒)", validate=validate_seconds)]
        ans = inquirer.prompt(q_sec)
        sValue = ans['sec']

    return sType, sValue

# --- テスト実行 ---
def _find_agent_status(label):
    res = subprocess.run(["launchctl", "list"], capture_output=True, text=True)
    for line in res.stdout.splitlines():
        parts = line.split()
        if len(parts) >= 3 and parts[2] == label:
            return parts[0], parts[1]  # (PID, last_exit_status)
    return None, None

def run_test_execution(label):
    print_info("テスト実行を開始します...")
    r = kickstart_agent(label)
    if r.returncode != 0:
        print_error(f"kickstart 失敗: {r.stderr.strip()}")
        return

    deadline = time.time() + 30
    exit_code = None
    while time.time() < deadline:
        pid, status = _find_agent_status(label)
        if pid is None:
            time.sleep(0.3)
            continue
        if pid == "-":  # 走り終わった
            exit_code = status
            break
        time.sleep(0.5)

    if exit_code is None:
        print_warning("30秒以内に完了しませんでした。長時間ジョブの可能性があります。")
        return

    if exit_code == "0":
        print_success("テスト成功 (Exit Code: 0)")
    else:
        print_error(f"テスト失敗 (Exit Code: {exit_code})")
        err_path = f"{LOG_DIR}/{label}.err"
        if os.path.exists(err_path):
            print("-" * 60)
            print(f"エラーログ: {err_path}")
            with open(err_path, 'r') as f:
                tail = f.read().strip()
                print(tail if tail else "(空)")
            print("-" * 60)

# --- 削除フロー ---
def remove_agent(label):
    plist_filename = f"{label}.plist"
    real_plist_path = os.path.join(DOTFILES_PLIST_DIR, plist_filename)
    link_plist_path = os.path.join(SYSTEM_LAUNCH_DIR, plist_filename)

    found_anything = False

    # bootout
    if os.path.lexists(link_plist_path) or os.path.exists(real_plist_path):
        found_anything = True
        r = unload_agent(label)
        if r.returncode == 0:
            print_info(f"bootout 完了: {label}")
        else:
            stderr = r.stderr.strip()
            if "Could not find service" in stderr or "No such process" in stderr:
                print_info("既にロードされていませんでした。")
            else:
                print_warning(f"bootout 警告: {stderr}")

    # symlink 削除
    if os.path.lexists(link_plist_path):
        os.remove(link_plist_path)
        print_info(f"シンボリックリンク削除: {link_plist_path}")

    # 実体 plist 削除
    if os.path.exists(real_plist_path):
        os.remove(real_plist_path)
        print_info(f"plist 削除: {real_plist_path}")

    if not found_anything:
        print_warning(f"対象が見つかりませんでした: {label}")
        return False

    print_success(f"{label} を削除しました。")
    return True

# --- Main ---
def main():
    setup_autocomplete()

    description_text = textwrap.dedent('''\
        [Launchd Agent Manager]
        macOSのlaunchd(自動実行)設定を対話形式で作成・管理するツール。
        dotfiles連携、テスト実行、削除機能を搭載。''')

    epilog_text = textwrap.dedent('''\
        【使用例】
          1. 対話モード:
             python launchd_manager.py

          2. パス指定モード:
             python launchd_manager.py ~/scripts/backup.sh

          3. エージェント削除:
             python launchd_manager.py --remove com.user.backup
        ''')

    parser = argparse.ArgumentParser(
        description=description_text,
        epilog=epilog_text,
        formatter_class=argparse.RawDescriptionHelpFormatter
    )

    parser.add_argument("script_path", nargs='?', help="自動実行設定を行う対象スクリプトのパス")
    parser.add_argument("--remove", metavar="LABEL", help="指定ラベルのエージェントを削除")
    args = parser.parse_args()

    # --- 削除モード ---
    if args.remove:
        ok = remove_agent(args.remove)
        sys.exit(0 if ok else 1)

    # --- 作成モード ---
    raw_path = args.script_path
    if not raw_path:
        try:
            raw_path = input("対象スクリプトのパス > ").strip()
        except KeyboardInterrupt:
            sys.exit()

    if not raw_path: return

    raw_path = raw_path.strip("'").strip('"').strip()
    script_path = os.path.abspath(os.path.expanduser(raw_path))

    if not os.path.exists(script_path):
        print_error(f"ファイルが見つかりません: {script_path}")
        return

    if not os.access(script_path, os.X_OK):
        print_info("実行権限を付与しています (+x)...")
        os.chmod(script_path, 0o755)

    label = get_plist_name(script_path)
    plist_filename = f"{label}.plist"

    real_plist_path = os.path.join(DOTFILES_PLIST_DIR, plist_filename)
    link_plist_path = os.path.join(SYSTEM_LAUNCH_DIR, plist_filename)

    print(f"\nTarget: \033[36m{script_path}\033[0m")
    print(f"Label:  \033[36m{label}\033[0m")

    # 既存設定処理
    if os.path.lexists(link_plist_path) or os.path.exists(real_plist_path):
        q_overwrite = [
            inquirer.List('overwrite',
                message="設定が既に存在します。上書きしますか？",
                choices=[('はい (上書き)', True), ('いいえ (キャンセル)', False)],
            ),
        ]
        ans = inquirer.prompt(q_overwrite)
        if not ans or not ans['overwrite']:
            print("キャンセルしました。")
            return

        # bootout（失敗してもプロセスは継続）
        r = unload_agent(label)
        if r.returncode == 0:
            print_info("既存エージェントを bootout しました。")
        elif "Could not find service" not in r.stderr:
            print_warning(f"bootout 警告: {r.stderr.strip()}")

    # スケジュール設定
    sType, sValue = ask_schedule_formal()
    plist_content = create_plist_content(label, script_path, sType, sValue)

    # ディレクトリ準備
    os.makedirs(DOTFILES_PLIST_DIR, exist_ok=True)
    os.makedirs(SYSTEM_LAUNCH_DIR, exist_ok=True)
    os.makedirs(LOG_DIR, exist_ok=True)

    # plist 書き出し
    with open(real_plist_path, 'wb') as f:
        plistlib.dump(plist_content, f)

    # シンボリックリンク作成
    if os.path.lexists(link_plist_path):
        os.remove(link_plist_path)
    os.symlink(real_plist_path, link_plist_path)
    print_info(f"シンボリックリンクを作成しました: {link_plist_path}")

    # bootstrap
    result = load_agent(link_plist_path)
    if result.returncode != 0:
        print_error("エージェントの bootstrap に失敗しました。")
        print(result.stderr)
        return

    print_success("エージェントの bootstrap に成功しました。")

    q_test = [
        inquirer.List('test',
            message="今すぐテスト実行を行いますか？",
            choices=[('はい (テスト実行)', True), ('いいえ (終了)', False)],
        ),
    ]
    ans_test = inquirer.prompt(q_test)

    if ans_test and ans_test['test']:
        run_test_execution(label)
    else:
        print_info("処理が完了しました。Gitへのコミットを忘れないでください。")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n中断しました。")
