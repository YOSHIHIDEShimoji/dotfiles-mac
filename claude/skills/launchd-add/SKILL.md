---
name: launchd-add
description: >-
  macOS の launchd に新しい定期実行エージェント（常駐ジョブ）を登録するスキル。
  「launchdに登録して」「定期実行を追加して」「毎日N時にこのスクリプトを実行して」
  「plistを作って登録して」「常駐ジョブにして」等、Mac 本体でスクリプトを永続的に定期実行させたいときに使う。
  スクリプトパス・ラベル(com.yoshihide.run_<name>)・実行時刻を対話で収集し、
  ~/dotfiles/LaunchAgents/ に plist 生成 → ~/Library/LaunchAgents/ へ symlink → launchctl load →
  dotfiles コミットまで行う。クラウド/ルーチン系ではなく Mac ローカルの launchd 常駐が必要な場合に選ぶ
  （軽い自然言語スケジュールや claude.ai 側の定期実行は schedule 系スキルの領分）。
---

ユーザーに以下を順番に確認し、launchd に新しいエージェントを登録する。

## 収集する情報

1. **実行スクリプトのパス** — 絶対パスで確認（例: `/Users/yoshihide/my-projects/foo/bar.sh`）。実在と実行権限を `ls -l` で確認する
2. **launchd ラベル** — `com.yoshihide.run_<name>` 形式を提案してユーザーに確認。同名の plist が `~/dotfiles/LaunchAgents/` や `launchctl list` に既に無いか先に確認し、あればユーザーに上書きの可否を聞く
3. **スケジュール** — 実行時刻（Hour / Minute）を確認。「毎日12:00」など自然言語で受け取り、整数に変換する

## 実行手順

情報が揃ったら以下を順に実行する。

### 1. plist を dotfiles に生成

`~/dotfiles/LaunchAgents/<label>.plist` を以下のテンプレートで書き出す:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>EnvironmentVariables</key>
	<dict>
		<key>PATH</key>
		<string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
	</dict>
	<key>Label</key>
	<string>{label}</string>
	<key>ProgramArguments</key>
	<array>
		<string>{script_path}</string>
	</array>
	<key>RunAtLoad</key>
	<false/>
	<key>StandardErrorPath</key>
	<string>/Users/yoshihide/Library/Logs/{label}.err</string>
	<key>StandardOutPath</key>
	<string>/Users/yoshihide/Library/Logs/{label}.out</string>
	<key>StartCalendarInterval</key>
	<dict>
		<key>Hour</key>
		<integer>{hour}</integer>
		<key>Minute</key>
		<integer>{minute}</integer>
	</dict>
</dict>
</plist>
```

### 2. ~/Library/LaunchAgents にシンボリックリンクを作成

```bash
ln -s ~/dotfiles/LaunchAgents/{label}.plist ~/Library/LaunchAgents/{label}.plist
```

### 3. launchctl で読み込み

```bash
launchctl load ~/Library/LaunchAgents/{label}.plist
launchctl list | grep {label}
```

登録されていることを確認する。`load` は legacy サブコマンドのため、失敗する場合は
`launchctl bootstrap gui/$UID ~/Library/LaunchAgents/{label}.plist` を使う。

### 3.5. 試走で動作検証（可能な場合のみ）

登録して終わりにしない。スクリプトに副作用（送信・削除・課金等）が無いことを確認したうえで、
ユーザーの了承を得てから1回試走し、ログで成否を確認する:

```bash
launchctl start {label}
sleep 3 && tail -20 ~/Library/Logs/{label}.out ~/Library/Logs/{label}.err
```

副作用がある・判断がつかない場合は試走をスキップし、その旨をユーザーに伝える
（「初回実行は次のスケジュール時刻。ログは `~/Library/Logs/{label}.out` / `.err`」）。

### 4. dotfiles を commit & push

```bash
git -C ~/dotfiles add LaunchAgents/{label}.plist
git -C ~/dotfiles commit -m "feat: {label} の launchd plist を追加"
git -C ~/dotfiles push
```

## 完了報告

登録したエントリの概要（ラベル・スクリプト・スケジュール）を1〜2行で伝える。
