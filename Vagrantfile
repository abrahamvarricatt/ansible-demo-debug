# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  # Create central management system
  config.vm.define :webapp do |webapp_config|
    webapp_config.vm.box = "bento/centos-7.2"
    webapp_config.vm.hostname = "webapp"
    webapp_config.vm.network "private_network", ip: "192.168.77.10"
    webapp_config.vm.provider "virtualbox" do |vb|
      vb.memory = "512"
    end
  end

end

