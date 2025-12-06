#!/bin/bash
set -e

# スクリプトのあるディレクトリへ移動（パス解決のため）
cd "$(dirname "$0")"

# ベースとなる設定ファイルを最初に指定
COMPOSE_FILES="-f infrastructure/compose.tools.yaml"

# infrastructureディレクトリ内の他の compose.*.yaml を自動検出して追加
# findコマンドで安全にファイルを探す（ファイルが存在しない場合のエラー回避）
if [ -d "infrastructure" ]; then
    for file in infrastructure/compose.*.yaml; do
        # globが展開されなかった場合のガード
        [ -e "$file" ] || continue
        
        # baseは既に追加済みなので除外
        if [ "$(basename "$file")" != "compose.tools.yaml" ]; then
            COMPOSE_FILES="$COMPOSE_FILES -f $file"
        fi
    done
fi

# 引数がなければ "up -d" をデフォルトとする
if [ $# -eq 0 ]; then
    CMD="up -d"
else
    CMD="$@"
fi

echo "Executing: docker-compose $COMPOSE_FILES $CMD"
docker-compose $COMPOSE_FILES $CMD
