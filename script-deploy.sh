#!/bin/bash

# Verifica se o MySQL já está instalado
if ! command -v mysql &> /dev/null; then
  echo "MySQL não está instalado. Instalando agora..."
  sudo apt update
  sudo apt install -y mysql-server
  sudo systemctl start mysql
else
  echo "MySQL já está instalado."
fi

# Verifica se o Docker está instalado
if ! command -v docker &> /dev/null; then
  echo "Docker não está instalado. Instalando agora..."
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh
  sudo systemctl start docker
  sudo usermod -aG docker $USER
else
  echo "Docker já está instalado."
fi


echo "Carregando imagem Docker..."
docker load -i ci_voilmed-api.tar

echo "Renomeando arquivo docker-compose..."
mv docker-compose-prod.yaml docker-compose.yaml

container_ids=$(docker ps -q)

if [ -z "$container_ids" ]; then
  echo "Não há containers em execução."
else
  for container_id in $container_ids; do
    echo "Parando container: $container_id"
    docker stop $container_id
  done
  echo "Todos os containers em execução foram parados."
fi

echo "Subindo containers com docker compose..."
docker compose up -d
