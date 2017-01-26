#!/bin/sh

# Setup environment
. /cvmfs/grid.cern.ch/emi-wn-3.15.3-1_sl6v1/etc/profile.d/setup-wn-example.sh
export X509_USER_PROXY=/etc/proxy/proxy

# Run the glidein
cd /pool/glidein
/usr/local/bin/glidein_startup.sh `cat /etc/glideinargs/glideinargs`
