# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!

ZEBRA="/usr/local/sbin/zebra"

update_agent = <<EOS
if ! [ -e "/usr/share/bcc/tools" ]
    then
        set -e
        echo "deb [trusted=yes] https://repo.iovisor.org/apt/xenial xenial-nightly main" | sudo tee /etc/apt/sources.list.d/iovisor.list
        apt -y update
        sudo apt-get -y install --force-yes build-essential git python tree bcc-tools python-pip
        pip install --upgrade pip
        apt-get -y install linux-headers-`uname -r`
        apt-get -y install --reinstall linux-image-`uname -r`
        pip install docopt
        pip install pyroute2
fi
EOS

update_packages = <<EOS
if ! [ -e "/usr/local/sbin/zebra" ]
    then
        set -e
        apt -y update
        apt install -y --force-yes libreadline-dev pkg-config libc-ares-dev
        wget http://download.savannah.gnu.org/releases/quagga/quagga-1.2.1.tar.gz
        tar zxf quagga-1.2.1.tar.gz && cd quagga-1.2.1
        useradd quagga -m
        ./configure  --disable-bgpd  --disable-ripd  --disable-ripngd  --disable-ospfd  --disable-ospf6d  --disable-nhrpd  --disable-pimd \
        --disable-bgp-announce  --disable-ospfapi  --disable-ospfclient
        make
        make install
        sudo mv /home/ubuntu/daemons /usr/local/etc/daemons
        sudo mv /home/ubuntu/debian.conf /usr/local/etc/debian.conf
        sudo mv /home/ubuntu/quagga /etc/init.d/
        sudo chown root:root /etc/init.d/quagga
        mkdir /var/log/quagga
        sudo chown quagga:quagga /var/log/quagga
        sudo chmod 755 /etc/init.d/quagga
fi
EOS

configure_quagga = <<EOS
sudo mv /home/ubuntu/isisd.conf /usr/local/etc/isisd.conf
sudo mv /home/ubuntu/zebra.conf /usr/local/etc/zebra.conf
EOS

setup_vnf_bridge = <<EOS
ip link add dev br1 type bridge || true
ip link set br1 up || true
ip link set enp0s9 master br1 || true

tc qdisc del dev br1 root || true
tc qdisc add dev br1 handle 1: root prio || true
tc filter add dev br1 parent 1: protocol 802_3 u32 match ether src 01:80:c2:00:00:14 action mirred egress mirror dev enp0s9 || true
tc qdisc del dev br1 ingress || true
tc qdisc add dev br1 ingress || true
tc filter add dev br1 parent ffff: protocol all u32 match ether src 01:80:c2:00:00:14 action mirred egress mirror dev enp0s9 || true
EOS

setup_gre_1_2 = <<EOS
sudo ip link add tunnel1 type gretap local 192.168.100.200 remote 192.168.100.201
sudo ip link set tunnel1 master br1
sudo ip link set tunnel1 up
EOS

setup_gre_1_3 = <<EOS
sudo ip link add tunnel2 type gretap local 192.168.100.200 remote 192.168.100.202
sudo ip link set tunnel2 master br1
sudo ip link set tunnel2 up
EOS

setup_gre_2_1 = <<EOS
sudo ip link add tunnel1 type gretap local 192.168.100.201 remote 192.168.100.200
sudo ip link set tunnel1 up
EOS


setup_gre_3_1 = <<EOS
sudo ip link add tunnel1 type gretap local 192.168.100.202 remote 192.168.100.200
sudo ip link set tunnel1 up
EOS


reboot = <<EOS
sudo init 6
EOS

start_quagga = <<EOS
set -x 
sudo /etc/init.d/quagga stop || true
sudo /etc/init.d/quagga start
EOS

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.define "vnf" do |vnf|
    vnf.vm.box = "ubuntu/xenial64"
    vnf.vm.hostname = "vnf"
    vnf.vm.network "private_network", ip: "192.168.100.200"
    vnf.vm.network "private_network", ip: "192.168.200.200"
    vnf.vm.provider "virtualbox" do |vb|
      vb.name = "vnf"
      vb.memory = 1440
    end
    vnf.vm.provision "file", source: "./quagga/quagga-1.2.1.tar.gz", destination: "~/quagga-1.2.1.tar.gz"
    vnf.vm.provision "file", source: "./quagga/quagga", destination: "~/quagga"
    vnf.vm.provision "file", source: "./quagga/daemons", destination: "~/daemons"
    vnf.vm.provision "file", source: "./quagga/debian.conf", destination: "~/debian.conf"
    vnf.vm.provision "file", source: "./quagga/vnf/isisd.conf", destination: "~/isisd.conf"
    vnf.vm.provision "file", source: "./quagga/vnf/zebra.conf", destination: "~/zebra.conf"
    vnf.vm.provision :shell, :inline => update_packages
    vnf.vm.provision :shell, :inline => setup_vnf_bridge
    vnf.vm.provision :shell, :inline => setup_gre_1_2
    vnf.vm.provision :shell, :inline => setup_gre_1_3
    vnf.vm.provision :shell, :inline => configure_quagga
  end

  config.vm.define "dc1" do |dc1|
    dc1.vm.box = "ubuntu/xenial64"
    dc1.vm.hostname = "dc1"
    dc1.vm.network "private_network", ip: "192.168.100.201"
    dc1.vm.provider "virtualbox" do |vb|
      vb.name = "dc1"
      vb.memory = 1440
    end
    dc1.vm.provision "file", source: "./quagga/quagga-1.2.1.tar.gz", destination: "~/quagga-1.2.1.tar.gz"
    dc1.vm.provision "file", source: "./quagga/quagga", destination: "~/quagga"
    dc1.vm.provision "file", source: "./quagga/daemons", destination: "~/daemons"
    dc1.vm.provision "file", source: "./quagga/debian.conf", destination: "~/debian.conf"
    dc1.vm.provision "file", source: "./quagga/dc1/isisd.conf", destination: "~/isisd.conf"
    dc1.vm.provision "file", source: "./quagga/dc1/zebra.conf", destination: "~/zebra.conf"
    dc1.vm.provision :shell, :inline => update_packages
    dc1.vm.provision :shell, :inline => setup_gre_2_1
    dc1.vm.provision :shell, :inline => configure_quagga

  
  end  

  config.vm.define "dc2" do |dc2|
    dc2.vm.box = "ubuntu/xenial64"
    dc2.vm.hostname = "dc2"
    dc2.vm.network "private_network", ip: "192.168.100.202"
    dc2.vm.provider "virtualbox" do |vb|
      vb.name = "dc2"
      vb.memory = 1440
    end
    dc2.vm.provision "file", source: "./quagga/quagga-1.2.1.tar.gz", destination: "~/quagga-1.2.1.tar.gz"
    dc2.vm.provision "file", source: "./quagga/quagga", destination: "~/quagga"
    dc2.vm.provision "file", source: "./quagga/daemons", destination: "~/daemons"
    dc2.vm.provision "file", source: "./quagga/debian.conf", destination: "~/debian.conf"
    dc2.vm.provision "file", source: "./quagga/dc2/isisd.conf", destination: "~/isisd.conf"
    dc2.vm.provision "file", source: "./quagga/dc2/zebra.conf", destination: "~/zebra.conf"
    dc2.vm.provision :shell, :inline => update_packages
    dc2.vm.provision :shell, :inline => setup_gre_3_1
    dc2.vm.provision :shell, :inline => configure_quagga


  end


    config.vm.define "agent" do |agent|
    agent.vm.box = "ubuntu/zesty64"
    agent.vm.hostname = "agent"
    agent.vm.network "private_network", ip: "192.168.200.201"
    agent.vm.provider "virtualbox" do |vb|
      vb.name = "agent"
      vb.memory = 1440
    end
    agent.vm.provision :shell, :inline => update_agent
  end

end