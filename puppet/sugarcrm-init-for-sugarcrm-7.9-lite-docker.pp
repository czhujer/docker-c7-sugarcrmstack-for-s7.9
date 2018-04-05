###############################
#
# SugarCRM example manifest
#
#
###############################

Service {
  provider => dummy
}

    class { 'sugarcrmstack_ng':
      apache_php_apache_manage_user => false,
    }

    # change MC color scheme
    #
    if ! defined (Package["mc"]){
      package { 'mc':
        ensure => "installed",
      }
    }

    if ! defined (File["/root/.mc"]){
      file { '/root/.mc':
        ensure => directory,
        mode    => '0755',
        owner   => 'root',
      }
    }

    #$mc_color_schema = "gray,black:normal=orange,black:selected=black,brown:marked=black,white:markselect=black,brown:errors=white,red:menu=black,brown:reverse=brightbrown,black:dnormal=black,lightgray:dfocus=black,cyan:dhotnormal=blue,lightgray:dhotfocus=blue,cyan:viewunderline=black,green:menuhot=white,gray:menusel=white,black:menuhotsel=yellow,black:helpnormal=black,lightgray:helpitalic=red,lightgray:helpbold=blue,lightgray:helplink=black,cyan:helpslink=yellow,blue:gauge=white,black:input=brown,gray:directory=brown,gray:executable=brown,gray:link=brightbrown,gray:stalelink=brightred,blue:device=magenta,gray:core=red,blue:special=black,blue:editnormal=white,black:editbold=yellow,blue:editmarked=black,white:errdhotnormal=yellow,red:errdhotfocus=yellow,lightgray"
    $mc_color_schema = "gray,black:normal=yellow,black:selected=black,yellow:marked=yellow,brown:markselect=black,magenta:errors=white,red:menu=yellow,gray:reverse=brightmagenta,black:dnormal=black,lightgray:dfocus=black,cyan:dhotnormal=blue,lightgray:dhotfocus=blue,cyan:viewunderline=black,green:menuhot=red,gray:menusel=white,black:menuhotsel=yellow,black:helpnormal=black,lightgray:helpitalic=red,lightgray:helpbold=blue,lightgray:helplink=black,cyan:helpslink=yellow,blue:gauge=white,black:input=yellow,gray:directory=brightred,gray:executable=brightgreen,gray:link=brightcyan,gray:stalelink=brightred,blue:device=white,gray:core=red,blue:special=black,blue:editnormal=white,black:editbold=yellow,blue:editmarked=black,white:errdhotnormal=yellow,red:errdhotfocus=yellow,lightgray"

    ini_setting { 'mc change colorschema':
      ensure  => present,
      path    => "/root/.mc/ini",
      section => 'Colors',
      setting => 'base_color',
      value   => $mc_color_schema,
      require => [ Package["mc"], File["/root/.mc"], ],
    }

    #time & timezone
    #
    class { 'timezone':
        timezone => 'Europe/Prague',
    }

    #mysql client
    package { 'mariadb':
      ensure => 'installed',
      #require => Ini_setting['ius-archive exclude'],
    }

#    package { 'unzip':
#      ensure => 'installed',
#    }

   # users and sudo
#   file {'sudoers-app-admin-as-apache':
#      name => "/etc/sudoers.d/app-admin-as-apache",
#      content => "app-admin    ALL=(apache) NOPASSWD: /bin/bash",
#   }

   user { 'apache':
     ensure     => present,
     home       => '/var/www',
     shell      => '/bin/bash',
     purge_ssh_keys => true,
   }

   file { "/var/www/.ssh":
     ensure  => directory,
     mode    => '0700',
     owner   => 'apache',
     group   => 'apache',
     require => User['apache'],
   }

   file { "/var/www/html":
     ensure  => directory,
     mode    => '0755',
     owner   => 'apache',
     group   => 'apache',
     require => User['apache'],
   }

   file { "/var/www":
     ensure  => directory,
     mode    => '0755',
     owner   => 'apache',
     group   => 'apache',
     require => User['apache'],
   }

   file { "/var/log/httpd":
     ensure  => directory,
     mode    => '0755',
     owner   => 'root',
     group   => 'root',
     require => User['apache'],
   }
