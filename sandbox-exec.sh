#!/bin/bash

set -e

# tmux監視機能（sandbox.shから移植）
if command -v tmux >/dev/null 2>&1 && [[ -n "$TMUX" ]]; then
    tmux setw monitor-silence 3
    trap 'tmux setw monitor-silence 0' EXIT
fi

# 作業ディレクトリを取得
WORKING_DIR=$(pwd)

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# プロファイルファイルのパス
PROFILE_FILE="$SCRIPT_DIR/sandbox.sb"

# プロファイルファイルの存在確認
if [[ ! -f "$PROFILE_FILE" ]]; then
    echo "Error: Profile file not found: $PROFILE_FILE" >&2
    exit 1
fi

# 引数が指定されていない場合はシェルを起動
if [[ $# -eq 0 ]]; then
    set -- "$SHELL"
fi

# 環境変数の制限（sandbox.shから移植）
# 必要最小限の環境変数のみ継承
SAFE_ENV_VARS=(
    "PATH"
    "HOME"
    "USER"
    "SHELL"
    "TERM"
    "LANG"
    "LC_ALL"
    "LC_CTYPE"
    "TMPDIR"
)

# 環境変数をクリアして必要なもののみ設定
env_args=()
for var in "${SAFE_ENV_VARS[@]}"; do
    if [[ -n "${!var}" ]]; then
        env_args+=("-D" "$var=${!var}")
    fi
done

# sandbox-execを実行
exec sandbox-exec \
    "${env_args[@]}" \
    -D "WORKING_DIR=$WORKING_DIR" \
    -f "$PROFILE_FILE" \
    "$@"
