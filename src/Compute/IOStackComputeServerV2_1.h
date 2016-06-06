//
//  IOStackServerObjectV2_1.h
//  IOpenStack
//
//  Created by Bruno Morel on 2016-01-25.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import "IOStackObject.h"


#define IOStackObjectTypeServer             @"server"

#define IOStackServerStatusUnknown          @"UNKNOWN"
#define IOStackServerStatusActive           @"ACTIVE" //The server is active.
#define IOStackServerStatusBuild            @"BUILD" //The server has not finished the original build process.
#define IOStackServerStatusDeleted          @"DELETED" //The server is deleted.
#define IOStackServerStatusError            @"ERROR" //The server is in error.
#define IOStackServerStatusHardReboot       @"HARD_REBOOT" //The server is hard rebooting. This is equivalent to pulling the power plug on a physical server, plugging it back in, and rebooting it.
#define IOStackServerStatusPassword         @"PASSWORD" //The password is being reset on the server.
#define IOStackServerStatusReboot           @"REBOOT" //The server is in a soft reboot state. A reboot command was passed to the operating system.
#define IOStackServerStatusRebuild          @"REBUILD" //The server is currently being rebuilt from an image.
#define IOStackServerStatusRescue           @"RESCUE" //The server is in rescue mode.
#define IOStackServerStatusResize           @"RESIZE" //Server is performing the differential copy of data that changed during its initial copy. Server is down for this stage.
#define IOStackServerStatusRevertResize     @"REVERT_RESIZE" //The resize or migration of a server failed for some reason. The destination server is being cleaned up and the original source server is restarting.
#define IOStackServerStatusShutoff          @"SHUTOFF" //The virtual machine (VM) was powered down by the user, but not through the OpenStack Compute API. For example, the user issued a shutdown -h command from within the server instance. If the OpenStack Compute manager detects that the VM was powered down, it transitions the server instance to the SHUTOFF status. If you use the OpenStack Compute API to restart the instance, the instance might be deleted first, depending on the value in the ``shutdown_terminate`` database field on the Instance model.
#define     IOStackServerStatusSuspended        @"SUSPENDED" //The server is suspended, either by request or necessity. This status appears for only the following hypervisors //XenServer/XCP, KVM, and ESXi. Administrative users may suspend an instance if it is infrequently used or to perform system maintenance. When you suspend an instance, its VM state is stored on disk, all memory is written to disk, and the virtual machine is stopped. Suspending an instance is similar to placing a device in hibernation; memory and vCPUs become available to create other instances.
#define     IOStackServerStatusVerifyResize     @"VERIFY_RESIZE"

#define IOStackServerStatusErrorArray       @[ IOStackServerStatusUnknown, IOStackServerStatusError ]


@interface IOStackComputeServerV2_1 : IOStackObject<IOStackObjectParsable>


@property (readonly, strong, nonatomic) NSString * _Nonnull                         adminPassword;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         name;
@property (readonly, strong, nonatomic) NSArray<NSDictionary *> * _Nonnull          securityGroups;

@property (readonly, strong, nonatomic) NSString * _Nonnull                         uidFlavor;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         uidHost;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         uidImage;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         uidTenant;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         uidUser;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         nameKeypair;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         status;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         statusHost;

@property (readonly, strong, nonatomic) NSDate * _Nonnull                           dateCreated;
@property (readonly, strong, nonatomic) NSDate * _Nonnull                           dateUpdated;

@property (readonly, strong, nonatomic) NSString * _Nonnull                         accessIPv4;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         accessIPv6;

@property (readonly, strong, nonatomic) NSNumber * _Nonnull                         useConfigDrive;
@property (readonly, strong, nonatomic) NSNumber * _Nonnull                         progress;

@property (readonly, strong, nonatomic) NSDictionary * _Nonnull                     metadata;

@property (readonly, strong, nonatomic) NSArray * _Nonnull                          arrIPsPrivate;
@property (readonly, strong, nonatomic) NSArray * _Nonnull                          arrIPsPublic;

//Extensions
@property (readonly, strong, nonatomic) NSString * _Nonnull                         OSDCFDiskConfig;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         OSEXTAZAvailability_zone;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         OSEXTSRVATTRHost;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         OSEXTSRVATTRHypervisor_hostname;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         OSEXTSRVATTRInstance_name;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         OSEXTSTSPower_state;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         OSEXTSTSTask_state;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         OSEXTSTSVm_state;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         OSSRVUSGLaunched_at;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         OSSRVUSGTerminated_at;

@property (readonly, strong, nonatomic) NSArray * _Nonnull                          OSEXTENDEDVOLUMESVolumes_attached;


+ ( nonnull NSDictionary * ) parseFromAPIResponse:( nonnull NSArray * ) arrAPIResponseData;
+ ( nonnull instancetype ) initFromAPIResponse:( nonnull NSDictionary * ) dicAPIResponse;
+ ( nonnull instancetype ) initFromAPIGETResponse:( nonnull NSDictionary * ) dicAPIGETResponse;

- ( nonnull instancetype ) initFromAPIResponse:( nonnull NSDictionary * ) dicAPIResponse;
- ( void ) refreshServerFromAPIGETResponse:( nonnull NSDictionary * ) dicAPIGETResponse;


@end
