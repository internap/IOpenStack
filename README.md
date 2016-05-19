### IOpenStack is a Objective-C iOS framework (including watchOS and tvOS) for OpenStack

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)


It currently support most of the Core Services (Keystone, Glance, Nova, Swift, Cinder). Neutron to come.

+ ![Progress](http://progressed.io/bar/90)   [Identity / Authentication - Keystone](/src/Auth)   
+ ![Progress](http://progressed.io/bar/60)   [Images - Glance](/src/Image)   
+ ![Progress](http://progressed.io/bar/90)   [Block Storage - Cinder](/src/BlockStorage)  
+ ![Progress](http://progressed.io/bar/60)   [Object Storage - Swift](/src/ObjectStorage) 
+ ![Progress](http://progressed.io/bar/30)   [Compute - Nova](/src/Compute)  
+ ![Progress](http://progressed.io/bar/0)   [Network - Neutron](/src/Network) 

You can see the support details by clicking the service name.


How to test/develop
-------------------
> **Note:** If you have a Dreamhost or Internap public cloud API access, you can test the framework integration, see this [guide](/src/Auth/Provider).

The easiest way to try the framework is to start a fresh devstack instance in a virtual machine locally (or a container if you're feeling brave).
* Boot up your VM machine with a Linux OS and sufficient RAM (we recommand more than 3 Go)
* Clone the devstack github repo :
```bash
git clone https://github.com/openstack-dev/devstack
```
* Create/edit your local.conf to activate all the services you want to test (here is an example we use)
```text
[[local|localrc]]
ADMIN_PASSWORD=password
RABBIT_PASSWORD=password
SERVICE_PASSWORD=password
SERVICE_TOKEN=tokentoken
DATABASE_PASSWORD=password
ADMIN_PASSWORD=password
SWIFT_PASSWORD=password
SWIFT_HASH=66a3d1b21c1f479c8b4e70ab5c2000f5
FLOATING_RANGE=192.168.15.0/27
FLAT_INTERFACE=eth1
#HOST_IP=10.0.0.4
Q_FLOATING_ALLOCATION_POOL=start=192.168.15.10,end=192.168.15.20
PUBLIC_NETWORK_GATEWAY=192.168.15.1

IP_VERSION=4+6

disable_service n-net
enable_service q-svc
enable_service q-agt
enable_service q-dhcp
enable_service q-l3
enable_service q-meta
enable_service neutron
enable_service n-novnc
enable_service s-proxy 
enable_service s-object 
enable_service s-container 
enable_service s-account
enable_service c-bak
enable_service heat 
enable_service h-api 
enable_service h-api-cfn 
enable_service h-api-cw 
enable_service h-eng

# fin :)
# Optional, to enable tempest configuration as part of devstack

#OFFLINE=True
VERBOSE=True
LOG_COLOR=True
LOGFILE=/opt/stack/logs/stack.sh.log
SCREEN_LOGDIR=/opt/stack/logs
PIP_UPGRADE=True
RECLONE=yes
```
* Launch your stack
```bash
cd ~/devstack
./stack.sh
```
* Once it's done, you can launch XCode and open the IOpenStack.xcodeproj project
* Make sure you have copied and rename the configuration file 'DefaultSettingsTests.plist' to 'SettingsTests.plist' in the /test directory
* Inside the 'SettingsTests.pList', edit all the DEVSTACK_*_ROOT value with the IP/URL of your devstack instance service
* Launch the test suite


How to use
----------
COMMING SOON
```objective-c


```


Contributing
============

Feel free to raise issues and send some pull request, we'll be happy to look at them!