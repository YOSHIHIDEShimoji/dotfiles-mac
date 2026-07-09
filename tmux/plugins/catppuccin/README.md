# catppuccin/tmux（vendor 済み）

tmux の Catppuccin テーマを dotfiles に取り込んだもの（#29）。`git clone` 一発で
tmux の見た目まで揃うよう、実体をリポジトリに含めている（skills 管理方針と同型）。

- 上流: https://github.com/catppuccin/tmux
- 取り込み版: `d2d25bd3393fe43f19eb4fff6cdd2bdf5578e622`
- 配置: `tmux/plugins/catppuccin/tmux/`（`bootstrap` が `~/.config/tmux/plugins/catppuccin` へ symlink）
- `tmux/tmux.conf` の末尾で `catppuccin.tmux` を `if-shell` ガード付きで読み込む。

## 取り込んだファイル（ランタイム必須のみ）

`catppuccin.tmux` / `catppuccin_tmux.conf` / `catppuccin_options_tmux.conf` /
`status/` / `themes/` / `utils/` / `LICENSE`。
スクリーンショット（`assets/`）・`tests/`・`docs/` は実行に不要なため除外した。

## 更新方法

```bash
git clone --depth 1 https://github.com/catppuccin/tmux /tmp/catppuccin-tmux
DEST=~/dotfiles/tmux/plugins/catppuccin/tmux
cp /tmp/catppuccin-tmux/{catppuccin.tmux,catppuccin_tmux.conf,catppuccin_options_tmux.conf,LICENSE} "$DEST/"
cp -R /tmp/catppuccin-tmux/{status,themes,utils} "$DEST/"
# この README の「取り込み版」の SHA を更新する
```
