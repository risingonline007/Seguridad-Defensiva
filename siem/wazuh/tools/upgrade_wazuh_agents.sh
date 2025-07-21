#!/bin/bash

PATH_COMPOSER=/wazuh/.docker
PATH_ACTUAL=$(pwd)

cd $PATH_COMPOSER
AGENTES_ACTIVOS=$(docker compose exec wazuh.manager bash -c "/var/ossec/bin/agent_control -lc | grep -v 000 | cut -d"," -f1 | sed 's/   ID: //g'")
echo "Actualizando agentes Wazuh activos: $AGENTES_ACTIVOS ..."
docker compose exec wazuh.manager bash –c “/var/ossec/bin/agent_upgrade –a $AGENTES_ACTIVOS”
if [ $? == 0 ]
then
	echo "Agentes Wazuh $AGENTES_ACTIVOS estan actualizados."
else
	RC=$?
	echo "Revisar manualmente el estado de los agentes, ha habido algún problema."
	exit $RC
fi
cd $PATH_ACTUAL
