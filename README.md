# Sandbox

セキュアなサンドボックス環境を提供するツール集です。

## 利用可能なサンドボックス

### 1. systemd-run版（オリジナル）
- `sandbox.sh`: systemd-runを使用したサンドボックス
- Linux（systemd必須）で動作

### 2. Docker版
- `docker-sandbox.sh`: Dockerを使用したサンドボックス
- Docker対応OSで動作（Linux、macOS、Windows）

## インストール手順

### systemd-run版

```bash
ln -s $(pwd)/sandbox.sh ~/.local/bin/sandbox
```

### Docker版

```bash
ln -s $(pwd)/docker-sandbox.sh ~/.local/bin/docker-sandbox
```

## 詳細情報

Docker版の詳細な使用方法については [DOCKER_SANDBOX.md](./DOCKER_SANDBOX.md) を参照してください。
