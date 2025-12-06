# Podman Fullstack Devcontainer Kit

Podman (または Docker) と VS Code Dev Containers を用いた、**認証機能付きフルスタック開発環境テンプレート**です。

## 特長

* **All-in-One開発環境**: 1つのコンテナで Go, Node.js, PHP, Python, Rust のすべての開発が可能。
* **Docker-outside-of-Docker (DooD)**: 開発コンテナ内からホストのDocker(Podman)を操作し、アプリコンテナを起動できます。
* **統合認証基盤**: **Authentik** を標準搭載。
* **充実したインフラ**: PostgreSQL 17, Redis 7, 管理ツール群 (Redis Commander, pgAdmin 4, Swagger UI/Editor)。

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

### 1. 開発環境の起動

VS Code でこのフォルダを開き、`F1` → `Dev Containers: Reopen in Container` を選択します。
**"Fullstack Dev Environment"** が起動し、すべての言語ツールが利用可能な状態になります。

### 2. インフラとアプリの起動

DevContainer内のターミナル、またはホストのPowerShellから以下のスクリプトを実行します。

```powershell
./start_dev.ps1
```
すべての言語環境（アプリコンテナ）とインフラサービス（DB, Redis, Authentik）が起動します。

### 3. 依存関係のインストール (初回のみ)

```powershell
./setup_deps.ps1
```

### 4. 停止

```powershell
./stop_dev.ps1
```

## ポートマッピング一覧

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

## ディレクトリ構成

```
.
├── .devcontainer/          # 開発環境 (All-in-One) 設定
│   ├── devcontainer.json
│   ├── Dockerfile
│   └── compose.yaml
├── services/               # アプリ実行用Docker設定
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
├── initdb/                 # DB初期化SQL
├── compose.base.yaml       # 共通インフラ定義
├── start_dev.ps1           # 一括起動スクリプト
├── stop_dev.ps1            # 一括停止スクリプト
└── setup_deps.ps1          # 依存関係インストールスクリプト
```
