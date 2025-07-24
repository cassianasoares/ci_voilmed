#!/bin/bash

echo "🔄 Atualizando pacotes..."
sudo apt update

echo "🔍 Verificando se o Docker está instalado..."
if ! command -v docker &> /dev/null; then
  echo "📦 Instalando Docker..."
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh
  sudo systemctl start docker
else
  echo "✅ Docker já está instalado."
fi

echo "🔍 Verificando acesso ao Docker (sem sudo)..."
if ! groups | grep -q '\bdocker\b'; then
  echo "🔧 Adicionando usuário '$(whoami)' ao grupo docker.."
  sudo usermod -aG docker $(whoami)
  echo "🔁 Aplicando novo grupo à sessão..."
  exec sudo -u $(whoami) newgrp docker
  echo "⚠️ Se os comandos seguintes ainda falharem, faça logout/login manualmente."
else
  echo "✅ Usuário já pertence ao grupo docker."
fi

echo "📦 Carregando imagem Docker..."
docker load -i ci_voilmed-api.tar

echo "📝 Renomeando arquivo docker-compose..."
mv docker-compose-prod.yaml docker-compose.yaml

container_ids=$(docker ps -q)

if [ -z "$container_ids" ]; then
  echo "🚫 Não há containers em execução."
else
  for container_id in $container_ids; do
    echo "🛑 Parando container: $container_id"
    docker stop $container_id
  done
  echo "✅ Todos os containers foram parados."
fi

echo "🚀 Subindo containers com docker compose..."
docker compose up -d