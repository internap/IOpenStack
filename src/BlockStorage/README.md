IOpenStack is a Objective-C iOS framework (including watchOS and tvOS) for OpenStack.

Progress : ![Progress](http://progressed.io/bar/30)


This part describe the BlockStorage/Volume component of the library :

+ Cinder V2.1
+ + Service versions ![Current Progress](http://progressed.io/bar/0)
+ + Limits ![Current Progress](http://progressed.io/bar/0)
+ + Volumes ![Current Progress](http://progressed.io/bar/0)
+ + Volume type access ![Current Progress](http://progressed.io/bar/0)
+ + Volume actions ![Current Progress](http://progressed.io/bar/0)
+ + Backups ![Current Progress](http://progressed.io/bar/0)
+ + Backup actions ![Current Progress](http://progressed.io/bar/0)
+ + Capabilities for storage back ends ![Current Progress](http://progressed.io/bar/0)
+ + Quota ses extensions ![Current Progress](http://progressed.io/bar/0)
+ + Quality of service (QoS) specifications ![Current Progress](http://progressed.io/bar/0)
+ + Volume types ![Current Progress](http://progressed.io/bar/0)
+ + Volume snapshots ![Current Progress](http://progressed.io/bar/0)
+ + Volume manage extension ![Current Progress](http://progressed.io/bar/0)
+ + Volume image metadata extension ![Current Progress](http://progressed.io/bar/0)
+ + Back-end storage pools ![Current Progress](http://progressed.io/bar/0)
+ + Volume transfer ![Current Progress](http://progressed.io/bar/100)
+ + Consistency groups ![Current Progress](http://progressed.io/bar/0)
+ + Coonsistency group snapshots ![Current Progress](http://progressed.io/bar/0)


If you run the test suite for this on devstack, make sure that you cleanup the volumes after.
----------
```bash
sudo lvdisplay
sudo lvremove THEFULLLVOLUMEPATH

```