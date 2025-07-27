FROM ubuntu:22.04

# アーキテクチャを指定するためのARG（デフォルトは自動検出）
ARG TARGETARCH
ARG TARGETOS=linux

# 必要なパッケージをインストール
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# アーキテクチャを取得してAmazon Q CLIをダウンロード
RUN if [ -z "$TARGETARCH" ]; then \
        ARCH=$(uname -m); \
        case $ARCH in \
            x86_64) ARCH_NAME="x86_64" ;; \
            aarch64) ARCH_NAME="aarch64" ;; \
            arm64) ARCH_NAME="aarch64" ;; \
            *) echo "Unsupported architecture: $ARCH" && exit 1 ;; \
        esac; \
    else \
        case $TARGETARCH in \
            amd64) ARCH_NAME="x86_64" ;; \
            arm64) ARCH_NAME="aarch64" ;; \
            *) echo "Unsupported target architecture: $TARGETARCH" && exit 1 ;; \
        esac; \
    fi && \
    curl --proto '=https' --tlsv1.2 -sSf "https://desktop-release.q.us-east-1.amazonaws.com/latest/q-${ARCH_NAME}-${TARGETOS}.zip" -o "q.zip" && \
    unzip q.zip && \
    cp q/bin/q /usr/local/bin/q && \
    cp q/bin/qchat /usr/local/bin/qchat && \
    cp q/bin/qterm /usr/local/bin/qterm && \
    chmod +x /usr/local/bin/q /usr/local/bin/qchat /usr/local/bin/qterm && \
    rm -rf q.zip q

# デフォルトのエントリーポイント
CMD ["/bin/bash"]
