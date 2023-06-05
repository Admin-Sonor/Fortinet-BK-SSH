#!/bin/bash

# Configuración de conexión SSH
HOST="xxxxxx" # ip del host
USER="xxxxxxxxx" # Nombre de usuario SSH
PASSWORD="xxxxxxxxx" # Conftraseña SSH
PUERTO_SSH="xxxxx" # Puerto SSH
thename="bkp-40F-10deOctubre"; # Nombre de router MK
theclient="STRONG" # Empresa
theroute_a="/xxxxxx/xxxxxxxx/"; # Ruta donde se descarga el BK
theroute_b="/xxxxxx/xxxxxxxx"; # Ruta para cambiar Permisos, misma que theroute_a pero quitar / del final
COMANDO="execute backup full-config sftp $theroute_b/backup.conf 10.243.0.220:2781 strongsystems cxxXH9TKi&W8"
db_host="localhost"; # Direccion DB
db_user="xxxxxxxx"; # Usuario DB
db_pass="xxxxxxxx"; # Password DB
db_name="xxxxxxxx"; # DB

# Conexión SSH y ejecución del comando
sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -p "$PUERTO_SSH" "$USER@$HOST" "$COMANDO"

# Renombrado y eliminacion
mv $theroute_b/backup.conf $theroute_b/`date +"%Y-%m-%d"`_backup.conf

# Verificar el estado de salida del comando "SSH" para determinar si la copia de seguridad se realizó correctamente
if [ $? -eq 0 ]; then
  status="OK"
else
  status="NO"
fi

# Permisos Directorios
chmod 754 $theroute_b
chown :backups $theroute_b

# Permisos Archivos
chown :backups $theroute_a*
chmod 754 $theroute_a*

# Conectarse a la base de datos y ejecutar una consulta SQL para insertar los datos
mysql -h $db_host -u $db_user -p$db_pass $db_name << EOF
INSERT INTO backup_logs (status, date, client, system_name) VALUES ('$status', NOW(), '$theclient', '$thename');
EOF
