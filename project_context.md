# Project Context & Configuration Summary

This document summarizes the project structure, infrastructure configuration, and development environment details for AI assistants.

## Project Overview
**Name**: Podman Fullstack Devcontainer Kit
**Goal**: A modular devcontainer setup supporting multiple languages (Go, Node.js, PHP, Python, Rust) with shared infrastructure (Postgres, Redis, Authentik).
**OS**: Windows (User uses `docker-compose` which aliases to Podman or handles Podman interaction).

## Directory Structure
```
.
├── .devcontainer/          # Devcontainer configurations for each language
│   ├── go/                 # Go environment (Air, Delve)
│   ├── node-nextjs/        # Node.js environment
│   ├── php-laravel/        # PHP environment
│   ├── python/             # Python environment
│   └── rust/               # Rust environment
├── go_workspace/           # Source code for Go
├── node_workspace/         # Source code for Node.js
├── php_workspace/          # Source code for PHP
├── py_workspace/           # Source code for Python
├── rust_workspace/         # Source code for Rust
├── initdb/                 # SQL initialization scripts for Postgres
├── docs/                   # Documentation and API specs
├── compose.base.yaml       # Shared infrastructure services (DB, Redis, Authentik)
├── nginx.conf              # Gateway configuration
└── README.md               # Human-readable documentation
```

## Infrastructure Services (`compose.base.yaml`)
These services are shared across all language environments.

| Service | Image | Internal Port | Host Port | Description |
| :--- | :--- | :--- | :--- | :--- |
| `db` | `postgres:17` | 5432 | 5433 | Main PostgreSQL database. Data volume: `pgdata`. |
| `redis` | `redis:7-alpine` | 6379 | 6379 | Redis cache. |
| `authentik-server` | `ghcr.io/goauthentik/server` | 9000, 9443 | 9000, 9443 | Identity Provider. |
| `authentik-worker` | `ghcr.io/goauthentik/server` | - | - | Background worker for Authentik. |
| `redisCommander` | `redis-commander` | 8081 | 8002 | Redis GUI. |
| `pgadmin` | `dpage/pgadmin4` | 80 | 8000 | PostgreSQL GUI. |
| `swagger-editor` | `swaggerapi/swagger-editor` | 8080 | 8001 | OpenAPI editor. |
| `gateway` | `nginx:alpine` | 80 | 8081 | Nginx reverse proxy. |

## Language Environments
Each language has its own `compose.yaml` in `.devcontainer/<lang>/` which extends/overrides the base configuration.

### Common Configuration
- **Network**: `devnet` (Bridge network shared by all services)
- **Workspace Mount**: `../../<lang>_workspace:/workspace`

### Port Mappings (Environment Specific)
To avoid conflicts when running multiple environments, ports are offset.

| Environment | App Port (Host:Container) | DB Port (Host:5432) | Redis Port (Host:6379) | RedisCmd (Host:8081) | Swagger (Host:8080) | Gateway (Host:80) | PgAdmin (Host:80) |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Go** (`go-app`) | 9001:8080 | 54321 | 63791 | 9011 | 9021 | 9031 | 9041 |
| **Node.js** (`node-app`) | 9002:3000 | 54322 | 63792 | 9012 | 9022 | 9032 | 9042 |
| **PHP** (`php-app`) | 9003:8000 | 54323 | 63793 | 9013 | 9023 | 9033 | 9043 |
| **Python** (`python-app`) | 9004:8000 | 54324 | 63794 | 9014 | 9024 | 9034 | 9044 |
| **Rust** (`rust-app`) | 9005:8080 | 54325 | 63795 | 9015 | 9025 | 9035 | 9045 |

## Authentication (Authentik)
- **Admin URL**: `http://localhost:9000/if/admin/`
- **Initial Setup**: `http://localhost:9000/if/flow/initial-setup/`
- **Integration**:
    - Services validate Bearer tokens (JWT).
    - JWKS URL pattern: `http://authentik-server:9000/application/o/<slug>/jwks/`
    - Rust implementation uses `actix-web` + `jsonwebtoken` to fetch JWKS and validate.

## Key Commands
- **Start Environment**: `docker-compose up -d` (Run inside `.devcontainer/<lang>/`)
- **Verify Auth**: `./verify_auth.sh <TOKEN>` (Root directory)
