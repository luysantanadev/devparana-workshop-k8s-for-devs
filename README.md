# Workshop — Kubernetes para Devs

Repositório do workshop prático de **Kubernetes para Desenvolvedores** da comunidade Dev Paraná.

Em aproximadamente 3 horas, você parte do código-fonte e chega a uma aplicação rodando em um cluster Kubernetes local, com deploy gerenciado por Helm chart.

---

## Sobre o Workshop

**Público-alvo:** Desenvolvedores que conhecem código mas ainda não dominam containers e orquestração.

**Ambiente:** 100% local — sem conta em cloud, sem custo. Tudo roda no seu computador via Docker Desktop e k3d.

**Aplicação usada:** Dashboard full-stack construído com Nuxt 4, Prisma ORM e OpenTelemetry — uma aplicação real, não um "hello world".

---

## Pré-requisitos

| Ferramenta | Versão mínima | Para que serve |
|---|---|---|
| [Docker Desktop](https://www.docker.com/products/docker-desktop/) | 4.30 | Runtime de containers |
| [k3d](https://k3d.io) | 5.6 | Cluster Kubernetes leve sobre Docker |
| [kubectl](https://kubernetes.io/docs/tasks/tools/) | 1.30 | CLI do Kubernetes |
| [Helm](https://helm.sh) | 3.14 | Gerenciador de pacotes do Kubernetes |

Se preferir instalar tudo de uma vez:

```powershell
# Windows — instala k3d, kubectl e Helm via winget
.\00.scripts\windows\01.install-dependencies.ps1

# Com Docker Desktop também
.\00.scripts\windows\01.install-dependencies.ps1 -InstallDocker
```

```bash
# Linux/macOS
bash 00.scripts/linux/01.install-dependencies.sh
```

Verifique se tudo está correto antes de continuar:

```powershell
.\00.scripts\windows\02.verify-installs.ps1
```

---

## Estrutura do Repositório

```
00.scripts/              # Scripts de setup do ambiente (Windows e Linux)
01.docker-images/        # Módulo 1 — Imagem estática Nginx, Dockerfile comentado
02.docker-envs/          # Módulo 2 — Variáveis de ambiente com Node.js
03.docker-compose/       # Módulo 3 — Multi-serviço com Docker Compose
04.fundamentos-kubernetes/  # Módulo 4 — Manifestos Kubernetes progressivos
05.helm-chart/           # Módulo 5 — Helm chart completo + aplicação Nuxt
06.explorando/           # Roteiro livre de comandos kubectl para explorar o cluster
```

---

## Fluxo do Workshop

### 1. Criar o cluster local

```powershell
.\00.scripts\windows\03.setup-k3d-multi-node.ps1
```

O script cria o cluster `workshop` com:
- 1 server + 2 agents
- Traefik como Ingress Controller (portas 80/443)
- Registry local em `localhost:5001`
- CloudNativePG operator para PostgreSQL

### 2. Subir o banco de dados

```powershell
.\00.scripts\windows\04.setup-database.ps1
```

Cria um cluster PostgreSQL via CloudNativePG no namespace `todolist` e abre um port-forward resiliente na porta `5432`.

### 3. Construir e publicar a imagem

```powershell
cd 05.helm-chart/app

docker build -t nuxt-workshop:1.0.0 .
docker tag nuxt-workshop:1.0.0 localhost:5001/nuxt-workshop:1.0.0
docker push localhost:5001/nuxt-workshop:1.0.0
```

### 4. Instalar a aplicação com Helm

```powershell
helm upgrade --install nuxt-workshop .\05.helm-chart\helm\ `
  --namespace default `
  --wait
```

### 5. Acessar no browser

Adicione ao arquivo `C:\Windows\System32\drivers\etc\hosts`:

```
127.0.0.1  nuxt-workshop.local
```

Acesse: **http://nuxt-workshop.local**

---

## Módulos em Detalhes

### Módulo 1 — Imagem Docker estática (`01.docker-images/`)

Serve um site HTML/CSS/JS via Nginx na porta 8080. Usa `nginxinc/nginx-unprivileged` — processo já roda como não-root sem nenhum `RUN chown`.

```powershell
cd 01.docker-images
.\windows\01.docker-build-run.ps1
```

### Módulo 2 — Variáveis de ambiente (`02.docker-envs/`)

Servidor Node.js que lê variáveis de ambiente e as exibe em uma página HTML. Ideal para demonstrar `ENV`, `-e`, ConfigMap e Secret no Kubernetes.

```powershell
cd 02.docker-envs
.\docker-build-run.ps1
```

### Módulo 3 — Docker Compose (`03.docker-compose/`)

Sobe a mesma app em três ambientes simultâneos (`dev`, `homologation`, `production`) demonstrando três formas diferentes de injetar variáveis: inline, `env_file` e combinação dos dois.

```powershell
cd 03.docker-compose
docker compose up
```

Serviços disponíveis após o `up`:
- `http://localhost:3001` — dev
- `http://localhost:3002` — homologação
- `http://localhost:8080` — produção

### Módulo 4 — Fundamentos Kubernetes (`04.fundamentos-kubernetes/`)

Cinco manifestos progressivos, cada um introduzindo um novo conceito:

| Arquivo | Recursos | Conceito |
|---|---|---|
| `01-pod.yaml` | Pod | Menor unidade do K8s; sem auto-healing |
| `02-deployment-configmap.yaml` | Deployment + ConfigMap | Self-healing, rolling update, configuração externalizada |
| `03-statefulset-secret.yaml` | StatefulSet + Secret + Headless Service | Estado persistente, credenciais seguras |
| `04-deployment-service.yaml` | Deployment + Service | Descoberta de serviço, load balancing interno |
| `05-deployment-completo.yaml` | ConfigMap + Secret + Deployment + Service + Ingress + HPA | Tudo junto |

```powershell
# Aplique e explore cada arquivo em sequência
kubectl apply -f 04.fundamentos-kubernetes/01-pod.yaml
kubectl get pods
kubectl delete -f 04.fundamentos-kubernetes/01-pod.yaml
```

### Módulo 5 — Helm Chart (`05.helm-chart/`)

Chart completo para a aplicação Nuxt. Centraliza convenções de nomes em `_helpers.tpl` e expõe toda a configuração no `values.yaml`.

```powershell
# Ver o que seria gerado sem aplicar
helm template nuxt-workshop .\05.helm-chart\helm\

# Instalar
helm upgrade --install nuxt-workshop .\05.helm-chart\helm\ --wait

# Atualizar após mudar o values.yaml
helm upgrade nuxt-workshop .\05.helm-chart\helm\

# Histórico de releases
helm history nuxt-workshop

# Rollback para a release anterior
helm rollback nuxt-workshop
```

### Módulo 6 — Explorando o Cluster (`06.explorando/`)

Roteiro de comandos kubectl para copiar e colar diretamente no terminal. Cobre 14 tópicos: contexto, nodes, namespaces, Pods, Deployments, ReplicaSets, Services, ConfigMaps, Secrets, logs, exec, port-forward, rollout e limpeza.

```
06.explorando/kubectl-explorar.ps1   # Windows
```

---

## Observabilidade (opcional)

Stack completa de observabilidade via Helm no namespace `monitoring`:

```powershell
.\00.scripts\windows\05.setup-monitoring.ps1
```

Instala:
- **Prometheus** — métricas
- **Grafana** — dashboards (usuário: `admin`, senha: `workshop123`)
- **Loki** — logs
- **Tempo** — rastreamento distribuído
- **Pyroscope** — profiling contínuo
- **Alloy** — coletor unificado (OpenTelemetry)

---

## Comandos Úteis

```powershell
# Status geral do cluster
kubectl get all -A

# Logs da aplicação em tempo real
kubectl logs -l app.kubernetes.io/name=nuxt-workshop -f

# Acessar a aplicação sem Ingress
kubectl port-forward service/nuxt-workshop 8080:80

# Resetar o cluster do zero
k3d cluster delete workshop
.\00.scripts\windows\03.setup-k3d-multi-node.ps1
```

---

## Política de execução no Windows

Se o PowerShell bloquear a execução dos scripts:

```powershell
# Libera apenas para a sessão atual (recomendado)
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

---

## Licença

[MIT](LICENSE)