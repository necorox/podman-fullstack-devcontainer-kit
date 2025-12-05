$composeFiles = @(
    "-f", "compose.base.yaml",
    "-f", ".devcontainer/go/compose.yaml",
    "-f", ".devcontainer/node-nextjs/compose.yaml",
    "-f", ".devcontainer/php-laravel/compose.yaml",
    "-f", ".devcontainer/python/compose.yaml",
    "-f", ".devcontainer/rust/compose.yaml"
)

Write-Host "Starting all devcontainer environments..."
docker-compose $composeFiles up -d --build
