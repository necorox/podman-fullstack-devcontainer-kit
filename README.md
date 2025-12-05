# Podman Fullstack Devcontainer Kit

Podman (または Docker) と VS Code Dev Containers を用いた、**認証機能付きフルスタック開発環境テンプレート**です。

## 特長

* **多言語対応**: PHP (Laravel) / Node.js (Next.js) / Go / Python / Rust の5つの環境を同時に、または個別に利用可能。
* **統合認証基盤**: **Authentik** を標準搭載し、各言語でのトークン認証（JWT）の実装例を提供。
* **充実したインフラ**:
  * PostgreSQL 17
  * Redis 7
  * Authentik (ID Provider)
  * 管理ツール: Redis Commander, pgAdmin 4, Swagger UI/Editor
* **簡単管理**: PowerShellスクリプトで全環境の一括起動・停止が可能。

## 前提条件

* Windows 10/11
* Docker Desktop または Podman Desktop + Docker CLI
* PowerShell
* VS Code (Dev Containers 拡張機能) または Antigravity

### Windows環境変数設定（Podman利用時）

Podmanを使用してコンテナをビルドする場合、以下の環境変数を設定しないとビルドが停止する場合があります。PowerShellで実行してください。

```powershell
[System.Environment]::SetEnvironmentVariable("DOCKER_BUILDKIT", "0", "User")
[System.Environment]::SetEnvironmentVariable("COMPOSE_DOCKER_CLI_BUILD", "0", "User")
```

## クイックスタート

リポジトリ直下のPowerShellスクリプトを使用して、すべての環境を一括で管理できます。

### 1. 起動

```powershell
./start_dev.ps1
```
すべての言語環境とインフラサービス（DB, Redis, Authentik）が起動します。

### 2. 依存関係のインストール (初回のみ)

PHP (Composer) や Go (Modules) の依存関係をインストールします。

```powershell
./setup_deps.ps1
```

### 3. 停止

```powershell
./stop_dev.ps1
```

## ポートマッピング一覧

各言語環境にはインデックス番号が割り当てられており、ポート番号の末尾で識別できます。

| 環境 | Index | アプリ (Host:Container) | DB (Host:5432) | Redis (Host:6379) | ツール群 (RedisCmd/Swagger/Gateway/PgAdmin) |
| :--- | :---: | :--- | :--- | :--- | :--- |
| **Authentik** | - | **9000** | - | - | - |
| **Go** | **1** | **9001**:8080 | 5432**1** | 6379**1** | 901**1**, 902**1**, 903**1**, 904**1** |
| **Node.js** | **2** | **9002**:8080 | 5432**2** | 6379**2** | 901**2**, 902**2**, 903**2**, 904**2** |
| **PHP** | **3** | **9003**:8080 | 5432**3** | 6379**3** | 901**3**, 902**3**, 903**3**, 904**3** |
| **Python** | **4** | **9004**:8080 | 5432**4** | 6379**4** | 901**4**, 902**4**, 903**4**, 904**4** |
| **Rust** | **5** | **9005**:8080 | 5432**5** | 6379**5** | 901**5**, 902**5**, 903**5**, 904**5** |

### 共通インフラ (8xxx)
*   **PgAdmin**: [http://localhost:8000](http://localhost:8000) (Email: `admin@example.com`, Pass: `admin`)
*   **Swagger Editor**: [http://localhost:8001](http://localhost:8001)
*   **Redis Commander**: [http://localhost:8002](http://localhost:8002)
*   **Gateway**: [http://localhost:8081](http://localhost:8081)

## Authentik & 認証デモ

本キットには、Authentikを使用したBearerトークン認証のデモが含まれています。

### Authentik 初期設定
1.  [http://localhost:9000/if/flow/initial-setup/](http://localhost:9000/if/flow/initial-setup/) にアクセス。
2.  `akadmin` ユーザーのパスワードを設定。
3.  [http://localhost:9000/if/admin/](http://localhost:9000/if/admin/) から管理画面にログイン。

### 認証デモの確認
Go, PHP, Rust 環境には `/protected` エンドポイントが実装されており、Bearerトークンの検証ロジックが含まれています。

1.  Authentikでトークンを発行（または任意のJWTを用意）。
2.  以下のURLに `Authorization: Bearer <TOKEN>` ヘッダーを付けてリクエスト。
    *   **Go**: `http://localhost:9001/protected`
    *   **PHP**: `http://localhost:9003/protected`
    *   **Rust**: `http://localhost:9005/protected`

## ディレクトリ構成

```
.
├── .devcontainer/          # 各言語のDevContainer設定 (compose.yaml含む)
│   ├── go/
│   ├── node-nextjs/
│   ├── php-laravel/
│   ├── python/
│   └── rust/
├── go_workspace/           # Go ソースコード
├── node_workspace/         # Node.js ソースコード
├── php_workspace/          # PHP ソースコード
├── py_workspace/           # Python ソースコード
├── rust_workspace/         # Rust ソースコード
├── initdb/                 # DB初期化SQL (Authentik用含む)
├── compose.base.yaml       # 共通インフラ定義
├── start_dev.ps1           # 一括起動スクリプト
├── stop_dev.ps1            # 一括停止スクリプト
└── setup_deps.ps1          # 依存関係インストールスクリプト
```

## 開発のヒント

* **コンテナ内開発**: VS Codeで「Dev Containers: Reopen in Container」を使用すると、特定の言語環境のコンテナに入って開発できます。
* **ポート設定**: アプリケーションはコンテナ内で必ず **8080** 番ポートでリッスンしてください。
