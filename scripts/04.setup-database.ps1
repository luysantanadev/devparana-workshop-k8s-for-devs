# 04.setup-database.ps1
#
# Deploys a CloudNativePG PostgreSQL cluster via Helm (cnpg/cluster chart)
# and opens a port-forward so local tools (Prisma, psql, etc.) can reach it.
#
# Prerequisites:
#   - CNPG operator running in cnpg-system (installed by 03.setup-k3d-multi-node.ps1)
#   - kubectl and helm available in PATH

param(
    [string]$Namespace    = "todolist",
    [string]$ReleaseName  = "pg",
    [string]$Database     = "app",
    [string]$Username     = "app",
    [string]$Password     = "Wgkk0*6fLy",
    [int]   $Instances    = 1,        # 1 for local dev; 3 for HA
    [string]$StorageSize  = "1Gi",
    [int]   $LocalPort    = 5432,
    [switch]$SkipForward              # deploy only, skip port-forward
)

$ErrorActionPreference = "Stop"

function Write-Step($msg)    { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Write-Success($msg) { Write-Host "OK: $msg"   -ForegroundColor Green }
function Write-Fail($msg)    { Write-Host "ERRO: $msg" -ForegroundColor Red; exit 1 }

$SecretName  = "$ReleaseName-app-credentials"
$ClusterName = "$ReleaseName-cluster"   # CNPG chart names resources as <release>-cluster
$rwSvc       = "$ClusterName-rw"

# ---------------------------------------------------------------------------
# 1. Verify CNPG operator is present
# ---------------------------------------------------------------------------
Write-Step "Verificando CloudNativePG operator..."

$cnpgReady = kubectl -n cnpg-system get deployment cnpg-cloudnative-pg `
    -o jsonpath='{.status.readyReplicas}' 2>$null
if ($cnpgReady -ne "1") {
    Write-Fail "CNPG operator nao esta pronto. Rode '.\scripts\03.setup-k3d-multi-node.ps1' primeiro."
}
Write-Success "CNPG operator pronto."

# ---------------------------------------------------------------------------
# 2. Create namespace
# ---------------------------------------------------------------------------
Write-Step "Criando namespace '$Namespace'..."
kubectl create namespace $Namespace --dry-run=client -o yaml | kubectl apply -f - | Out-Null
Write-Success "Namespace pronto."

# ---------------------------------------------------------------------------
# 3. Create credentials Secret (Kubernetes Secret, not plain-text in values)
#    CNPG expects: username and password keys
# ---------------------------------------------------------------------------
Write-Step "Criando Secret de credenciais '$SecretName'..."

kubectl -n $Namespace create secret generic $SecretName `
    --from-literal=username=$Username `
    --from-literal=password=$Password `
    --dry-run=client -o yaml | kubectl apply -f - | Out-Null

Write-Success "Secret criado."

# ---------------------------------------------------------------------------
# 4. Install / upgrade the CNPG cluster chart
# ---------------------------------------------------------------------------
Write-Step "Instalando cluster PostgreSQL via Helm (release: $ReleaseName)..."

helm repo add cnpg https://cloudnative-pg.github.io/charts 2>$null | Out-Null
helm repo update | Out-Null

helm upgrade --install $ReleaseName cnpg/cluster `
    --namespace $Namespace `
    --set cluster.instances=$Instances `
    --set cluster.storage.size=$StorageSize `
    --set cluster.initdb.database=$Database `
    --set cluster.initdb.owner=$Username `
    --set cluster.initdb.secret.name=$SecretName `
    --set-string cluster.postgresql.parameters.max_connections=200 `
    --wait `
    --timeout 180s

if ($LASTEXITCODE -ne 0) { Write-Fail "Helm install falhou. Verifique os logs acima." }
Write-Success "Cluster PostgreSQL pronto."

# ---------------------------------------------------------------------------
# 5. Show connection info
# ---------------------------------------------------------------------------
Write-Step "Servicos disponiveis no namespace '$Namespace'..."
kubectl -n $Namespace get cluster,pods,svc

$rwSvc = "$ClusterName-rw"

Write-Host ""
Write-Host "Connection string (dentro do cluster):" -ForegroundColor Yellow
Write-Host "  postgresql://${Username}:${Password}@${rwSvc}.${Namespace}.svc.cluster.local:5432/${Database}"
Write-Host ""

if ($SkipForward) {
    Write-Host "Port-forward ignorado (-SkipForward). Para abrir manualmente:" -ForegroundColor Gray
    Write-Host "  kubectl port-forward -n $Namespace svc/$rwSvc ${LocalPort}:5432"
    Write-Host ""
    exit 0
}

# ---------------------------------------------------------------------------
# 6. Port-forward (foreground — keep terminal open)
# ---------------------------------------------------------------------------
Write-Host "============================================" -ForegroundColor Green
Write-Host " Port-forward ativo na porta $LocalPort" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Use esta DATABASE_URL na sua aplicacao:" -ForegroundColor Yellow
Write-Host "  postgresql://${Username}:${Password}@localhost:${LocalPort}/${Database}"
Write-Host ""
Write-Host "Pressione Ctrl+C para encerrar o port-forward." -ForegroundColor Gray
Write-Host ""

kubectl port-forward -n $Namespace svc/$rwSvc "${LocalPort}:5432"
