$composeFiles = @(
    "-f", "compose.base.yaml",
    "-f", ".devcontainer/go/compose.yaml",
    "-f", ".devcontainer/node-nextjs/compose.yaml",
    "-f", ".devcontainer/php-laravel/compose.yaml",
    "-f", ".devcontainer/python/compose.yaml",
    "-f", ".devcontainer/rust/compose.yaml"
)

Write-Host "Installing PHP dependencies..."
docker-compose $composeFiles exec -w /workspace php-app composer install

Write-Host "Installing Go dependencies..."
docker-compose $composeFiles exec -w /workspace go-app go mod tidy
