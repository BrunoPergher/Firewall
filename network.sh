#!/bin/bash

# Nome das redes
EXTERNAL_NET="external_net"
DMZ_NET="dmz_net"
INTERNAL_NET="internal_net"

# Criar redes Docker, se não existirem
docker network create --driver bridge $EXTERNAL_NET || true
docker network create --driver bridge $DMZ_NET || true
docker network create --driver bridge $INTERNAL_NET || true

# Conectar os contêineres às redes apropriadas
# Externa
docker network connect $EXTERNAL_NET pc_externo || true

# DMZ
docker network connect $DMZ_NET caliandra || true
docker network connect $DMZ_NET caiman || true
docker network connect $DMZ_NET dns_server || true
docker network connect $DMZ_NET ad_server || true
docker network connect $DMZ_NET web_server || true
docker network connect $DMZ_NET bd_server || true
docker network connect $DMZ_NET app_server || true
docker network connect $DMZ_NET arquivos_server || true

# Interna
docker network connect $INTERNAL_NET pc_interno || true

# Exibir redes e verificações de conectividade
echo "Redes Docker criadas e configurações aplicadas:"
docker network ls
docker network inspect $EXTERNAL_NET
docker network inspect $DMZ_NET
docker network inspect $INTERNAL_NET

echo "Redes configuradas com sucesso."

