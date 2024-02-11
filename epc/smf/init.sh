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

export LC_ALL=C.UTF-8
export LANG=C.UTF-8

UE_IPV4_INTERNET_TUN_IP=$(python3 /open5gs/ip_utils.py --ip_range $UE_IPV4_INTERNET)
UE_IPV4_IMS_TUN_IP=$(python3 /open5gs/ip_utils.py --ip_range $UE_IPV4_IMS)
PCSCF_IP=$(nslookup $PCSCF_FQDN | grep 'Address:' | tail -n1 | awk '{print $2}' | sed 's/#.*//')

sed 's|LD_LIBRARY_PATH|$LD_LIBRARY_PATH|g' /config/smf.conf > install/etc/freeDiameter/smf.conf

cp /config/smf.yaml install/etc/open5gs/smf.yaml
sed -i 's|UE_IPV4_INTERNET_TUN_IP|$UE_IPV4_INTERNET_TUN_IP|g' install/etc/open5gs/smf.yaml
sed -i 's|UE_IPV4_IMS_TUN_IP|$UE_IPV4_IMS_TUN_IP|g' install/etc/open5gs/smf.yaml
sed -i 's|PCSCF_IP|$PCSCF_IP|g' install/etc/open5gs/smf.yaml

# Generate TLS certificates
./install/etc/freeDiameter/make_certs.sh install/etc/freeDiameter
