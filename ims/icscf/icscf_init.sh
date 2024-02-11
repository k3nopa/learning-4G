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

while ! mysqladmin ping -h icscf-mysql-svc --silent; do
	sleep 5;
done

# Sleep until permissions are set
sleep 10;

# Create ICSCF database, populate tables and grant privileges
if [[ -z "`mysql -u root -h icscf-mysql-svc -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='icscf'" 2>&1`" ]];
then
	mysql -u root -h icscf-mysql-svc -e "create database icscf;"
	mysql -u root -h icscf-mysql-svc icscf < /init/icscf.sql

	ICSCF_USER_EXISTS=`mysql -u root -h icscf-mysql-svc -s -N -e "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE User = 'icscf' AND Host = '%')"`
	if [[ "$ICSCF_USER_EXISTS" == 0 ]]
	then
		mysql -u root -h icscf-mysql-svc -e "CREATE USER 'icscf'@'%' IDENTIFIED WITH mysql_native_password BY 'heslo'";
		mysql -u root -h icscf-mysql-svc -e "CREATE USER 'provisioning'@'%' IDENTIFIED WITH mysql_native_password BY 'provi'";
		mysql -u root -h icscf-mysql-svc -e "CREATE USER 'icscf'@'ims-icscf-svc' IDENTIFIED WITH mysql_native_password BY 'heslo'";
		mysql -u root -h icscf-mysql-svc -e "CREATE USER 'provisioning'@'ims-icscf-svc' IDENTIFIED WITH mysql_native_password BY 'provi'";
		mysql -u root -h icscf-mysql-svc -e "GRANT ALL ON icscf.* TO 'icscf'@'%'";
		mysql -u root -h icscf-mysql-svc -e "GRANT ALL ON icscf.* TO 'icscf'@'ims-icscf-svc'";
		mysql -u root -h icscf-mysql-svc -e "GRANT ALL ON icscf.* TO 'provisioning'@'%'";
		mysql -u root -h icscf-mysql-svc -e "GRANT ALL ON icscf.* TO 'provisioning'@'ims-icscf-svc'";
		mysql -u root -h icscf-mysql-svc -e "FLUSH PRIVILEGES;"
	fi
fi

DOMAIN_PRESENT=`mysql -u root -h icscf-mysql-svc icscf -s -N -e "SELECT count(*) FROM nds_trusted_domains WHERE trusted_domain='ims.mnc001.mcc001.3gppnetwork.org';"`
if [[ "$DOMAIN_PRESENT" == 0 ]]
then
	mysql -u root -h icscf-mysql-svc icscf -e "INSERT INTO nds_trusted_domains (trusted_domain) VALUES ('ims.mnc001.mcc001.3gppnetwork.org');"
fi

URI_PRESENT=`mysql -u root -h icscf-mysql-svc icscf -s -N -e "SELECT count(*) FROM s_cscf WHERE s_cscf_uri='sip:scscf.ims.mnc001.mcc001.3gppnetwork.org:6060';"`
if [[ "$URI_PRESENT" == 0 ]]
then
	mysql -u root -h icscf-mysql-svc icscf -e "INSERT INTO s_cscf (name, s_cscf_uri) VALUES ('First and only S-CSCF', 'sip:scscf.ims.mnc001.mcc001.3gppnetwork.org:6060');"
fi

SCSCF_ID=`mysql -u root -h icscf-mysql-svc icscf -s -N -e "SELECT id FROM s_cscf WHERE s_cscf_uri='sip:scscf.ims.mnc001.mcc001.3gppnetwork.org:6060' LIMIT 1;"`
CAP_PRESENT=`mysql -u root -h icscf-mysql-svc icscf -s -N -e "SELECT count(*) FROM s_cscf_capabilities WHERE id_s_cscf='$SCSCF_ID';"`
if [[ "$CAP_PRESENT" == 0 ]]
then
	mysql -u root -h icscf-mysql-svc icscf -e "INSERT INTO s_cscf_capabilities (id_s_cscf, capability) VALUES ('$SCSCF_ID', 0),('$SCSCF_ID', 1);"
fi

# Sync docker time
#ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
