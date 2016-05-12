### IOpenStack is a Objective-C iOS framework (including watchOS and tvOS) for OpenStack
 
This is the provider drivers directory where you can find instruction on how to use and/or test the framework against the following OpenStack public clouds :

+ INTERNAP - [AgileCLOUD](http://www.internap.com/cloud/public-cloud/?ref=mnav) and [AgileSERVER](http://www.internap.com/bare-metal/?ref=mnav), currently supported : ![Progress](http://progressed.io/bar/100)  
+ DreamHost - [DreamCompute](https://www.dreamhost.com/cloud/computing/) and [DreamObjects](https://www.dreamhost.com/cloud/storage/), currently supported : ![Progress](http://progressed.io/bar/100)  
+ OVH - [OVH Public cloud](https://www.ovh.com/us/cloud/instances/) and [OVH Public cloud storage](https://www.ovh.com/us/cloud/storage/), currently supported : ![Progress](http://progressed.io/bar/0)  

> **NOTE:** Those instruction are for framework developer. If you want to know how to *use* the framework inside your application, please refer to the [main README](/README.md)

Setup for launching the tests
-------------------
* Make sure you have copied and rename the configuration file 'DefaultSettingsTests.plist' to 'SettingsTests.plist' in the /test directory
* Follow the steps specific to you're public cloud provider


INTERNAP step by step
-------------------

> **WARNING:** By activating and running the tests, you will incur **resource consumption** on your account that will be invoiced to **your** account. 
Make sure to have sufficient credit or active payment options before trying this.


> **Note:** if you already know your API credentials and tenant ID, you can skip steps 1 to 5


1. Log in your [Internap account](http://login.internap.com)
2. In the header menu, select 'Cloud Management' 
![INTERNAP - CloudManagement Menu](/design/step-by-step/INTERNAP-CloudManagement1.png)
    
3. In the Cloud Management page, click the 'Get New API User' button 
![INTERNAP - CloudManagement Menu](/design/step-by-step/INTERNAP-CloudManagement3.png)
    
4. Read and accept the disclaimers, and note down / save the API credentials displayed 
![INTERNAP - CloudManagement Menu](/design/step-by-step/INTERNAP-CloudManagement2.png)
    * red box 1 : will be your INAP_ACCOUNT_LOGIN
    * red box 2 : will be your INAP_ACCOUNT_PASSWORD
>**INFO** : if you loose those credentials, you can re-generate new ones by using this same button

5. Back in the Cloud Management page, note down / save your Tenant ID
![INTERNAP - CloudManagement Menu](/design/step-by-step/INTERNAP-CloudManagement2.png)
    * red box 3 : will be your INAP_ACCOUNT_PROJECTORTENANT
    
6. Finally, still in the same Cloud Management page, scroll down to the list of region to activate the one your want to spin instances/resource in, wait until the activation is finished, and make sure that it is displayed as 'ACTIVE'
![INTERNAP - CloudManagement Menu](/design/step-by-step/INTERNAP-CloudManagement4.png)
    * In this example, we have the New Jersey region (*nyj01*) activated 
    
7. Now, launch XCode, open the IOpenStack.xcodeproj project and insert those values directly inside the DefaultSettings.plist file in the /test directory

8. Finally, still in XCode, in the test folder, enable the following file for the IOpenStacl iOSTests Target Membership :
    * IOStackAuth_INAPTests.m
    * IOStackImage_INAPTests.m
    * IOStackBStorage_INAPTests.m
    * IOStackOStorage_INAPTests.m
    * IOStackCompute_INAPTests.m
 


Dreamhost step by step
-------------------
 COMMING SOON


Contributing
============
 
 Feel free to raise issues and send some pull request, we'll be happy to look at them!