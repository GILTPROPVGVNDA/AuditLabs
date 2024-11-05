# Vagrantfile for Pentesting Lab
Vagrant.configure("2") do |config|
    # Kali Linux (Scanner)
    config.vm.define "kali_scanner" do |kali|
      kali.vm.box = "kalilinux/rolling" 
      kali.vm.hostname = "kali-scanner"
      kali.vm.network "private_network", ip: "10.0.2.15"
      kali.vm.provider "virtualbox" do |vb|
        vb.gui = true
        vb.memory = "4096" # Adjust memory as needed
      end
  
      kali.vm.provision "shell", inline: <<-SHELL
        apt-get update
        apt-get install -y openvas
        gvm-setup
        gvm-start
        git clone https://github.com/GILTPROPVGVNDA/AuditLabs.git
      SHELL
    end
  
    # Kali Linux (Victim)
    config.vm.define "kali_victim" do |victim|
      victim.vm.box = "kalilinux/rolling"
      victim.vm.hostname = "kali-victim"
      victim.vm.network "private_network", ip: "10.0.2.14"
      victim.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
      end
      victim.vm.provision "shell", inline: <<-SHELL
        apt-get update
        apt-get install -y apache2 vsftpd
      SHELL
    end
  
    # Windows 10 Machine (assuming Windows Vagrant box is available)
    config.vm.define "windows10" do |win|
      win.vm.box = "gusztavvargadr/windows-10" # Example Windows 10 Vagrant box
      config.vm.box_version = "2202.0.2409"
      win.vm.hostname = "windows10"
      win.vm.network "private_network", ip: "10.0.2.16"
      win.vm.provider "virtualbox" do |vb|
        vb.memory = "4096"
        vb.gui = true
      end
    end
  
    # Metasploitable 2
    config.vm.define "metasploitable2" do |meta|
      meta.vm.box = "rapid7/metasploitable2"
      meta.vm.hostname = "metasploitable2"
      meta.vm.network "private_network", ip: "10.0.2.13"
      meta.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
      end
    end
  
  end
  