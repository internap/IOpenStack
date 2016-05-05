//
//  IOStackBStorageVolumeV1.m
//  IOpenStack
//
//  Created by Bruno Morel on 2016-03-29.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import "IOStackBStorageVolumeV2.h"

@implementation IOStackBStorageVolumeV2


@synthesize nameVolume;
@synthesize descriptionVolume;
@synthesize type;
@synthesize status;
@synthesize migration_status;
@synthesize replication_status;
@synthesize availability_zone;
@synthesize snapshot_id;
@synthesize source_volid;
@synthesize consistencygroup_id;
@synthesize encrypted;
@synthesize bootable;
@synthesize multiattach;
@synthesize created_at;
@synthesize updated_at;
@synthesize size;
@synthesize user_id;
@synthesize attachments;
@synthesize metadatas;
@synthesize volume_image_metadata;

@synthesize os_vol_host_attr_host;
@synthesize os_vol_tenant_attr_tenant_id;
@synthesize os_vol_mig_status_attr_migstat;
@synthesize os_vol_mig_status_attr_name_id;
@synthesize os_volume_replication_extended_status;
@synthesize os_volume_replication_driver_data;


+ ( NSDictionary * ) parseFromAPIResponse:( NSArray * ) arrAPIResponseData
{
    NSMutableDictionary * parsedVolumes = [[NSMutableDictionary alloc] init];
    
    for( id currentVolume in arrAPIResponseData )
    {
        if( ![currentVolume isKindOfClass:[NSDictionary class]] )
            break;
        
        if( [currentVolume valueForKey:@"id"] == nil )
            break;
        
        IOStackBStorageVolumeV2 * volume = [[IOStackBStorageVolumeV2 alloc] initFromAPIResponse:currentVolume];
        
        [parsedVolumes setObject:volume
                          forKey:volume.uniqueID];
    }
    
    return parsedVolumes;
}

+ ( instancetype ) initFromAPIResponse:( NSDictionary * ) dicAPIResponse
{
    return [ [self alloc] initFromAPIResponse:dicAPIResponse ];
}

+ ( instancetype ) initFromAPIGETResponse:( NSDictionary * ) dicAPIGETResponse
{
    IOStackBStorageVolumeV2 * volResult = [[self alloc] init];
    
    [volResult refreshVolumeFromAPIGETResponse:dicAPIGETResponse andCheckConsistency:NO];
    
    return volResult;
}

- ( instancetype ) initFromAPIResponse:( NSDictionary * ) dicAPIResponse
{
    if( dicAPIResponse == nil )
        return nil;
    
    if( self = [super init] )
    {
        self.objectType     = IOStackObjectTypeVolume;
        self.uniqueID       = dicAPIResponse[ @"id" ];
        nameVolume          = dicAPIResponse[ @"name" ];
        descriptionVolume   = dicAPIResponse[ @"description" ];
        type                = dicAPIResponse[ @"volume_type" ];
        status              = dicAPIResponse[ @"status" ];
        migration_status    = dicAPIResponse[ @"migration_status" ];
        replication_status  = dicAPIResponse[ @"replication_status" ];
        availability_zone   = dicAPIResponse[ @"availability_zone" ];
        snapshot_id         = dicAPIResponse[ @"snapshot_id" ];
        source_volid        = dicAPIResponse[ @"source_volid" ];
        consistencygroup_id = dicAPIResponse[ @"consistencygroup_id" ];
        encrypted           = dicAPIResponse[ @"encrypted" ];
        bootable            = dicAPIResponse[ @"bootable" ];
        multiattach         = dicAPIResponse[ @"multiattach" ];
        created_at          = dicAPIResponse[ @"created_at" ];
        updated_at          = dicAPIResponse[ @"updated_at" ];
        size                = dicAPIResponse[ @"size" ];
        user_id             = dicAPIResponse[ @"user_id" ];
        attachments         = dicAPIResponse[ @"attachments" ];
        metadatas           = dicAPIResponse[ @"metadata" ];
        volume_image_metadata= dicAPIResponse[ @"volume_image_metadata" ];
        
    }
    return self;
}

- ( void ) refreshVolumeFromAPIGETResponse:( NSDictionary * ) dicAPIGETResponse
                       andCheckConsistency:( BOOL ) bCheckForConsistency
{
    if( bCheckForConsistency &&
       ( ![self.objectType isEqualToString:IOStackObjectTypeVolume] ||
        ![self.uniqueID isEqualToString:dicAPIGETResponse[ @"id" ]] ) )
        return;
    
    nameVolume          = dicAPIGETResponse[ @"name" ];
    descriptionVolume   = dicAPIGETResponse[ @"description" ];
    type                = dicAPIGETResponse[ @"volume_type" ];
    status              = dicAPIGETResponse[ @"status" ];
    migration_status    = dicAPIGETResponse[ @"migration_status" ];
    replication_status  = dicAPIGETResponse[ @"replication_status" ];
    availability_zone   = dicAPIGETResponse[ @"availability_zone" ];
    snapshot_id         = dicAPIGETResponse[ @"snapshot_id" ];
    source_volid        = dicAPIGETResponse[ @"source_volid" ];
    consistencygroup_id = dicAPIGETResponse[ @"consistencygroup_id" ];
    encrypted           = dicAPIGETResponse[ @"encrypted" ];
    bootable            = dicAPIGETResponse[ @"bootable" ];
    multiattach         = dicAPIGETResponse[ @"multiattach" ];
    created_at          = dicAPIGETResponse[ @"created_at" ];
    updated_at          = dicAPIGETResponse[ @"updated_at" ];
    size                = dicAPIGETResponse[ @"size" ];
    user_id             = dicAPIGETResponse[ @"user_id" ];
    attachments         = dicAPIGETResponse[ @"attachments" ];
    metadatas           = dicAPIGETResponse[ @"metadata" ];
    volume_image_metadata= dicAPIGETResponse[ @"volume_image_metadata" ];
    
    os_vol_host_attr_host               = dicAPIGETResponse[ @"os-vol-host-attr:host" ];
    os_vol_tenant_attr_tenant_id        = dicAPIGETResponse[ @"os-vol-tenant-attr:tenant_id" ];
    os_vol_mig_status_attr_migstat      = dicAPIGETResponse[ @"os-vol-mig-status-attr:migstat" ];
    os_vol_mig_status_attr_name_id      = dicAPIGETResponse[ @"os-vol-mig-status-attr:name_id" ];
    os_volume_replication_extended_status= dicAPIGETResponse[ @"os-volume-replication:extended_status " ];
    os_volume_replication_driver_data   = dicAPIGETResponse[ @"os-volume-replication:driver_data " ];
}

- ( void ) setAvailable:( BOOL ) isAvailable
{
    if( isAvailable )
        status = IOStackVolumeStatusAvailable;
}


@end
