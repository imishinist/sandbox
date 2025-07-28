#!/bin/bash

set -e

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

# sandbox-execを実行
exec sandbox-exec \
    -D "HOME=$HOME" \
    -D "WORKING_DIR=$WORKING_DIR" \
    -f "$PROFILE_FILE" \
    "$@"
