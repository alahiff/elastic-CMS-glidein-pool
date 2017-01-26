FROM centos:6

RUN yum -y update
RUN yum -y install sudo wget glibc-headers python-argparse
RUN wget http://cvmrepo.web.cern.ch/cvmrepo/yum/cvmfs-release-latest.noarch.rpm && \
    yum -y localinstall cvmfs-release-latest.noarch.rpm
RUN yum -y install cvmfs cvmfs-config-default

COPY default.local /etc/cvmfs/
COPY cms.cern.ch.local /etc/cvmfs/config.d/
RUN mkdir -p /cvmfs/cms.cern.ch /cvmfs/grid.cern.ch /etc/cms

COPY glidein_startup.sh /usr/local/bin/
COPY run.sh /usr/local/bin/
COPY docker-entrypoint.sh /

RUN useradd glidein_pilot

ENTRYPOINT ["/docker-entrypoint.sh"]
