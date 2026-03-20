#!/bin/bash

set -e

# tmux監視機能（sandbox.shから移植）
if command -v tmux >/dev/null 2>&1 && [[ -n "$TMUX" ]]; then
    tmux setw monitor-silence 3
fi

# 作業ディレクトリを取得
WORKING_DIR=$(pwd)

# HOMEディレクトリからの実行チェック（Docker版と同様）
if [[ "$WORKING_DIR" == "$HOME" ]]; then
    echo "WARNING: Running from HOME directory ($HOME). The entire HOME directory will be writable in the sandbox." >&2
fi

# スクリプトのディレクトリを取得（シンボリックリンク対応）
SCRIPT_PATH="${BASH_SOURCE[0]}"
# シンボリックリンクの場合は実際のファイルパスを取得
while [[ -L "$SCRIPT_PATH" ]]; do
    SCRIPT_PATH="$(readlink "$SCRIPT_PATH")"
    # 相対パスの場合は絶対パスに変換
    if [[ "$SCRIPT_PATH" != /* ]]; then
        SCRIPT_PATH="$(dirname "${BASH_SOURCE[0]}")/$SCRIPT_PATH"
    fi
done
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"

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

# 設定ファイル管理
CONFIG_DIR="$HOME/.config/sandbox"
CONFIG_FILE="$CONFIG_DIR/paths.conf"

# デフォルト設定ファイルの生成
if [[ ! -f "$CONFIG_FILE" ]]; then
    mkdir -p "$CONFIG_DIR"
    cat > "$CONFIG_FILE" << 'EOF'
# sandbox extra writable paths
# 1行1パス、~ は $HOME に展開されます

# ビルドキャッシュ
~/Library/Caches/ms-playwright
~/Library/Caches/go-build
~/.cache/uv

# パッケージマネージャ
~/go/pkg
~/.npm
~/.cargo

# エディタ
~/.local/share/.nvim
~/.local/state/.nvim
EOF
    echo "Created default config: $CONFIG_FILE" >&2
fi

# 設定ファイルからパスを読み込み、プロファイルに注入する一時ファイルを生成
TEMP_PROFILE=$(mktemp /tmp/sandbox-profile.XXXXXX)
trap 'rm -f "$TEMP_PROFILE"; command -v tmux >/dev/null 2>&1 && [[ -n "$TMUX" ]] && tmux setw monitor-silence 0' EXIT

extra_rules=""
while IFS= read -r line; do
    [[ -z "$line" || "$line" == \#* ]] && continue
    line="${line/#\~/$HOME}"
    extra_rules+="(allow file-write* (subpath \"${line}\"))"$'\n'
done < "$CONFIG_FILE"

# プロファイルテンプレートにルールを注入
while IFS= read -r profile_line; do
    if [[ "$profile_line" == ";; __EXTRA_WRITE_PATHS__" ]]; then
        printf '%s' "$extra_rules"
    else
        printf '%s\n' "$profile_line"
    fi
done < "$PROFILE_FILE" > "$TEMP_PROFILE"

# リソース制限
# macOS では ulimit -v (virtual memory) が使えないため、利用可能な制限を設定
ulimit -f 1048576  # ファイルサイズ: 512MB (512-byte blocks)
ulimit -n 256      # オープンファイル数

# sandbox-execを実行
sandbox-exec \
    "${env_args[@]}" \
    -D "WORKING_DIR=$WORKING_DIR" \
    -f "$TEMP_PROFILE" \
    "$@"
