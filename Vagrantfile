# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  ##################################
  # Section - 01 : Ansible configs #
  config.vm.define :webapp do |webapp_config|
    webapp_config.vm.box = "bento/centos-7.2"
    webapp_config.vm.hostname = "webapp"
    webapp_config.vm.network "private_network", ip: "192.168.77.20"
    webapp_config.vm.provider "virtualbox" do |vb|
      vb.memory = "256"
    end
  end
  # Section - 01 : END #
  ######################

  #####################################
  # Section - 04 : Load Balancer Demo #
#  config.vm.define :loadb do |loadb_config|
#    loadb_config.vm.box = "bento/centos-7.2"
#    loadb_config.vm.hostname = "loadb"
#    loadb_config.vm.network "private_network", ip: "192.168.77.20"
#    loadb_config.vm.network "forwarded_port", guest: 80, host: 8080
#    loadb_config.vm.provider "virtualbox" do |vb|
#      vb.memory = "256"
#    end
#  end
  
#  (1..3).each do |i|
#    config.vm.define "webapp#{i}" do |webapp_config|
#      webapp_config.vm.box = "bento/centos-7.2"
#      webapp_config.vm.hostname = "webapp#{i}"
#      webapp_config.vm.network "private_network", ip: "192.168.77.2#{i}"
#      webapp_config.vm.network "forwarded_port", guest: 80, host: "808#{i}"
#      webapp_config.vm.provider "virtualbox" do |vb|
#        vb.memory = "256"
#      end
#    end
#  end
  # Section - 04 : END #
  ######################


end

