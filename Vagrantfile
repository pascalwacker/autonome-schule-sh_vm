# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    config.vm.box = "ubuntu/xenial64"

    # Do some network configuration
    config.vm.network "private_network", ip: "192.168.100.100"
    #config.vm.network "private_network", type: "dhcp"
    config.vm.network "forwarded_port", guest: 80, host: 80

    # Mount shared folder using NFS
    config.vm.synced_folder ".", "/vagrant", type: "nfs",
        mount_options: ['rw', 'vers=3', 'tcp'],
        linux__nfs_options: ['rw','no_subtree_check','all_squash','async']

#    config.vm.synced_folder "./source/app", "/var/www/app", type: "nfs",
#        mount_options: ['rw', 'vers=3', 'tcp'],
#        linux__nfs_options: ['rw','no_subtree_check','all_squash','async']

    # Assign a quarter of host memory and all available CPU's to VM
    # Depending on host OS this has to be done differently.
    config.vm.provider :virtualbox do |vb|
        host = RbConfig::CONFIG['host_os']

        if host =~ /darwin/
            cpus = `sysctl -n hw.ncpu`.to_i
            mem = `sysctl -n hw.memsize`.to_i / 1024 / 1024 / 4

        elsif host =~ /linux/
            cpus = `nproc`.to_i
            mem = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024 / 4

        # Windows...
        else
            cpus = 4
            mem = 2048
        end

        vb.customize ["modifyvm", :id, "--memory", mem]
        vb.customize ["modifyvm", :id, "--cpus", cpus]

        vb.memory = mem
        vb.cpus = cpus
    end

    config.vm.provision :shell, :path => "bootstrap.sh"
#    config.vm.provision "shell", inline: "sudo service mysql start", run: "always"
    config.vm.provision "shell", inline: "sudo service apache2 start", run: "always"
#    config.vm.provision "shell", inline: "sudo service mailhog start", run: "always"
    config.vm.provision "shell", inline: "mysql -uroot -p123 < /vagrant/mysql-5.7.sql", run: "always"

end
