# Docker Sandbox

systemd-runベースのsandbox.shと同等の機能をDockerで実現したサンドボックス環境です。Amazon Q CLIが事前にインストールされたカスタムイメージを使用します。

## ファイル構成

- `docker-sandbox.sh`: Docker版サンドボックス
- `Dockerfile`: Amazon Q CLI付きのカスタムイメージ定義

## インストール手順

```bash
ln -s $(pwd)/docker-sandbox.sh ~/.local/bin/docker-sandbox
```

## 使用方法

### 基本的な使用

```bash
# シェルを起動
docker-sandbox bash

# コマンドを実行
docker-sandbox ls -la

# Amazon Q CLIを使用
docker-sandbox q chat

# Python スクリプトを実行
docker-sandbox python3 script.py
```

### 初回実行

初回実行時は自動的にDockerイメージ（`sandbox-amazonq:latest`）がビルドされます。Amazon Q CLIが含まれるため、ビルドに数分かかる場合があります。

## セキュリティ機能

- **権限制限**: すべてのLinux capabilityを削除（`--cap-drop=ALL`）
- **新しい権限の取得を禁止**: `--security-opt=no-new-privileges:true`
- **読み取り専用ルートファイルシステム**: システムファイルの変更を防止（`--read-only`）
- **プライベート一時ディレクトリ**: `/tmp`, `/var/tmp`, `/run`を分離（各100MB制限）
- **ユーザーマッピング**: ホストユーザーと同じUID/GIDで実行
- **ネットワーク制限**: bridgeネットワークのみ許可
- **リソース制限**: メモリ1GB、CPU 1.0コア制限
- **ホスト名の匿名化**: `sandbox`として設定
- **PID分離**: コンテナ内でのプロセス分離

## ディレクトリアクセス

### 読み取り専用アクセス
- 必須設定ファイル: `.bashrc`, `.bash_profile`, `.profile`, `.gitconfig`
- システムファイル: `/etc/passwd`

### 読み書きアクセス
- 現在の作業ディレクトリ（`$PWD`）
- `~/.config`（存在する場合）
- `~/.cache`（存在する場合）
- `~/.local/share/amazon-q`（存在する場合）
- `~/.aws/amazonq`（存在する場合）

### 一時的なホームディレクトリ
- ホームディレクトリ全体がtmpfsとしてマウント（500MB制限）
- 必要な設定ファイルのみ読み取り専用でマウント
- セッション終了時に自動的にクリーンアップ

### アクセス不可
- `~/.ssh`（自然に分離される）
- `~/.gnupg`（自然に分離される）
- システムの重要なディレクトリ

## 元のsandbox.shとの比較

| 機能 | systemd-run版 | Docker版 |
|------|---------------|----------|
| 権限制限 | ✅ | ✅ |
| ファイルシステム保護 | ✅ | ✅ |
| ネットワーク制限 | ✅ | ✅（bridge制限）|
| プロセス分離 | ✅ | ✅ |
| 一時ディレクトリ分離 | ✅ | ✅（tmpfs使用）|
| システムコール制限 | ✅ | ✅（Dockerのseccomp）|
| Amazon Q CLI | ❌ | ✅（事前インストール）|
| 依存関係 | systemd | Docker |
| ポータビリティ | Linux（systemd必須） | Docker対応OS |
| イメージサイズ | - | ~200MB |

## トラブルシューティング

### Dockerイメージのリビルド

```bash
# イメージを削除してリビルド
docker rmi sandbox-amazonq:latest
docker-sandbox bash
```

### 権限エラー

ホストのUID/GIDとコンテナ内のUID/GIDが一致しない場合：

```bash
# 現在のUID/GIDを確認
id

# スクリプトは自動的にホストのUID/GIDを使用します
```

### リソース不足

メモリやCPU制限を調整したい場合は、スクリプト内の以下の行を編集：

```bash
# docker-sandbox.sh内で編集
docker_options+=('--memory=2g')      # メモリ制限を2GBに変更
docker_options+=('--cpus=2.0')       # CPU制限を2コアに変更
```

### Amazon Q CLIの設定

Amazon Q CLIの設定は永続化されます：

```bash
# 設定の確認
docker-sandbox q configure list

# 新しい設定
docker-sandbox q configure
```

### ディスク容量不足

一時ディレクトリのサイズ制限を調整：

```bash
# docker-sandbox.sh内で編集
docker_options+=("--tmpfs=/tmp:noexec,nosuid,nodev,size=200m")  # 200MBに変更
docker_options+=("--tmpfs=${HOME}:noexec,nosuid,nodev,size=1g") # 1GBに変更
```

## 注意事項

- 初回実行時はDockerイメージのビルドに時間がかかります（Amazon Q CLIのダウンロード含む）
- Dockerデーモンが実行されている必要があります
- 一部のシステムコールは制限される場合があります
- ネットワークアクセスは基本的な機能のみ利用可能です
- ホームディレクトリの変更はセッション終了時に失われます（設定ファイルは永続化）
- Amazon Q CLIの認証情報は`~/.aws/amazonq`に永続化されます
