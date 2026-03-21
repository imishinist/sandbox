# Sandbox

セキュアなサンドボックス環境を提供するツール集です。

## 利用可能なサンドボックス

### 1. Docker版
- `sandbox-docker.sh`: Dockerを使用したサンドボックス
- Docker対応OSで動作（Linux、macOS、Windows）

### 2. macOS版
- `sandbox-macos.sh`: macOS sandbox-execを使用したサンドボックス
- macOS専用

#### セキュリティ機能
- ファイルシステム書き込み制限（作業ディレクトリと許可パスのみ書き込み可）
- 機密ディレクトリ（`~/.ssh`, `~/.gnupg`）へのアクセス拒否
- デバイスアクセス制限（`/dev/disk*`, `/dev/rdisk*`, `/dev/kmem`, `/dev/mem`）
- 危険なコマンド（`sudo`, `su`, `chroot`）の実行拒否
- ネットワーク制限（デフォルトで外部ネットワーク遮断、ローカルホストとDNSは常に許可）
- リソース制限（ファイルサイズ 512MB、オープンファイル数 256）
- HOMEディレクトリからの実行時に警告を表示

#### ネットワーク制限

デフォルトで外部ネットワークアクセスは遮断されます。ローカルホスト（127.0.0.1 / ::1）とDNS解決は常に許可されます。

外部ネットワークアクセスが必要な場合は `-n` / `--network` フラグを使用してください：

```bash
# ネットワーク遮断（デフォルト）
sandbox command args...

# ネットワーク許可
sandbox -n command args...
sandbox --network command args...
```

#### 設定ファイル
ツール固有の書き込み許可パスは `~/.config/sandbox/paths.conf` で管理されます。
初回実行時にデフォルト設定が自動生成されます。

```
# ~/.config/sandbox/paths.conf
# 1行1パス、~ は $HOME に展開されます

~/Library/Caches/go-build
~/.npm
~/.cargo
```

### 3. systemd-run版（Linux）
- `sandbox-systemd.sh`: systemd-runを使用したサンドボックス
- Linux（systemd必須）で動作


## インストール手順

まず、リポジトリをクローンします：

```bash
git clone https://github.com/imishinist/sandbox.git
cd sandbox
```

### Docker版

```bash
ln -s $(pwd)/sandbox-docker.sh ~/.local/bin/sandbox
```

### macOS版

```bash
ln -s $(pwd)/sandbox-macos.sh ~/.local/bin/sandbox
```

### systemd-run版（Linux）

```bash
ln -s $(pwd)/sandbox-systemd.sh ~/.local/bin/sandbox
```

## 詳細情報

Docker版の詳細な使用方法については [DOCKER_SANDBOX.md](./DOCKER_SANDBOX.md) を参照してください。
