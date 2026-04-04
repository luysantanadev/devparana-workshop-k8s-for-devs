# Copilot Instructions - Workshop Kubernetes para Devs

## 1. Visao Geral do Projeto

Este repositorio foi criado para um workshop pratico de Kubernetes para desenvolvedores, com duracao de 3 horas.

O foco e ensinar, passo a passo, como sair do codigo-fonte ate uma aplicacao rodando no cluster Kubernetes local, com deploy via Helm chart.

Publico-alvo:
- Desenvolvedores sem experiencia previa em Kubernetes.
- Pessoas que ja conhecem desenvolvimento de software, mas ainda nao dominam conteineres e orquestracao.

Ambiente padrao do lab:
- Docker Desktop (runtime de containers local).
- k3d (cluster Kubernetes leve executando sobre Docker).

## 2. Stack e Ferramentas

Ferramentas obrigatorias e versoes minimas recomendadas:
- Docker Desktop >= 4.30
- k3d >= 5.6
- kubectl >= 1.30
- Helm >= 3.14

Observacoes:
- Sempre preferir exemplos compativeis com ambiente local (Windows + PowerShell).
- Comandos devem funcionar no contexto de laboratorio, sem exigir infraestrutura cloud.

## 3. Convencoes do Repositorio

- Dockerfile deve ser didatico: cada instrucao importante precisa de comentario explicando o por que da etapa.
- `values.yaml` do Helm deve conter comentarios em todas as chaves configuraveis, explicando impacto e exemplos de uso.
- `guia-lab.md` deve ser escrito em portugues, linguagem acessivel, com comandos completos prontos para copiar e colar.
- Recursos Kubernetes devem seguir o padrao de nome: `workshop-<recurso>`.

## 4. Padroes de Codigo e Arquivos

Ao gerar ou editar Dockerfile:
- Priorizar multi-stage build.
- Priorizar imagens base slim/alpine/distroless quando aplicavel.
- Evitar instrucoes desnecessarias que dificultem o entendimento didatico.

Ao gerar manifests Kubernetes (YAML):
- Incluir sempre `metadata.name`.
- Incluir labels com `app` e `version`.
- Incluir `resources.requests` e `resources.limits` para os containers.
- Evitar tags de imagem ambiguas; usar tags explicitas de versao.

Ao gerar Helm chart:
- Centralizar padroes de nome e labels em `templates/_helpers.tpl`.
- Reutilizar helpers nos manifests para consistencia.
- Evitar hardcode de valores que o aluno precisara alterar; expor no `values.yaml`.

## 5. Fluxo Esperado do Aluno

Durante o workshop, o fluxo de aprendizado esperado e:

1. Clonar o repositorio.
2. Entender o Dockerfile e executar o build da imagem.
3. Subir o cluster local com k3d.
4. Fazer push da imagem para o registry usado pelo k3d.
5. Instalar a aplicacao com `helm install`.
6. Validar com `kubectl get pods` e acessar a aplicacao no browser.

Referencias de escopo do workshop:
- Fundamentos Docker (imagem, container, camadas, registry).
- Containerizacao da app (Dockerfile, build, push, env, docker compose).
- Kubernetes fundamentos (Pod, Deployment, Service, Namespace, kubectl).
- Helm chart na pratica (estrutura, values, install, upgrade, rollback).
- Lab livre + Q&A.

## 6. O Que o Copilot Deve Priorizar

- Clareza didatica acima de otimizacao prematura.
- Comentarios explicativos em arquivos de configuracao e manifests do lab.
- Comandos completos e prontos para rodar, sem omitir flags importantes.
- Explicacoes e sugestoes alinhadas ao nivel iniciante em Kubernetes.
- Respostas com passo a passo objetivo, validacoes apos cada etapa e comandos de verificacao.

## 7. O Que o Copilot Deve Evitar

- Gerar configuracoes avancadas fora do escopo do workshop, como:
	- HPA
	- PodDisruptionBudget
	- Istio
	- cert-manager
- Omitir comentarios nos arquivos didaticos.
- Usar `latest` como tag de imagem.
- Gerar manifests sem `resources.limits`.

## Diretriz Final para Sugestoes

Toda sugestao deve considerar que este e um ambiente de ensino guiado. Priorize previsibilidade, simplicidade operacional e facilidade de reproducao local.
