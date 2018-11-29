# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end

  config.vm.box = "hashicorp/precise64"
  config.vm.network "private_network", ip: "192.168.66.6"  
  config.vm.hostname = "widgetbox-php53"
  config.vm.provision "shell", path: "provision.sh"
  config.vm.synced_folder ".", "/var/www", :mount_options => ["dmode=777", "fmode=666"]
  config.ssh.insert_key = false

end
