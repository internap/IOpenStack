 [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

IOpenStack is a Objective-C iOS framework (including watchOS and tvOS) for OpenStack.

It currently support most of the Core Services (Keystone, Glance, Nova, Swift, Cinder). Neutron to come.

+ Identity / Authentication - [Keystone](/src/Auth/README.md) ![Progress](http://progressed.io/bar/70)  
+ Images - [Glance](/src/Image/README.md) ![Progress](http://progressed.io/bar/100)  
+ Compute - [Nova](/src/Compute/README.md) ![Progress](http://progressed.io/bar/40)  
+ Object Storage - [Swift](/src/ObjectStorage/README.md) ![Progress](http://progressed.io/bar/80)  
+ Block Storage - [Cinder](/src/BlockStorage/README.md) ![Progress](http://progressed.io/bar/90)  
+ Network - [Neutron](/src/Network/README.md) ![Progress](http://progressed.io/bar/0)

You can see the support details by clicking the service name.


How to test/develop
-------------------
The most easy way to try the framework is to start a fresh devstack instance in a virtual machine locally.
From there, you will have to rename the configuration file 'DefaultSettingsTests.plist' to 'SettingsTests.plist'. 
If you have a Dreamhost or Internap public cloud API access, you can modify this file accordingly to your credential. See this guide 

How to use
----------
COMMING SOON
```objective-c


```


Contributing
============

Feel free to raise issues and send some pull request, we'll be happy to look at them!