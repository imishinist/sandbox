FROM ubuntu:22.04

# 必要なパッケージをインストール
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Amazon Q CLIをダウンロードしてバイナリを配置
RUN curl --proto '=https' --tlsv1.2 -sSf "https://desktop-release.q.us-east-1.amazonaws.com/latest/q-x86_64-linux.zip" -o "q.zip" \
    && unzip q.zip \
    && cp q/bin/q /usr/local/bin/q \
    && cp q/bin/qchat /usr/local/bin/qchat \
    && cp q/bin/qterm /usr/local/bin/qterm \
    && chmod +x /usr/local/bin/q /usr/local/bin/qchat /usr/local/bin/qterm \
    && rm -rf q.zip q

# デフォルトのエントリーポイント
CMD ["/bin/bash"]
