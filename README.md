docker-c7-sugarcrmstack-for-s7.8
==========

Docker Images of CentOS-7 7.x x86_64

Includes SSH server, RVM, ruby 2.3, puppet 4.x, Apache 2.4 + PHP 5.6
SSH server includes public key authentication, Automated password generation and supports custom configuration via environment variables.

## Overview & links

The Dockerfile can be used to build a base image that is the bases for several other docker images.

Included in the build are the [EPEL](http://fedoraproject.org/wiki/EPEL) and [REMI]  repositories. Installed packages include [OpenSSH](http://www.openssh.com/portable.html) secure shell, [Sudo](http://www.courtesan.com/sudo/) and [vim-minimal](http://www.vim.org/) are along with python-setuptools, [supervisor](http://supervisord.org/) and [supervisor-stdout](https://github.com/coderanger/supervisor-stdout).

[Supervisor](http://supervisord.org/) is used to start and the sshd daemon when a docker container based on this image is run. To enable simple viewing of stdout for the sshd subprocess, supervisor-stdout is included. This allows you to see output from the supervisord controlled subprocesses with `docker logs {container-name}`.

SSH access is by public key authentication and, by default, the [Vagrant](http://www.vagrantup.com/) [insecure private key](https://github.com/mitchellh/vagrant/blob/master/keys/vagrant) is required.

### SSH Alternatives

SSH is not required in order to access a terminal for the running container. The simplest method is to use the docker exec command to run bash (or sh) as follows:

```
$ docker exec -it {container-name-or-id} bash
```

For cases where access to docker exec is not possible the preferred method is to use Command Keys and the nsenter command. 

## Quick Example

