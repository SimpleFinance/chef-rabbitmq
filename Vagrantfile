#!/usr/bin/env ruby

Vagrant.configure('2') do |config|
  config.vm.define :rabbitmq do |rabbitmq|
    rabbitmq.vm.hostname = 'rabbitmq'
    rabbitmq.vm.box = ENV['VAGRANT_BOX'] || 'opscode_ubuntu-12.04_chef-provisionerless'
    rabbitmq.vm.box_url = ENV['VAGRANT_BOX_URL'] || "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/#{rabbitmq.vm.box}.box"

    rabbitmq.vm.network :forwarded_port, guest: 5672,  host: 5672
    rabbitmq.vm.network :forwarded_port, guest: 15672, host: 15672
    rabbitmq.omnibus.chef_version = ENV['CHEF_VERSION'] || :latest

    rabbitmq.vm.provision :shell do |shell|
      shell.inline = 'test -f $1 || (sudo apt-get update -y && touch $1)'
      shell.args = '/var/run/apt-get-update'
    end

    rabbitmq.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = './cookbooks'
      chef.run_list = [
        'recipe[rabbitmq::default]'
      ]
    end
  end
end
