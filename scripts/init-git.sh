#!/usr/bin/env bash
# shell-craft - Git Project Initializer
# 用法：
#   ./init-git.sh -n "My Project" -l mit -g node -r https://github.com/user/repo.git
set -euo pipefail

# === 預設參數 ===
PROJECT_NAME=""
LICENSE_TYPE="mit"        # mit | apache-2.0 | none
GITIGNORE="node"          # node | csharp | none
REMOTE_URL=""
BRANCH="main"

usage() {
cat <<EOF
使用方式：
  $(basename "$0") [options]

Options:
  -n  專案名稱 (README.md 標題)          [必填]
  -l  授權條款: mit | apache-2.0 | none   (預設: mit)
  -g  .gitignore: node | csharp | none    (預設: node)
  -r  遠端 Git URL (不填則不設定 remote)
  -b  預設分支名稱                       (預設: main)
  -h  顯示說明
EOF
exit 1
}

# 便利函式：複製範本
copy_template() {
  local src="$1" dst="$2"
  [[ "$src" == "none" ]] && return
  cp "$(dirname "$0")/../templates/$src" "$dst"
}

# 解析參數
while getopts ":n:l:g:r:b:h" opt; do
  case $opt in
    n) PROJECT_NAME="$OPTARG" ;;
    l) LICENSE_TYPE="$OPTARG" ;;
    g) GITIGNORE="$OPTARG" ;;
    r) REMOTE_URL="$OPTARG" ;;
    b) BRANCH="$OPTARG" ;;
    h|*) usage ;;
  esac
done

[[ -z "$PROJECT_NAME" ]] && { echo "❌ 必須輸入專案名稱 (-n)"; usage; }

# 若已有 .git 需先確認
if [[ -d .git ]]; then
  read -rp "⚠️  目前資料夾已是 Git 倉庫，繼續？(y/N) " confirm
  [[ "$confirm" != [yY] ]] && exit 1
fi

### Git 初始化 ###
git init -b "$BRANCH"
echo "# $PROJECT_NAME" > README.md

copy_template "gitignore/${GITIGNORE}.gitignore" ".gitignore"
copy_template "license/${LICENSE_TYPE^^}.txt" "LICENSE"

git add .
git commit -m "chore: initial commit via shell-craft"

if [[ -n "$REMOTE_URL" ]]; then
  git remote add origin "$REMOTE_URL"
  git push -u origin "$BRANCH"
fi

echo "✅ 完成：已初始化 Git 倉庫並建立基本檔案"