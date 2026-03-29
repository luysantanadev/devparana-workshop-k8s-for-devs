# 1. Instalar as ferramentas
winget install Docker.DockerDesktop
winget install k3d.k3d
winget install Kubernetes.kubectl
winget install Helm.Helm

# 2. IMPORTANTE: antes de continuar
Write-Host ""
Write-Host "PRÓXIMOS PASSOS:" -ForegroundColor Yellow
Write-Host "  1. Feche este terminal para aplicar o PATH" -ForegroundColor Yellow
Write-Host "  2. Abra o Docker Desktop e aguarde o ícone ficar estável na bandeja" -ForegroundColor Yellow
Write-Host "  3. Abra um novo terminal e rode o script de verificacao" -ForegroundColor Yellow