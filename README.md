Vagrant LAMP
============

A Vagrant LAMP that uses PHP 5.3.10

Requirements
------------
* VirtualBox <http://www.virtualbox.org>
* Vagrant <http://www.vagrantup.com>
* Git <http://git-scm.com/>

Usage
-----

### Startup

1. Download one of the releases available [https://github.com/bmckinney/widgetbox-php53/releases](https://github.com/bmckinney/widgetbox-php53/releases)
2. Extract the ZIP file.
3. From the command-line:
```
$ cd vagrant-lamp-release
$ vagrant up
```
### Connecting

#### Apache
The Apache server is available at <http://192.168.66.6/>

#### MySQL
The MySQL server is available at port 306 as usual.
Username: root
Password: root

Technical Details
-----------------
* Ubuntu 12.04 64-bit
* Apache 2.2.33
* PHP 5.3.10
* MySQL 5.5
* XDebug
* PHPUnit 4.8
* Composer

We are using the base Ubuntu 14.04 box from Vagrant (precise64). If you don't already have it downloaded
the Vagrantfile has been configured to do it for you. This only has to be done once
for each account on your host computer.

The web root is the project directory and you can install your files there.

And like any other vagrant file you have SSH access with
```
$ vagrant ssh
```

