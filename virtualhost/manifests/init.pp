 class virtualhost {
        package { 'apache2':
                ensure => 'installed',
                allowcdrom => 'true',
        }
        file { '/etc/apache2/sites-available/kokeilu.conf':
                content => template('virtualhost/kokeilu.conf.erb'),
                notify => Service['apache2'],
        }
        file { '/etc/hosts':
                content => template('virtualhost/hosts.erb'),
                notify => Service['apache2'],
        }
        file { '/home/xubuntu/public_html':
                ensure => 'directory',
        }
    }
