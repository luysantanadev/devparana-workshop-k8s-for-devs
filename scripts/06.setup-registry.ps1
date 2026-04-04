<#
.SYNOPSIS
    Instala Harbor container registry no cluster via Helm e abre port-forward para UI e push de imagens.

.DESCRIPTION
    - Usa expose.type=clusterIP: Harbor sobe seu proprio nginx como gateway interno.
      Isso significa que o Traefik NAO e envolvido e nenhuma configuracao extra e necessaria.
      (Se usassemos expose.type=ingress, precisariamos remover annotations do nginx-ingress
       e configurar expose.ingress.className=traefik.)
    - TLS desabilitado: HTTP puro em localhost. Docker aceita HTTP em localhost sem configuracao extra.
    - Trivy desabilitado: economiza ~1Gi de disco e ~200Mi de RAM desnecessarios num lab local.
    - Um unico port-forward serve tanto a interface web quanto o push de imagens (mesma porta).
    - Port-forward roda como background job vinculado a esta sessao.

.NOTES
    Pre-requisito: cluster k3d 'workshop' em execucao (03.setup-k3d-multi-node.ps1).
    UI acessivel em : http://localhost:8181
    Push de imagens : docker push localhost:8181/library/<imagem>:<tag>
#>

param(
    [string]$Namespace   = "registry",
    [string]$ReleaseName = "harbor",
    [string]$AdminPass   = "Harbor12345",
    [int]   $LocalPort   = 8181,
    [switch]$SkipForward              # instala apenas, sem abrir port-forward
)

$ErrorActionPreference = "Stop"

function Write-Step($msg)    { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Write-Success($msg) { Write-Host "    OK: $msg" -ForegroundColor Green }
function Write-Warn($msg)    { Write-Host "    AVISO: $msg" -ForegroundColor Yellow }
function Write-Fail($msg)    { Write-Host "`n    ERRO: $msg" -ForegroundColor Red; exit 1 }

# O Harbor chart fixa o nome do servico ClusterIP via expose.clusterIP.name (default: "harbor").
$HarborSvc = "harbor"

# ---------------------------------------------------------------------------
# 1. Pre-checks
# ---------------------------------------------------------------------------
Write-Step "Verificando pre-requisitos..."

@("kubectl", "helm", "docker") | ForEach-Object {
    if (-not (Get-Command $_ -ErrorAction SilentlyContinue)) {
        Write-Fail "$_ nao encontrado no PATH. Instale antes de continuar."
    }
}

$ctx = kubectl config current-context 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Fail "Nenhum contexto Kubernetes ativo. Rode '.\scripts\03.setup-k3d-multi-node.ps1' primeiro."
}
Write-Success "Contexto ativo: $ctx"

# ---------------------------------------------------------------------------
# 2. Helm repo
# ---------------------------------------------------------------------------
Write-Step "Adicionando repo do Harbor..."

helm repo add harbor https://helm.goharbor.io 2>$null | Out-Null
helm repo update | Out-Null

Write-Success "Repo harbor atualizado."

# ---------------------------------------------------------------------------
# 3. Namespace
# ---------------------------------------------------------------------------
Write-Step "Criando namespace '$Namespace'..."

kubectl create namespace $Namespace --dry-run=client -o yaml | kubectl apply -f - | Out-Null
Write-Success "Namespace pronto."

# ---------------------------------------------------------------------------
# 4. Instalar Harbor via Helm
#
#  Decisoes de configuracao:
#   expose.type=clusterIP    -> Harbor usa nginx proprio; Traefik nao e necessario
#   expose.tls.enabled=false -> HTTP simples; Docker permite insecure em localhost
#   trivy.enabled=false      -> economiza disco e memoria no lab local
#   updateStrategy=Recreate  -> evita conflito de PVC ReadWriteOnce em rolling update
#   persistence.resourcePolicy="" -> PVCs sao removidos com 'helm uninstall'
#
#  Recursos minimos (suficiente para workshop single-node):
#   nginx      50m / 64Mi   (proxy frontend do Harbor)
#   portal     50m / 64Mi   (SPA Angular servida pelo nginx)
#   core      100m / 128Mi  (servico principal do Harbor)
#   jobservice  50m /  64Mi (executor de tarefas asincronas)
#   registry    50m / 128Mi (OCI distribution registry)
#   database   100m / 256Mi (PostgreSQL interno)
#   redis       50m /  64Mi (cache e filas)
# ---------------------------------------------------------------------------
Write-Step "Instalando Harbor via Helm (release: $ReleaseName, namespace: $Namespace)..."
Write-Host "    Aguarde - a inicializacao do banco pode levar ate 5 minutos..." -ForegroundColor Gray

helm upgrade --install $ReleaseName harbor/harbor `
    --namespace $Namespace `
    --set expose.type=clusterIP `
    --set expose.tls.enabled=false `
    --set-string "externalURL=http://localhost:$LocalPort" `
    --set "harborAdminPassword=$AdminPass" `
    --set trivy.enabled=false `
    --set updateStrategy.type=Recreate `
    --set "persistence.resourcePolicy=" `
    --set "persistence.persistentVolumeClaim.registry.size=2Gi" `
    --set "nginx.resources.requests.cpu=50m" `
    --set "nginx.resources.requests.memory=64Mi" `
    --set "nginx.resources.limits.cpu=200m" `
    --set "nginx.resources.limits.memory=128Mi" `
    --set "portal.resources.requests.cpu=50m" `
    --set "portal.resources.requests.memory=64Mi" `
    --set "portal.resources.limits.cpu=200m" `
    --set "portal.resources.limits.memory=128Mi" `
    --set "core.resources.requests.cpu=100m" `
    --set "core.resources.requests.memory=128Mi" `
    --set "core.resources.limits.cpu=500m" `
    --set "core.resources.limits.memory=256Mi" `
    --set "jobservice.resources.requests.cpu=50m" `
    --set "jobservice.resources.requests.memory=64Mi" `
    --set "jobservice.resources.limits.cpu=200m" `
    --set "jobservice.resources.limits.memory=128Mi" `
    --set "registry.registry.resources.requests.cpu=50m" `
    --set "registry.registry.resources.requests.memory=128Mi" `
    --set "registry.registry.resources.limits.cpu=200m" `
    --set "registry.registry.resources.limits.memory=256Mi" `
    --set "registry.controller.resources.requests.cpu=50m" `
    --set "registry.controller.resources.requests.memory=32Mi" `
    --set "registry.controller.resources.limits.cpu=100m" `
    --set "registry.controller.resources.limits.memory=64Mi" `
    --set "database.internal.resources.requests.cpu=100m" `
    --set "database.internal.resources.requests.memory=256Mi" `
    --set "database.internal.resources.limits.cpu=500m" `
    --set "database.internal.resources.limits.memory=512Mi" `
    --set "database.internal.shmSizeLimit=128Mi" `
    --set "redis.internal.resources.requests.cpu=50m" `
    --set "redis.internal.resources.requests.memory=64Mi" `
    --set "redis.internal.resources.limits.cpu=200m" `
    --set "redis.internal.resources.limits.memory=128Mi" `
    --wait `
    --timeout 300s

if ($LASTEXITCODE -ne 0) {
    Write-Fail "Helm install falhou. Verifique com: kubectl get pods -n $Namespace"
}
Write-Success "Harbor instalado com sucesso."

# ---------------------------------------------------------------------------
# 5. Status dos pods
# ---------------------------------------------------------------------------
Write-Step "Pods do Harbor no namespace '$Namespace'..."
kubectl -n $Namespace get pods

# ---------------------------------------------------------------------------
# 6. Informacoes de acesso e comandos docker
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "=============================================" -ForegroundColor Green
Write-Host "  Harbor Registry instalado!                " -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Interface web  : http://localhost:$LocalPort" -ForegroundColor Yellow
Write-Host "  Usuario admin  : admin" -ForegroundColor Yellow
Write-Host "  Senha admin    : $AdminPass" -ForegroundColor Yellow
Write-Host ""
Write-Host "  NOTA: UI e push de imagens usam a mesma porta ($LocalPort)." -ForegroundColor Gray
Write-Host "  O Harbor roteia internamente: '/' -> portal, '/v2/' -> registry." -ForegroundColor Gray
Write-Host ""
Write-Host "  Comandos para enviar uma imagem ao registry:" -ForegroundColor Yellow
Write-Host ""
Write-Host "    # 1. Autenticar" -ForegroundColor Cyan
Write-Host "    docker login localhost:$LocalPort -u admin -p $AdminPass" -ForegroundColor White
Write-Host ""
Write-Host "    # 2. Baixar a imagem base do Docker Hub" -ForegroundColor Cyan
Write-Host "    docker pull alpine:latest" -ForegroundColor White
Write-Host ""
Write-Host "    # 3. Retagear para o registry local" -ForegroundColor Cyan
Write-Host "    docker tag alpine:latest localhost:$LocalPort/library/alpine:latest" -ForegroundColor White
Write-Host ""
Write-Host "    # 4. Enviar para o Harbor" -ForegroundColor Cyan
Write-Host "    docker push localhost:$LocalPort/library/alpine:latest" -ForegroundColor White
Write-Host ""
Write-Host "    # 5. (Opcional) Verificar no portal" -ForegroundColor Cyan
Write-Host "    Start-Process 'http://localhost:$LocalPort/harbor/projects'" -ForegroundColor White
Write-Host ""

if ($SkipForward) {
    Write-Host "    Port-forward ignorado (-SkipForward). Para abrir manualmente:" -ForegroundColor Gray
    Write-Host "    kubectl port-forward -n $Namespace svc/$HarborSvc ${LocalPort}:80"
    Write-Host ""
    exit 0
}

# ---------------------------------------------------------------------------
# 7. Port-forward como background job (sessao vinculada)
#    Um unico port-forward serve tanto a UI quanto o push de imagens.
#    Se o processo cair (ex: pod reiniciou), o loop reconecta automaticamente.
# ---------------------------------------------------------------------------
$pfJob = Start-Job -ScriptBlock {
    param($ns, $svc, $port)
    while ($true) {
        kubectl port-forward -n $ns svc/$svc "${port}:80"
        if ($LASTEXITCODE -eq 0) { break }
        Start-Sleep -Seconds 3
    }
} -ArgumentList $Namespace, $HarborSvc, $LocalPort

Write-Host ""
Write-Success "Port-forward rodando em background (Job ID: $($pfJob.Id))."
Write-Host ""
Write-Host "    Para verificar o status : Receive-Job $($pfJob.Id)" -ForegroundColor Gray
Write-Host "    Para encerrar           : Stop-Job $($pfJob.Id); Remove-Job $($pfJob.Id)" -ForegroundColor Gray
Write-Host ""
Write-Host "    Aguarde alguns segundos e acesse: http://localhost:$LocalPort" -ForegroundColor Gray
Write-Host ""
