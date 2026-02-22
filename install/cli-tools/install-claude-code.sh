set -e

# exports.sh に記述があるか確認し、なければ追記
grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' ~/dotfiles-mac/zsh/exports.sh || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/dotfiles-mac/zsh/exports.sh

# 現在のターミナルにも反映
export PATH="$HOME/.local/bin:$PATH"

# インストール実行
curl -fsSL https://claude.ai/install.sh | bash

# skills を使えるようにする（dotfiles-mac/scripts/bin/skills-sync をインストール時に行う）
SRC_DIR="$HOME/.agents/skills"
DST_DIR="$HOME/.claude/skills"

mkdir -p "$DST_DIR"

for dir in "$SRC_DIR"/*; do
    if [ -d "$dir" ]; then
        name=$(basename "$dir")
        target="$DST_DIR/$name"

        if [ -L "$target" ] || [ -e "$target" ]; then
            rm -rf "$target"
        fi

        ln -s "$dir" "$target"
        echo "linked: $name"
    fi
done

echo "done."

