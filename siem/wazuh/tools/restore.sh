#!/bin/bash

PATH_BACKUPS=/backups
PATH_CONFIG=/wazuh
PATH_COMPOSE=/wazuh/.docker
PATH_WAZUH_VOLUMES=/var/lib/docker/volumes
PATH_INFO_VOLUMES=/tmp/wazuh.volumes.json
DATE=$(date +%d%m%Y)
NOMBRE_FICHERO=$1
PATH_ACTUAL=$(pwd)

# Control básico de errores

if [ $# != 1 ]
then
	echo "ERROR: Falta informar fichero de backup a recuperar."
	echo
	echo "Formato: $0 FICHERO_RESTORE"
	echo "FICHERO_RESTORE debe ser alguna de las copias realizadas y ubicadas en /backups"
	exit 1
fi

if [ ! -f $PATH_BACKUPS/$NOMBRE_FICHERO ]
then
	echo "ERROR: Fichero indicado como parsmetro no existe."
	exit 2
fi

exit 0

cd /
tar zxvf $PATH_BACKUPS/$NOMBRE_FICHERO wazuh
LISTADO=$(egrep "filebeat|wazuh" $PATH_COMPOSE/docker-compose.yml | egrep "_|-" | egrep -v " -|image|hostname" | sed 's/://g' | sed 's/ //g')
for VOLUME in $LISTADO; do docker volume create docker_$VOLUME; done

tar zxvf $PATH_BACKUPS/$NOMBRE_FICHERO $PATH_WAZUH_VOLUMES

cd $PATH_COMPOSE

# Instalar aplicación
docker compose up -d



