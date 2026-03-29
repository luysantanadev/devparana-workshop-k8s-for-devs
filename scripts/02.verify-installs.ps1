# verify-prereqs.ps1
$ok = $true

foreach ($cmd in @("docker", "k3d", "kubectl", "helm")) {
    if (Get-Command $cmd -ErrorAction SilentlyContinue) {
        Write-Host "OK  $cmd" -ForegroundColor Green
    } else {
        Write-Host "FALTANDO  $cmd" -ForegroundColor Red
        $ok = $false
    }
}

$dockerRunning = docker info 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "OK  Docker Desktop rodando" -ForegroundColor Green
} else {
    Write-Host "FALTANDO  Docker Desktop nao esta rodando — abra o Docker Desktop primeiro" -ForegroundColor Red
    $ok = $false
}

Write-Host ""
if ($ok) {
    Write-Host "Tudo pronto! Pode rodar o setup-workshop.ps1" -ForegroundColor Green
} else {
    Write-Host "Corrija os itens acima antes de continuar." -ForegroundColor Red
}