# Sandbox

セキュアなサンドボックス環境を提供するツール集です。

## 利用可能なサンドボックス

### 1. systemd-run版（Linux）
- `sandbox-systemd.sh`: systemd-runを使用したサンドボックス
- Linux（systemd必須）で動作

### 2. macOS版
- `sandbox-macos.sh`: macOS sandbox-execを使用したサンドボックス
- macOS専用

### 3. Docker版
- `sandbox-docker.sh`: Dockerを使用したサンドボックス
- Docker対応OSで動作（Linux、macOS、Windows）

## インストール手順

### systemd-run版（Linux）

```bash
ln -s $(pwd)/sandbox-systemd.sh ~/.local/bin/sandbox
```

### macOS版

```bash
ln -s $(pwd)/sandbox-macos.sh ~/.local/bin/sandbox
```

### Docker版

```bash
ln -s $(pwd)/sandbox-docker.sh ~/.local/bin/sandbox
```

## 詳細情報

Docker版の詳細な使用方法については [DOCKER_SANDBOX.md](./DOCKER_SANDBOX.md) を参照してください。
## 詳細情報

Docker版の詳細な使用方法については [DOCKER_SANDBOX.md](./DOCKER_SANDBOX.md) を参照してください。
