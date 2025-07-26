# Docker Sandbox

systemd-runベースのsandbox.shと同等の機能をDockerで実現したサンドボックス環境です。

## ファイル構成

- `docker-sandbox.sh`: Docker版サンドボックス

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

# Python スクリプトを実行
docker-sandbox python3 script.py
```

## セキュリティ機能

- **権限制限**: すべてのLinux capabilityを削除
- **読み取り専用ルートファイルシステム**: システムファイルの変更を防止
- **プライベート/tmp**: 一時ファイルの分離
- **ユーザーマッピング**: ホストユーザーと同じUID/GIDで実行
- **ネットワーク制限**: 基本的なネットワークアクセスのみ許可
- **リソース制限**: メモリとCPU使用量を制限
- **PID分離**: コンテナ内でのプロセス分離

## ディレクトリアクセス

### 読み取り専用アクセス
- ホームディレクトリ全体（`$HOME`）

### 読み書きアクセス
- 現在の作業ディレクトリ（`$PWD`）
- `~/.config`
- `~/.cache`
- `~/.aws/amazonq`（存在する場合）
- `~/.local/share/amazon-q`（存在する場合）

### アクセス不可
- `~/.ssh`（自然に分離される）
- `~/.gnupg`（自然に分離される）
- システムの重要なディレクトリ

## 元のsandbox.shとの比較

| 機能 | systemd-run版 | Docker版 |
|------|---------------|----------|
| 権限制限 | ✅ | ✅ |
| ファイルシステム保護 | ✅ | ✅ |
| ネットワーク制限 | ✅ | ✅（基本的な制限）|
| プロセス分離 | ✅ | ✅ |
| 一時ディレクトリ分離 | ✅ | ✅ |
| システムコール制限 | ✅ | ✅（Seccomp使用）|
| 依存関係 | systemd | Docker |
| ポータビリティ | Linux（systemd必須） | Docker対応OS |

## トラブルシューティング

### Dockerイメージのリビルド

```bash
# 高機能版のイメージを削除してリビルド
docker rmi sandbox:latest
docker-sandbox-advanced bash
```

### 権限エラー

ホストのUID/GIDとコンテナ内のUID/GIDが一致しない場合：

```bash
# 現在のUID/GIDを確認
id

# 必要に応じてDockerfileのUSER_ID/GROUP_IDを調整
```

### リソース不足

メモリやCPU制限を調整したい場合は、スクリプト内の以下の行を編集：

```bash
docker_options+=('--memory=2g')
docker_options+=('--cpus=2.0')
```

## 注意事項

- 初回実行時はDockerイメージのダウンロード/ビルドに時間がかかります
- Dockerデーモンが実行されている必要があります
- 一部のシステムコールは制限される場合があります
- ネットワークアクセスは基本的な機能のみ利用可能です
