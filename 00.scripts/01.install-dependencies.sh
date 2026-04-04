#!/usr/bin/env bash
# ==============================================================================
# SYNOPSIS
#   Instala ou atualiza todas as ferramentas necessárias para o workshop de
#   Kubernetes local com k3d em Ubuntu/Debian.
#
# DESCRIPTION
#   - Docker Engine não instalado → instala via script oficial.
#   - k3d, kubectl e Helm → instalam via curl/apt se ausentes.
#   - Ferramentas já instaladas → prossegue sem alteração.
#
#   Por padrão o Docker Engine NÃO é instalado. Use --install-docker para incluí-lo.
#
# USAGE
#   ./01.install-dependencies.sh              # instala apenas k3d, kubectl e Helm
#   ./01.install-dependencies.sh --install-docker
#
# NOTES
#   Execute com sudo ou como root para instalar Docker Engine.
#   k3d, kubectl e Helm são instalados no escopo do usuário (~/.local/bin ou /usr/local/bin).
# ==============================================================================

set -euo pipefail

INSTALL_DOCKER=false

for arg in "$@"; do
  case "$arg" in
    --install-docker) INSTALL_DOCKER=true ;;
  esac
done

# Cores ANSI
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

write_step()    { echo -e "\n${CYAN}==> $1${RESET}"; }
write_success() { echo -e "    ${GREEN}OK: $1${RESET}"; }
write_warn()    { echo -e "    ${YELLOW}AVISO: $1${RESET}"; }
write_fail()    { echo -e "\n    ${RED}ERRO: $1${RESET}"; exit 1; }

# Detecta se um comando existe no PATH
command_exists() { command -v "$1" &>/dev/null; }

# ---------------------------------------------------------------------------
# Docker Engine — opcional, requer sudo
# ---------------------------------------------------------------------------
install_docker() {
  write_step "Docker Engine"

  if command_exists docker; then
    write_success "Docker já está instalado ($(docker --version 2>&1 | head -1)). Pulando."
    return
  fi

  if [[ $EUID -ne 0 ]]; then
    write_fail "A instalação do Docker requer sudo. Execute: sudo $0 --install-docker"
  fi

  write_step "Instalando Docker Engine via script oficial..."
  curl -fsSL https://get.docker.com | sh

  # Adiciona o usuário atual ao grupo docker para dispensar sudo no uso diário
  if [[ -n "${SUDO_USER:-}" ]]; then
    usermod -aG docker "$SUDO_USER"
    write_warn "Usuário '$SUDO_USER' adicionado ao grupo docker. Faça logout/login para aplicar."
  fi

  systemctl enable --now docker
  write_success "Docker Engine instalado e ativado."
}

# ---------------------------------------------------------------------------
# k3d — instala via script oficial (https://k3d.io)
# ---------------------------------------------------------------------------
install_k3d() {
  write_step "k3d"

  if command_exists k3d; then
    write_success "k3d já instalado ($(k3d --version 2>&1 | head -1)). Pulando."
    return
  fi

  write_step "Instalando k3d..."
  curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
  write_success "k3d instalado."
}

# ---------------------------------------------------------------------------
# kubectl — instala via binário oficial do Kubernetes
# ---------------------------------------------------------------------------
install_kubectl() {
  write_step "kubectl"

  if command_exists kubectl; then
    write_success "kubectl já instalado ($(kubectl version --client --short 2>&1 | head -1)). Pulando."
    return
  fi

  write_step "Instalando kubectl..."
  local ARCH
  ARCH=$(uname -m)
  [[ "$ARCH" == "x86_64" ]] && ARCH="amd64"
  [[ "$ARCH" == "aarch64" ]] && ARCH="arm64"

  local KUBE_VERSION
  KUBE_VERSION=$(curl -fsSL https://dl.k8s.io/release/stable.txt)

  curl -fsSLo /usr/local/bin/kubectl \
    "https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/${ARCH}/kubectl"
  chmod +x /usr/local/bin/kubectl
  write_success "kubectl ${KUBE_VERSION} instalado."
}

# ---------------------------------------------------------------------------
# Helm — instala via script oficial (https://helm.sh)
# ---------------------------------------------------------------------------
install_helm() {
  write_step "Helm"

  if command_exists helm; then
    write_success "Helm já instalado ($(helm version --short 2>&1 | head -1)). Pulando."
    return
  fi

  write_step "Instalando Helm..."
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  write_success "Helm instalado."
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
write_step "Verificando pré-requisitos (curl)..."
if ! command_exists curl; then
  write_fail "curl não encontrado. Instale com: sudo apt-get install -y curl"
fi
write_success "curl disponível."

if $INSTALL_DOCKER; then
  install_docker
else
  write_step "Docker Engine"
  write_warn "Pulando instalação do Docker (use --install-docker para incluir)."
fi

install_k3d
install_kubectl
install_helm

echo ""
echo -e "${GREEN}============================================================${RESET}"
echo -e "${GREEN}  Ferramentas instaladas/atualizadas com sucesso!${RESET}"
echo -e "${GREEN}============================================================${RESET}"
echo ""
echo -e "${YELLOW}PRÓXIMOS PASSOS:${RESET}"
echo -e "${YELLOW}  1. Recarregue o terminal: source ~/.bashrc${RESET}"
echo -e "${YELLOW}  2. Certifique-se que o daemon Docker está rodando: sudo systemctl status docker${RESET}"
echo -e "${YELLOW}  3. Execute: ./02.verify-installs.sh${RESET}"
echo ""
