Test ISIS simulator for NetRecon
====

* Intitialize VMS.

> Initial configuration will provision interfaces and tunnels

`vagrant up`

* Stop an instance

`vagrant halt dc1`

* Start an instance of dc1

`vagrant up dc1`

* Reprovision dc1

`vagrant provision dc1`



The quagga service is not started by default.. To start all quagga instances you can execute:

./start.sh


Configuring the NetRecon Agent.
----

The agent can live on another VM and particpate as long as it has an interface bound to "192.168.200.0/24. This is the interface that will recieve all of the frames that the VNF is peering with.


Network Diagram
----

Quagga is bound to a GRETAP tunnel interface one for each dc i.e. Tunnel1->DC1, Tunnel2->DC2. These tunnel interfaces are enslaved to an internal bridge called br1. Packets entering the bridge are mirrored over to the agent via Traffic Control.



    +-------------------+                     +-------+
    |                   +----------+  +-------+       |
    |  +-------------+  |          |  |       |  dc1  |
    |  |             |  |       xxx+xx+x      |       |
    |  |  Quagga     |  |      xx      xxx    +-------+
    |  |             |  |      x         xxx
    |  +-------------+  |      x 192.168.100
    |  +-------------+  |      xx          x  +-------+
    |  |             |  |       xxxxxxxxxxxx  |       |
    |  |    br1      |  |             +-------+  dc2  |
    |  +-------------+  |                     |       |
    +---------+---------+                     +-------+
              |
         xxxxx+xxxxxx
        xx          xxxxxx
        xx 192.168.200   xx
         xxx              x
           xxx        xxxxx
               xx+xxxx
                 |          +--------------+
                 |          |              |
                 |          |              |
                 +----------+    Agent     |
                            |              |
                            |              |
                            +--------------+