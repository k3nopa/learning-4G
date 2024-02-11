
while ! mysqladmin ping -h smsc-mysql-svc --silent; do
	echo "Checking mysql if alive";
	sleep 5;
done

# Sleep until permissions are set
echo "Sleep 10 s until permissions are set";
sleep 10;

# Drop SMSC database
echo "Preparing database";
mysql -u root -h smsc-mysql-svc -e "drop database smsc;"

# Create SMSC database, populate tables and grant privileges
if [[ -z "`mysql -u root -h smsc-mysql-svc -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='smsc'" 2>&1`" ]];
then
	mysql -u root -h smsc-mysql-svc -e "create database smsc;"
	mysql -u root -h smsc-mysql-svc smsc < /init/standard-create.sql
	mysql -u root -h smsc-mysql-svc smsc < /init/smsc-create.sql
	mysql -u root -h smsc-mysql-svc smsc < /init/dialplan-create.sql
	mysql -u root -h smsc-mysql-svc smsc < /init/presence-create.sql

	SMSC_USER_EXISTS=`mysql -u root -h smsc-mysql-svc -s -N -e "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE User = 'smsc' AND Host = '%')"`
	if [[ "$SMSC_USER_EXISTS" == 0 ]]
	then
		mysql -u root -h smsc-mysql-svc -e "CREATE USER 'smsc'@'%' IDENTIFIED WITH mysql_native_password BY 'heslo'";
		mysql -u root -h smsc-mysql-svc -e "CREATE USER 'smsc'@'ims-smsc-svc' IDENTIFIED WITH mysql_native_password BY 'heslo'";
		mysql -u root -h smsc-mysql-svc -e "GRANT ALL ON smsc.* TO 'smsc'@'%'";
		mysql -u root -h smsc-mysql-svc -e "GRANT ALL ON smsc.* TO 'smsc'@'ims-smsc-svc'";
		mysql -u root -h smsc-mysql-svc -e "FLUSH PRIVILEGES;"
	fi
fi