## Harjoitus 3

# Virtualhost

Teen tehtävän Helia-talon tietokonelaboratoriossa h5004. Koneena oli HP Compaq 8200 työasema, monitorin jalassa oli numero 18.
Tehtävän ohjeistus löytyi opettajan kotisivuilta: http://terokarvinen.com/2017/aikataulu-%e2%80%93-palvelinten-hallinta-ict4tn022-2-%e2%80%93-5-op-uusi-ops-loppukevat-2017-p2

h3. a) Package-File-Server. Asenna ja konfiguroi jokin demoni package-file-server -tyyliin. Tee jokin muu asetus kuin tunnilla näytetty sshd:n portin vaihto.

b) Modulit Gitistä. Tee skripti, jolla saat nopeasti modulisi kloonattua GitHubista ja ajettua vaikkapa liverompulle. Voit katsoa mallia terokarvinen/nukke GitHub-varastosta.

Päätin tehdä kaverin tapaan Apachen asennuksen ja modulin, joka vaihtaa virtualhostin xubuntun kotihakemistoon

#Vhn testaus

Aloitin tehtävän vaihtamalla näppäimistökielen komennolla
	$ setxkbmap fi 

ja ajamalla päivitykset Linux versiooni komenolla
	$ sudo apt-get -y update.

Tähän perään asennetaan Apache ja testataan virtualhostin toiminta ilman puppettia:

	$ sudo apt-get install apache2

Loin sitten tiedoston kokeilu.conf apachen sites-available kansioon:
	$ sudoedit /etc/apache2/sites-available/oliot.conf

	<VirtualHost *:80>
  		DocumentRoot /home/xubuntu/public_html/

  		<Directory /home/xubuntu/public_html/>
     			Require all granted
  		</Directory>
	</VirtualHost>

Seruaavilla komennoilla otin luodun tiedoston käyttöön ja poistin oletus 000-default.conf:
	$ sudo a2ensite kokeilu.conf  
	$ sudo a2dissite 000-default.conf

Molemmat komennot pyytävät apachen uudelleen käynnistystä saadakseen muutokset voimaan joten tehdään tämä:
	$ sudo service apache2 restart 

Tein kansion public_html kotihakemistooni, johon tiedoston index.html. Tiedostoon kirjoitin vain tekstin HTML MOI.
	$ mkdir public_html
 	$ cd public_html/
	$ nano index.html

Tein muutokset hosts tiedostoon lisäten oikeat sivut:
	$ sudoedit /etc/hosts
 127.0.0.1 kokei.lu
 127.0.1.1 www.kokei.lu

#Puppet modulin luonti

Tietenkin aluksin asennetaan koneelle Puppet:
	$ sudo apt-get -y install puppet

Perinteisen kaavan mukaan siirryin modules kansioon, minne loin manifests ja templates -kansiot uuden virtualhost kansion alle.
	$ cd /etc/puppet/modules
	$ sudo mkdir virtualhost
	cd virtualhost/
	$ sudo mkdir manifests
	$ sudo mkdir templates

Siirryin templates kansioon ja kopioin sinne /etc/apache2/sites-available/kokeilu.conf tiedostoni johon muutin päätteeksi erb. 
	$ sudo cp /etc/apache2/sites-available/kokeilu.conf kokeilu.conf.erb

Saman tein myös hosts tiedostolle:
	$ sudo cp /etc/hosts hosts.erb

Tein templates kansioon tiedoston index.html.erb, joka toimii mallina käyttäjän kotisivulle. Itse tiedoston mallina käytin W3schoolin etusivua.
	$ sudoedit index.html.erb



Kirjoitin opettajan mallin mukaan tiedostot start.sh ja apply.sh kansioon /home/xubuntu/virtualhost
	#start.sh
	setxkbmap fi
	sudo apt-get update
	sudo apt-get -y install puppet git
	git clone https://github.com/AAHyv/har3.git
	cd har3
	bash apply.sh
	#apply.sh
	sudo puppet apply --modulepath puppet/modules/ -e 'class {hellotero:}'

Seuraavaksi tein kansioon manifests tiedoston inip.pp:

	 class virtualhost {
        	package { 'apache2':
                	ensure => 'installed',
                	allowcdrom => 'true',
        	}
        	file { '/etc/apache2/sites-available/oliot.conf':
                	content => template('virtualhost/oliot.conf.erb'),
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

