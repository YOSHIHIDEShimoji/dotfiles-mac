# exports.sh に記述があるか確認し、なければ追記
grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' ~/dotfiles-mac/zsh/exports.sh || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/dotfiles-mac/zsh/exports.sh

# 現在のターミナルにも反映
export PATH="$HOME/.local/bin:$PATH"

# インストール実行
curl -fsSL https://claude.ai/install.sh | bash
