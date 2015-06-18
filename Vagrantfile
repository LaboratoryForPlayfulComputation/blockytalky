# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "hashicorp/precise64"
  config.berkshelf.enabled = true
  #config.berkshelf.berksfile_path = Pathname(__FILE__).dirname.join('.', 'Berksfile')
  config.vm.provision "chef_solo" do |chef|
    chef.add_recipe "elixir"
    chef.add_recipe "nodejs"
    chef.add_recipe "git"
    chef.add_recipe "python"
    #chef.add_recipe "avahi"
    #chef.add_recipe "samba"
  end

  #Fix LATIN1 -> UTF-8
  config.vm.provision :shell, :inline => <<-EOT
       echo 'LC_ALL="en_US.UTF-8"'  >  /etc/default/locale
  EOT
  config.vm.provision :shell, path: "non_chefable_scripts.sh"
  config.vm.provider "virtualbox" do |v|
    v.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/vagrant", "1"]
  end

  #blockytalky default port forwarding
  config.vm.network "forwarded_port", guest: 4000, host: 8080
  # config.vm.network "forwarded_port", guest: 4369, host: 8282
  config.vm.network "private_network", type: "dhcp"
  # Require the Trigger plugin for Vagrant
unless Vagrant.has_plugin?('vagrant-triggers')
  # Attempt to install ourself.
  # Bail out on failure so we don't get stuck in an infinite loop.
  system('vagrant plugin install vagrant-triggers') || exit!

  # Relaunch Vagrant so the new plugin(s) are detected.
  # Exit with the same status code.
  exit system('vagrant', *ARGV)
end

# Workaround for https://github.com/mitchellh/vagrant/issues/5199
config.trigger.before [:reload, :up, :provision], stdout: true do
  MY_PROVIDER = "virtualbox"
  SYNCED_FOLDER = ".vagrant/machines/default/#{MY_PROVIDER}/synced_folders"
  info "Trying to delete folder #{SYNCED_FOLDER}"
  begin
    File.delete(SYNCED_FOLDER)
  rescue StandardError => e
    warn "Could not delete folder #{SYNCED_FOLDER}."
    warn e.inspect
  end
end

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false


  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  #config.vm.network "private_network", ip: "192.168.33.10"

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
  #   sudo apt-get update
  #   sudo apt-get install -y apache2
  # SHELL
end
