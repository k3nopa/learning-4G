#!/bin/bash

# BSD 2-Clause License

# Copyright (c) 2020, Supreeth Herle
# All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

while ! mysqladmin ping -h scscf-mysql-svc --silent; do
	sleep 5;
done

# Sleep until permissions are set
sleep 10;

# Create SCSCF database, populate tables and grant privileges
if [[ -z "`mysql -u root -h scscf-mysql-svc -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='scscf'" 2>&1`" ]];
then
	mysql -u root -h scscf-mysql-svc -e "create database scscf;"
	mysql -u root -h scscf-mysql-svc scscf < /init/standard-create.sql
	mysql -u root -h scscf-mysql-svc scscf < /init/presence-create.sql
	mysql -u root -h scscf-mysql-svc scscf < /init/ims_usrloc_scscf-create.sql
	mysql -u root -h scscf-mysql-svc scscf < /init/ims_dialog-create.sql
	mysql -u root -h scscf-mysql-svc scscf < /init/ims_charging-create.sql
	
	SCSCF_USER_EXISTS=`mysql -u root -h scscf-mysql-svc -s -N -e "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE User = 'scscf' AND Host = '%')"`
	if [[ "$SCSCF_USER_EXISTS" == 0 ]]
	then
		mysql -u root -h scscf-mysql-svc -e "CREATE USER 'scscf'@'%' IDENTIFIED WITH mysql_native_password BY 'heslo'";
		mysql -u root -h scscf-mysql-svc -e "CREATE USER 'scscf'@'ims-scscf-svc' IDENTIFIED WITH mysql_native_password BY 'heslo'";
		mysql -u root -h scscf-mysql-svc -e "GRANT ALL ON scscf.* TO 'scscf'@'%'";
		mysql -u root -h scscf-mysql-svc -e "GRANT ALL ON scscf.* TO 'scscf'@'ims-scscf-svc'";
		mysql -u root -h scscf-mysql-svc -e "FLUSH PRIVILEGES;"
	fi
fi

# Sync docker time
#ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
