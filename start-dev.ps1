$ErrorActionPreference = "Stop"

# スクリプトのあるディレクトリをルートとする
$rootDir = $PSScriptRoot
$infraDir = Join-Path $rootDir "infrastructure"

# ベースとなる設定ファイルを最初に指定
$composeFiles = @("infrastructure/compose.tools.yaml")

# infrastructureディレクトリ内の他の compose.*.yaml を自動検出して追加
if (Test-Path $infraDir) {
    Get-ChildItem -Path $infraDir -Filter "compose.*.yaml" | ForEach-Object {
        $relativePath = "infrastructure/" + $_.Name
        # baseは既に追加済みなので除外
        if ($_.Name -ne "compose.tools.yaml") {
            $composeFiles += $relativePath
        }
    }
}

# docker-composeの引数を構築
$composeArgs = @()
foreach ($file in $composeFiles) {
    $composeArgs += "-f"
    $composeArgs += $file
}

# 引数がなければ "up -d" をデフォルトとする
if ($args.Count -eq 0) {
    $composeArgs += "up"
    $composeArgs += "-d"
} else {
    $composeArgs += $args
}

Write-Host "Executing: docker-compose $composeArgs" -ForegroundColor Cyan
& docker-compose $composeArgs
