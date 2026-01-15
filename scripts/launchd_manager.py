import os
import sys
import argparse
import plistlib
import subprocess
import getpass
import readline
import glob
import time
import textwrap # ヘルプ表示の整形用に使い追加

# 必須ライブラリチェック
try:
    import inquirer
    from inquirer import errors
except ImportError:
    print("[ERROR] 'inquirer' ライブラリが必要です。")
    print("実行してください: pip install inquirer")
    sys.exit(1)

# --- 設定 ---
DOTFILES_PLIST_DIR = os.path.expanduser("~/dotfiles-mac/LaunchAgents")
SYSTEM_LAUNCH_DIR = os.path.expanduser("~/Library/LaunchAgents")
CURRENT_USER = getpass.getuser()

# --- ログ出力用ユーティリティ ---
def print_info(msg):
    print(f"[INFO] {msg}")

def print_success(msg):
    print(f"\033[32m[SUCCESS] {msg}\033[0m")

def print_error(msg):
    print(f"\033[31m[ERROR] {msg}\033[0m")

def print_warning(msg):
    print(f"\033[33m[WARNING] {msg}\033[0m")

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
    if 'libedit' in readline.__doc__:
        readline.parse_and_bind("bind ^I rl_complete")
    else:
        readline.parse_and_bind("tab: complete")

# --- スクリプト内容の監査 (コピペ対応版) ---
def audit_script_content(script_path):
    """
    スクリプト内に必須要素が含まれているかチェックする。
    不備がある場合は、コピペ用の修正コードを表示して終了する。
    """
    required_path_key = "export PATH"
    required_exit_key = "exit 0"
    
    # コピペ用の推奨コード
    recommended_path_code = 'export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"'
    
    try:
        with open(script_path, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
            
            missing_path = required_path_key not in content
            missing_exit = required_exit_key not in content
            
            if missing_path or missing_exit:
                print_error(f"スクリプトの必須記述チェックでエラーが発生しました: {script_path}")
                print("\n以下の必須行が不足しています。")
                print("下記コードをコピーし、スクリプトに追記してください:")
                print("\n" + "=" * 60)
                
                # PATHが足りない場合
                if missing_path:
                    print("# [必須] 冒頭 (#!/bin/bash の直後など) に追記してください")
                    print(f"\033[36m{recommended_path_code}\033[0m") # シアン色
                    print("")

                # exit 0 が足りない場合
                if missing_exit:
                    print("# [必須] スクリプトの末尾 (最終行) に追記してください")
                    print("\033[36mexit 0\033[0m")

                print("=" * 60 + "\n")
                print_info("処理を中断します。ファイルを修正後に再度実行してください。")
                return False
                
            return True

    except Exception as e:
        print_warning(f"スクリプト解析中に例外が発生しました (バイナリ等の可能性): {e}")
        return True

# --- Plist関連 ---
def get_plist_name(script_path):
    filename = os.path.basename(script_path)
    name_without_ext = os.path.splitext(filename)[0]
    return f"com.{CURRENT_USER}.{name_without_ext}"

def create_plist_content(label, script_path, schedule_type, schedule_value):
    plist_data = {
        "Label": label,
        "ProgramArguments": [script_path], 
        "StandardOutPath": f"/tmp/{label}.out",
        "StandardErrorPath": f"/tmp/{label}.err",
        "RunAtLoad": False
    }

    if schedule_type == "interval":
        plist_data["StartInterval"] = int(schedule_value)
    elif schedule_type == "calendar":
        hour, minute = map(int, schedule_value.split(":"))
        plist_data["StartCalendarInterval"] = {
            "Hour": hour,
            "Minute": minute
        }
    elif schedule_type == "login":
        plist_data["RunAtLoad"] = True
    
    return plist_data

# --- バリデーション ---
def validate_time(answers, current):
    if not current or ":" not in current:
        raise errors.ValidationError('', reason='フォーマット不正です。HH:MM 形式で入力してください (例: 09:00)')
    parts = current.split(":")
    if len(parts) != 2 or not parts[0].isdigit() or not parts[1].isdigit():
        raise errors.ValidationError('', reason='数値を入力してください。')
    return True

def validate_seconds(answers, current):
    if not current.isdigit():
        raise errors.ValidationError('', reason='整数を入力してください。')
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
        q_time = [
            inquirer.Text('time',
                message="実行時刻を入力 (HH:MM)",
                validate=validate_time
            )
        ]
        ans = inquirer.prompt(q_time)
        sValue = ans['time']

    elif sType == 'interval':
        q_sec = [
            inquirer.Text('sec',
                message="実行間隔を入力 (秒)",
                validate=validate_seconds
            )
        ]
        ans = inquirer.prompt(q_sec)
        sValue = ans['sec']

    return sType, sValue

# --- テスト実行 ---
def run_test_execution(label):
    print_info("テスト実行を開始します...")
    subprocess.run(["launchctl", "start", label])
    
    time.sleep(2)
    
    res = subprocess.run(["launchctl", "list"], capture_output=True, text=True)
    
    status_code = None
    
    for line in res.stdout.splitlines():
        if label in line:
            parts = line.split()
            # parts[0]=PID, parts[1]=Status
            status_code = parts[1]
            break
    
    if status_code == "0":
        print_success("テスト成功 (Exit Code: 0)")
    elif status_code:
        print_error(f"テスト失敗 (Exit Code: {status_code})")
        err_path = f"/tmp/{label}.err"
        if os.path.exists(err_path):
            print("-" * 60)
            print(f"エラーログ: {err_path}")
            with open(err_path, 'r') as f:
                print(f.read().strip())
            print("-" * 60)
    else:
        print_warning("プロセスステータスを取得できませんでした。")

# --- Main ---
def main():
    setup_autocomplete()

    # Helpメッセージの定義
    description_text = textwrap.dedent('''\
        [Launchd Agent Manager]
        macOSのlaunchd(自動実行)設定を対話形式で作成・管理するツール。
        dotfiles連携、スクリプト監査、テスト実行機能を搭載。''')

    epilog_text = textwrap.dedent('''\
        【使用例】
          1. 対話モード (パス入力から開始):
             python launchd_manager.py

          2. パス指定モード (指定ファイルの設定を開始):
             python launchd_manager.py ~/scripts/backup.sh
        ''')

    parser = argparse.ArgumentParser(
        description=description_text,
        epilog=epilog_text,
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    
    parser.add_argument("script_path", nargs='?', help="自動実行設定を行う対象スクリプトのパス")
    args = parser.parse_args()

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

    # --- Step 0: Script Audit ---
    if not audit_script_content(script_path):
        sys.exit(1)

    # 実行権限チェック
    if not os.access(script_path, os.X_OK):
        print_info("実行権限を付与しています (+x)...")
        os.chmod(script_path, 0o755)

    label = get_plist_name(script_path)
    plist_filename = f"{label}.plist"
    
    real_plist_path = os.path.join(DOTFILES_PLIST_DIR, plist_filename)
    link_plist_path = os.path.join(SYSTEM_LAUNCH_DIR, plist_filename)

    print(f"\nTarget: \033[36m{script_path}\033[0m")

    # 既存設定処理
    if os.path.exists(link_plist_path) or os.path.exists(real_plist_path):
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
        
        if os.path.exists(link_plist_path):
            subprocess.run(["launchctl", "unload", link_plist_path], stderr=subprocess.DEVNULL)
            print_info("既存のエージェントをアンロードしました。")
    
    # スケジュール設定
    sType, sValue = ask_schedule_formal()
    plist_content = create_plist_content(label, script_path, sType, sValue)
    
    # 保存処理
    if not os.path.exists(DOTFILES_PLIST_DIR): os.makedirs(DOTFILES_PLIST_DIR)
    
    with open(real_plist_path, 'wb') as f:
        plistlib.dump(plist_content, f)
    
    if not os.path.exists(SYSTEM_LAUNCH_DIR): os.makedirs(SYSTEM_LAUNCH_DIR)

    if os.path.exists(link_plist_path) or os.path.islink(link_plist_path):
        os.remove(link_plist_path)
    
    os.symlink(real_plist_path, link_plist_path)
    print_info(f"シンボリックリンクを作成しました: {link_plist_path}")

    # Load処理
    result = subprocess.run(["launchctl", "load", link_plist_path], capture_output=True, text=True)
    
    if result.returncode == 0:
        print_success("エージェントのロードに成功しました。")
        
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

    else:
        print_error("エージェントのロードに失敗しました。")
        print(result.stderr)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n中断しました。")