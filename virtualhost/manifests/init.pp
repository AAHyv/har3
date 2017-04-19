class virtualhost {
        package { 'apache2':
                ensure => 'installed',
                allowcdrom => 'true',
        }
        file { '/etc/apache2/sites-available/kokeilu.conf':
                content => template('virtualhost/kokeilu.conf.erb'),
                require => Service['apache2'],
        }
        file { '/etc/hosts':
                content => template('virtualhost/hosts.erb'),
                require => Service['apache2'],
        }
        file { '/home/xubuntu/public_html':
                ensure => 'directory',
        }
        file { '/home/xubuntu/public_html/index.html':
                content => template('virtualhost/index.html.erb'),
                require => File['/home/xubuntu/public_html'],
        }
        service { 'apache2':
                ensure => 'true',
                enable => 'true',
                provider => 'systemd',
        }
        exec { 'a2ensite':
                command => 'sudo a2ensite oliot.conf',
                path => '/bin:/usr/bin:/sbin:/usr/sbin:',
                require => File['/etc/apache2/sites-available/kokeilu.conf'],
        }
        exec { 'a2dissite':
                command => 'sudo a2dissite 000-default.conf',
                path => '/bin:/usr/bin:/sbin:/usr/sbin:',
                notify => Service['apache2'],
        }
    }
