#!/bin/bash
set -e

cd /tmp
curl -LO http://www.routemeister.net/projects/sipcalc/files/sipcalc-1.1.6.tar.gz
tar -xzvf sipcalc-1.1.6.tar.gz
cd sipcalc-1.1.6

sudo yum install -y glibc-static
CFLAGS=-static ./configure
make
sudo cp src/sipcalc /srv/sipcalc
