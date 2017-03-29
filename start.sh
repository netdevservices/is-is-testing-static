for i in `cat Vagrantfile|grep config.vm.define | awk {'print $2'} | grep -v "agent" | sed 's/\"//g' `
do
	echo  "Starting Quagga service on host $i"
	vagrant ssh $i -- sudo /etc/init.d/quagga restart
done