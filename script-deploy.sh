#!/bin/bash

echo "🔍 Verificando se o MySQL está instalado..."
if ! command -v mysql &> /dev/null; then
  echo "📦 Instalando MySQL..."
  apt update
  apt install -y mysql-server
  systemctl start mysql
else
  echo "✅ MySQL já está instalado."
fi

echo "🔍 Verificando se o Docker está instalado..."
if ! command -v docker &> /dev/null; then
  echo "📦 Instalando Docker..."
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
  systemctl start docker
else
  echo "✅ Docker já está instalado."
fi

# 🔐 Verifica se o usuário está no grupo docker
if ! groups $USER | grep -q '\bdocker\b'; then
  echo "🔧 Adicionando usuário '$USER' ao grupo docker..."
  sudo usermod -aG docker $USER
  echo "⚠️ IMPORTANTE: Logout/login necessário para usar Docker sem sudo."
else
  echo "✅ Usuário '$USER' já está no grupo docker."
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