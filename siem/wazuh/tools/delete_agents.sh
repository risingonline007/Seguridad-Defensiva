#!/bin/bash

PATH_COMPOSER=/wazuh/.docker
PATH_ACTUAL=$(pwd)

FILE=$1
cd $PATH_COMPOSER
echo "Borrando registro de los agentes Wazuh informados en el fichero $FICHERO ..."
docker compose exec wazuh.manager bash -c "/var/ossec/bin/agent_control -r FILE"
if [ $? == 0 ]
then
	echo "Agentes Wazuh desregistrados: $(cat $FILE)"
else
	RC=$?
	echo "Revisar los agentes Wazuh registrados, ha habido algun problema."
	exit $RC
fi
cd $PATH_ACTUAL
