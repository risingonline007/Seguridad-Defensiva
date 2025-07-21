# Support files to Module Secure Web Gateway





\*\*\* squid.conf \*\*\*



* Configuración básica para el proxy Squid (parent proxy) de la DMZ.
* Permite por defecto la conexión HTTPS unicamente al puerto 443 y por HTTP a todos los demás puertos indicados en el fichero de configuración (una lista, que incluye el rango de puertos no reservados).
* Incluye una directiva include a un directorio acls donde se podrían ubicar reglas específicas para direcciones orígenes y destinos (a modo firewall HTTP/HTTPS).





