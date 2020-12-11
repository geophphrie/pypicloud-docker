FROM phusion/baseimage:18.04-1.0.0
MAINTAINER Jeffrey Cross <jeffrey.cross@ambition.com>

ENV PYPICLOUD_VERSION 1.1.7+ambition

EXPOSE 8080

# Install packages required
# 2020-12-11 - jtc - For ambition version, I've pulled out libmysqlclient-dev and libldap2-dev
# from apt-get as we do not use either of these back-ends.
# I split out the RUN commands for troubleshooting, and it doesn't really hurt anything
# to leave it split. I added the pip3 install -U setuptools wheel because it seemed that
# with the old pip 8 that was natively installed, it was trying to build the cryptography
# package (which I added as a specific install but was a dependency for bcrypt) from
# source and failing. With the upgrade to pip/setuptools/wheel it appears to correctly just
# install the wheel. I don't know precisely what solved the problem but something about
# upgrading those tools did!
# I removed mysqlclient from the pip install also, and removed the [all_plugins] option
# from pypicloud. Our implementation only uses built-in features (S3, SQL)
# Note that we install from our own pypicloud pip index via an arg.
ARG PIP_INDEX_URL='https://pypicloud.ambition.ninja/simple/'
RUN apt-get update -qq \
  && DEBIAN_FRONTEND=noninteractive apt-get install -qy python3-pip python3-dev \
     libsasl2-dev libffi-dev libssl-dev bcrypt
RUN pip3 install -U pip wheel
RUN pip3 install cryptography bcrypt requests uwsgi pastescript psycopg2-binary 
# mysqlclient
RUN pip3 install pypicloud==$PYPICLOUD_VERSION

  # Create the pypicloud user
RUN groupadd -r pypicloud \
  && useradd -r -g pypicloud -d /var/lib/pypicloud -m pypicloud \
  # Make sure this directory exists for the baseimage init
  && mkdir -p /etc/my_init.d

# Add the startup service
ADD pypicloud-uwsgi.sh /etc/my_init.d/pypicloud-uwsgi.sh

# Add the pypicloud config file
RUN mkdir -p /etc/pypicloud
ADD config.ini /etc/pypicloud/config.ini

# Create a working directory for pypicloud
VOLUME /var/lib/pypicloud

# Add the command for easily creating config files
ADD make-config.sh /usr/local/bin/make-config

# Add an environment variable that pypicloud-uwsgi.sh uses to determine which
# user to run as
ENV UWSGI_USER pypicloud

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]
