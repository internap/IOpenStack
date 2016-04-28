//
//  IOStackBStorageVolumeV1.h
//  IOpenStack
//
//  Created by Bruno Morel on 2016-03-29.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import "IOStackObject.h"


#define IOStackObjectTypeVolume         @"volume"

#define IOStackVolumeStatusUnknown          @""
#define IOStackVolumeStatusCreating         @"creating"
#define IOStackVolumeStatusAvailable        @"available"
#define IOStackVolumeStatusAttaching        @"attaching"
#define IOStackVolumeStatusInUse            @"in-use"
#define IOStackVolumeStatusDeleting         @"deleting"
#define IOStackVolumeStatusBackingUp        @"backing-up"
#define IOStackVolumeStatusRestoring        @"restoring-backup"
#define IOStackVolumeStatusError            @"error"
#define IOStackVolumeStatusErrorDeleting    @"error_deleting"
#define IOStackVolumeStatusErrorRestoring   @"error_restoring"
#define IOStackVolumeStatusErrorExtending   @"error_extending"


@interface IOStackBStorageVolumeV2 : IOStackObject<IOStackObjectParsable>

@property (readonly, strong, nonatomic) NSString * _Nonnull                         nameVolume;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         descriptionVolume;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         type;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         status;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         migration_status;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         replication_status;
@property (readonly, strong, nonatomic) NSString * _Nullable                        availability_zone;
@property (readonly, strong, nonatomic) NSString * _Nullable                        snapshot_id;
@property (readonly, strong, nonatomic) NSString * _Nullable                        source_volid;
@property (readonly, strong, nonatomic) NSString * _Nullable                        consistencygroup_id;
@property (readonly, strong, nonatomic) NSNumber * _Nullable                        encrypted;
@property (readonly, strong, nonatomic) NSNumber * _Nullable                        bootable;
@property (readonly, strong, nonatomic) NSNumber * _Nullable                        multiattach;
@property (readonly, strong, nonatomic) NSDate * _Nullable                          created_at;
@property (readonly, strong, nonatomic) NSDate * _Nullable                          updated_at;
@property (readonly, strong, nonatomic) NSNumber * _Nullable                        size;
@property (readonly, strong, nonatomic) NSString * _Nullable                        user_id;
@property (readonly, strong, nonatomic) NSArray<NSDictionary *> * _Nullable         attachments;
@property (readonly, strong, nonatomic) NSDictionary * _Nullable                    metadatas;
@property (readonly, strong, nonatomic) NSDictionary * _Nullable                    volume_image_metadata;

@property (readonly, strong, nonatomic) NSString * _Nullable                        os_vol_host_attr_host;
@property (readonly, strong, nonatomic) NSString * _Nullable                        os_vol_tenant_attr_tenant_id;
@property (readonly, strong, nonatomic) NSString * _Nullable                        os_vol_mig_status_attr_migstat;
@property (readonly, strong, nonatomic) NSString * _Nullable                        os_vol_mig_status_attr_name_id;
@property (readonly, strong, nonatomic) NSString * _Nullable                        os_volume_replication_extended_status;
@property (readonly, strong, nonatomic) NSString * _Nullable                        os_volume_replication_driver_data;


+ ( nonnull NSDictionary * ) parseFromAPIResponse:( nonnull NSArray * ) arrAPIResponseData;
+ ( nonnull instancetype ) initFromAPIResponse:( nonnull NSDictionary * ) dicAPIResponse;
+ ( nonnull instancetype ) initFromAPIGETResponse:( nonnull NSDictionary * ) dicAPIGETResponse;

- ( nonnull instancetype ) initFromAPIResponse:( nonnull NSDictionary * ) dicAPIResponse;
- ( void ) setAvailable:( BOOL ) isAvailable;


@end
