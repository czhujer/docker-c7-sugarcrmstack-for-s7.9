# =============================================================================
# sugarfactory/c7-sugarcrmstack-for-s7.8
#
# CentOS-7 7.x x86_64 - EPEL,REMI repos, RVM, Ruby 2.3 / Supervisor / OpenSSH, Apache + PHP, ...
# 
# =============================================================================
FROM sugarfactory/centos7-ssh-puppet:0.1-2

MAINTAINER Patrik Majer <patrik.majer@sugarfactory.cz>

# -----------------------------------------------------------------------------
# fix symlink for module folder
# -----------------------------------------------------------------------------
RUN bash -c "if [ ! -L /etc/puppetlabs/code/modules ]; then \
    rm -rf /etc/puppetlabs/code/modules; \
    mkdir -p /etc/puppet/modules; \
    mkdir -p /etc/puppetlabs/code; \
    ln -s /etc/puppet/modules/ /etc/puppetlabs/code/modules; \
  fi; \
  ";

# -----------------------------------------------------------------------------
# copy r10k config
# -----------------------------------------------------------------------------
ADD r10k/Puppetfile \
    /etc/puppet/Puppetfile

# -----------------------------------------------------------------------------
# run r10k
# -----------------------------------------------------------------------------
#RUN bash -c 'source /etc/bashrc; cd /etc/puppet && r10k -v info puppetfile install || exit 0'
RUN bash -c 'source /etc/bashrc; cd /etc/puppet && r10k -v info puppetfile install'

RUN bash -c 'source /etc/bashrc; puppet module list'

# -----------------------------------------------------------------------------
# prepare hiera gen-items script
# -----------------------------------------------------------------------------
ADD scripts/hiera-items-handler.pl \
    /etc/puppet/hiera-items-handler.pl

RUN bash -c "source /etc/bashrc; \
           puppet apply -e  \"\
            package { [\"perl-YAML-Tiny\", \
             \"perl-Digest-SHA1\", \
             \"perl-ExtUtils-MakeMaker\", \
             \"perl-ExtUtils-Manifest\", \
             \"perl-Test-Simple\"]: \
             ensure => installed, \
          }\"; \
      ";

RUN bash -c "source /etc/bashrc; \
           puppet apply -e \"\
            perl::module { 'Crypt::RandPasswd': \
              exec_environment => [\\\"INSTALL_BASE=/usr/share/perl5\\\"], \
              package_downcase => false, \
              package_suffix   => \\\"\\\", \
              package_prefix   => \\\"\\\", \
            }\"; \
          ";

# -----------------------------------------------------------------------------
# copy sugarcrmstack and manifest
# -----------------------------------------------------------------------------
COPY puppet/sugarcrm-stack /etc/puppet/modules/sugarcrmstack

ADD puppet/sugarcrm-init-for-sugarcrm-7.8-lite-docker.pp \
    /etc/puppet/manifests/sugarcrm-init-for-sugarcrm-7.8-lite-docker.pp

RUN bash -c "source /etc/bashrc; puppet apply /etc/puppet/manifests"

ADD supervisor/crond.conf \
    /etc/supervisord.d/crond.conf
ADD supervisor/httpd.conf \
    /etc/supervisord.d/httpd.conf
ADD supervisor/postfix.conf \
    /etc/supervisord.d/postfix.conf

# -----------------------------------------------------------------------------
# purge yum and rpm unused files
# -----------------------------------------------------------------------------
RUN rm -rf /var/cache/yum/* \
    && yum clean all \
    && rm -rf /usr/share/phpMyAdmin/.git/*
#     \
#       && /bin/find /usr/share \
#               -type f \
#               -regextype posix-extended \
#               -regex '.*\.(jpg|png)$' \
#               -delete

# -----------------------------------------------------------------------------
# expose
# -----------------------------------------------------------------------------

EXPOSE 22

# -----------------------------------------------------------------------------
# Set default environment variables
# -----------------------------------------------------------------------------
ENV SSH_AUTHORIZED_KEYS="" \
    SSH_AUTOSTART_SSHD=true \
    SSH_AUTOSTART_SSHD_BOOTSTRAP=true \
    SSH_CHROOT_DIRECTORY="%h" \
    SSH_INHERIT_ENVIRONMENT=false \
    SSH_SUDO="ALL=(ALL) ALL" \
    SSH_USER="app-admin" \
    SSH_USER_FORCE_SFTP=false \
    SSH_USER_HOME="/home/%u" \
    SSH_USER_ID="500:500" \
    SSH_USER_PASSWORD="" \
    SSH_USER_PASSWORD_HASHED=false \
    SSH_USER_SHELL="/bin/bash"

CMD ["/usr/bin/supervisord", "--configuration=/etc/supervisord.conf"]
