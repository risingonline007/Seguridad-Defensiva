#!/bin/bash

PATH_BACKUPS=/backups
PATH_CONFIG=/wazuh
PATH_COMPOSE=/wazuh/.docker
PATH_WAZUH_VOLUMES=/var/lib/docker/volumes
PATH_INFO_VOLUMES=/tmp/wazuh.volumes.json
DATE=$(date +%d%m%Y)
NOMBRE_FICHERO=wazuh.backup.$DATE.tar.gz
PATH_ACTUAL=$(pwd)
PATH_BACKUP_LOG=$PATH_BACKUPS/wazuh.backup.$DATE.log

LISTADO=$(ls -la /var/lib/docker/volumes | egrep "filebeat|wazuh" | awk '{print $9}')
VOLUMES_BACKUP=$(for VOLUME in $LISTADO; do  echo "$PATH_WAZUH_VOLUMES/$VOLUME"; done)
for VOLUME in $LISTADO; do docker volume inspect $VOLUME >> $PATH_INFO_VOLUMES; done

cd $PATH_COMPOSE

# Parar aplicacion
echo "Parando los componentes de Wazuh ..." | tee -a $PATH_BACKUP_LOG
docker compose stop | tee -a $PATH_BACKUP_LOG
if [ $? -eq 0 ]
then
	echo "Componentes de Wazuh parados." | tee -a $PATH_BACKUP_LOG
else
	echo "ERROR: Ha habido algún problema, revisar si esta todo parado, el backup no continua." | tee -a $PATH_BACKUP_LOG
fi

# Backup contenedores
echo "Iniciando exportación de contenedores ..." | tee -a $PATH_BACKUP_LOG
docker compose export wazuh.indexer –o wazuh.indexer.$DATE.tar | tee -a $PATH_BACKUP_LOG
docker compose export wazuh.manager –o wazuh.manager.$DATE.tar | tee -a $PATH_BACKUP_LOG
docker compose export wazuh.dashboard –o wazuh.dashboard.$DATE.tar | tee -a $PATH_BACKUP_LOG
echo "Finalizada exportación de contenedores." | tee -a $PATH_BACKUP_LOG


echo "Iniciando backup Wazuh Docker installation ..." | tee -a $PATH_BACKUP_LOG
tar Pzcvf $PATH_BACKUPS/$NOMBRE_FICHERO $PATH_CONFIG $VOLUMES_BACKUP $PATH_INFO_VOLUMES | tee -a $PATH_BACKUP_LOG
RC=$?
if [ $RC == 0 ]
then
	echo "Backup Wazuh finalizado OK." | tee -a $PATH_BACKUP_LOG
	echo 
	echo "Eliminando ficheros temporales ..." | tee -a $PATH_BACKUP_LOG
	rm -f wazuh.indexer.$DATE.tar wazuh.manager.$DATE.tar wazuh.dashboard.$DATE.tar
	rm -f $PATH_INFO_VOLUMES
	echo "Eliminados ficheros temporales." | tee -a $PATH_BACKUP_LOG
else
	RC=$?
	echo "Backup Wazuh NOK." | tee -a $PATH_BACKUP_LOG
fi

# Arrancar aplicación
echo "Iniciando componentes de Wazuh ..." | tee -a $PATH_BACKUP_LOG
docker compose start
echo "Finalizado inicio componentes Wazuh." | tee -a $PATH_BACKUP_LOG
cd $PATH_ACTUAL
exit $RC


