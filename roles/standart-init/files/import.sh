#!/bin/bash

### Script installs root.cert.pem to certificate trust store of applications using NSS
### (e.g. Firefox, Thunderbird, Chromium)
### Mozilla uses cert8, Chromium and Chrome use cert9

###
### Requirement: apt install libnss3-tools or yum install nss-tools
###


###
### CA file to install (CUSTOMIZE!)
###

certfile="/etc/pki/ca-trust/source/anchors/VARB-CA.crt"
certname="VARB CA Limited"


###
### For cert8 (legacy - DBM)
###

for certDB in $(find /home/userrit/ -name "cert8.db")
do
    certdir=$(dirname ${certDB});
    certutil -A -n "${certname}" -t "TCu,Cu,Tu" -i ${certfile} -d dbm:${certdir}
done


###
### For cert9 (SQL)
###

for certDB in $(find /home/userrit/ -name "cert9.db")
do
    certdir=$(dirname ${certDB});
    certutil -A -n "${certname}" -t "TCu,Cu,Tu" -i ${certfile} -d sql:${certdir}
done

exit 0
