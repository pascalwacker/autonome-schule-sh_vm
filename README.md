# Vagrant VM for A.S.S. project  
  
## Dependencies:  
- Vagrant (https://www.vagrantup.com/)  
- VirtualBox (https://www.virtualbox.org/)  
- NFS Server  
- Linux (tested) or Mac (untested)  
(On Windows the syncing can be changed to `SMB` sharing or default Virtualbox sharing, note that the default sharing mode of Virtualbox is slow!)
  
## What does it do?
Provisions a Ubuntu 16.04 VM with all dependencies of Symfony and loads `db-dump.sql` in the db on provision  

## Vagrant commands
`vagrant up` start vm (creates a new vm if none is created)  
`vagrant halt` stop vm  
`vagrant destroy` destroy vm  
`vagrant ssh` open ssh session to the VM  
  
## Provision/First Run
The VM will bind to `192.168.100.100`, you can change this in the `Vagrantfile`. Please add the following urls to your `hostfile` (probably located at `/etc/hosts`):  
- app.dev  
- phpmyadmin.dev  
Visit http://app.dev in your browser, you should see a `phpinfo` promt if not, something went wrong.
  
## Install symfony
1) connect to the VM by ssh (`vagrant ssh` command) and navigate to `/var/www/app` (there's a alias, acting as shortcut, just type in `app` and hit enter.  
2) remove the `web` folder containing `index.php` with the command `rm -rf web`  
3) clone the a.s.s. repo with the command `git clone <a.s.s. repo url> .`  
4) update the db and general config files at `app` folder and use `127.0.0.1` as host, `root` as user, `123` as password, `dev` as db scheme  
  
## Done
There's a PHPMyAdmin sitting at http://phpmyadmin.dev, user is `root` and password `123`  
There's a MailHog (intercepting all outgoing messages!) sitting at http://app.dev:8025 with user `root` and password `123`  
There's the craft app sitting at http://app.dev  
  
## Filesharing
The `source/app` folder gets synced to `/var/www/app` as soon as you uncomment it in the `Vagrantfile`
This directory get's synced to `/vagrant` inside the VM too, so you can also use it to move stuff.  
  
## Troubleshooting
- http://app.dev doesn't load after adding it to the hosts file => Flush your DNS cache https://help.dreamhost.com/hc/en-us/articles/214981288-Flushing-your-DNS-cache-in-Mac-OS-X-and-Linux (Linux should do that automatically for you!)
- Port 80 can't be forwarded => Adjust port 80 in the `Vagrantfile` to whatever you want, for example `8080` on the host  
- NFS won't start => Either install the NFS Server package on your computer or fall back to Virtualbox default sharing (which is much slower!)  
  
## Known Issues

