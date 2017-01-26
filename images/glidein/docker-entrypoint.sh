#!/bin/sh

# Setup CVMFS repositories
rm -f /dev/fuse
mknod -m 666 /dev/fuse c 10 229

mount -t cvmfs cms.cern.ch /cvmfs/cms.cern.ch
mount -t cvmfs grid.cern.ch /cvmfs/grid.cern.ch

# Get CA certs from CVMFS
rm -rf /etc/grid-security
ln -sf /cvmfs/grid.cern.ch/etc/grid-security /etc/grid-security

# Run the glidein wrapper
mkdir -p /pool/glidein
chown glidein_pilot /pool/glidein
sudo -u glidein_pilot /usr/local/bin/run.sh
