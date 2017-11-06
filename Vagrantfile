# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  # config.vm.box = "ubuntu/xenial64"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL

  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.iso_path = File.expand_path("/Applications/VirtualBox.app/Contents/MacOS/VBoxGuestAdditions.iso", __FILE__)
    config.vbguest.no_remote = true
    config.vbguest.auto_update = false
  end

  servers=[
      {
        :hostname => "pipeline-cp-image",
        :box => "ubuntu/xenial64",
        :ram => 1024,
        :cpu => 2
      }
  ].each do |machine|
    config.vm.define machine[:hostname] do |node|
        node.vm.box = machine[:box]
        node.vm.hostname = machine[:hostname]
        node.vm.network "private_network", type: "dhcp"
        node.vm.provider :virtualbox do |vb|
            vb.customize ["modifyvm", :id, "--memory", machine[:ram]]
            vb.customize ["modifyvm", :id, "--cpus", machine[:cpu]]
            vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
            vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
        end

        node.vm.network "forwarded_port", guest: 8080, host: 8080

        node.vm.provision "shell" do |s|
          s.path = "scripts/bootstrap.sh"
          s.env = JSON.parse(value)
          {
            "AWS_ACCESS_KEY_ID" => ENV['AWS_ACCESS_KEY_ID'],
            "AWS_SECRET_ACCESS_KEY" => ENV['AWS_SECRET_ACCESS_KEY'],
            "AWS_REGION" => ENV['AWS_REGION'],
            "AWS_DEFAULT_REGION" => ENV['AWS_DEFAULT_REGION'] ? ENV['AWS_REGION']: "",
            "KUBERNETES_RELEASE_TAG" => "v1.7.3",
            "ETCD_RELEASE_TAG" => "3.0.17",
            "K8S_DNS_RELEASE_TAG" => "1.14.4",
            "SPARK_RELEASE_TAG" => "v2.1.0-k8s-1.0.49",
            "HELM_RELEASE_TAG" => "v2.6.0"
          }
        end
    end
  end

end
