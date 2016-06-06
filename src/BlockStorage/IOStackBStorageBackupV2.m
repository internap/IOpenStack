//
//  IOStackBStorageBackupV2.m
//  IOpenStack
//
//  Created by Bruno Morel on 2016-04-06.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import "IOStackBStorageBackupV2.h"

@implementation IOStackBStorageBackupV2


@synthesize uidVolumeFrom;
@synthesize nameContainer;
@synthesize availability_zone;
@synthesize nameBackup;
@synthesize descriptionBackup;
@synthesize status;
@synthesize created_at;
@synthesize updated_at;
@synthesize size;
@synthesize is_incremental;
@synthesize has_dependent_backups;
@synthesize object_count;
@synthesize fail_reason;


+ ( NSDictionary * ) parseFromAPIResponse:( NSArray * ) arrAPIResponseData
{
    NSMutableDictionary * parsedVolumes = [[NSMutableDictionary alloc] init];
    
    for( id currentVolume in arrAPIResponseData )
    {
        if( ![currentVolume isKindOfClass:[NSDictionary class]] )
            break;
        
        if( [currentVolume valueForKey:@"id"] == nil )
            break;
        
        IOStackBStorageBackupV2 * backup = [[IOStackBStorageBackupV2 alloc] initFromAPIResponse:currentVolume];
        
        [parsedVolumes setObject:backup
                          forKey:backup.uniqueID];
    }
    
    return parsedVolumes;
}

+ ( instancetype ) initFromAPIResponse:( NSDictionary * ) dicAPIResponse
{
    return [ [self alloc] initFromAPIResponse:dicAPIResponse ];
}

+ ( instancetype ) initFromAPIGETResponse:( NSDictionary * ) dicAPIGETResponse
{
    IOStackBStorageBackupV2 * backupResult = [[self alloc] init];
    
    [backupResult refreshBackupFromAPIGETResponse:dicAPIGETResponse andCheckConsistency:NO];
    
    return backupResult;
}

- ( instancetype ) initFromAPIResponse:( NSDictionary * ) dicAPIResponse
{
    if( dicAPIResponse == nil )
        return nil;
    
    if( self = [super init] )
    {
        self.objectType     = IOStackObjectTypeBackup;
        self.uniqueID       = dicAPIResponse[ @"id" ];
        uidVolumeFrom       = dicAPIResponse[ @"volume_id" ];
        nameContainer       = dicAPIResponse[ @"container" ];
        availability_zone   = dicAPIResponse[ @"availability_zone" ];
        nameBackup          = dicAPIResponse[ @"name" ];
        descriptionBackup   = dicAPIResponse[ @"description" ];
        status              = dicAPIResponse[ @"status" ];
        created_at          = dicAPIResponse[ @"created_at" ];
        updated_at          = dicAPIResponse[ @"updated_at" ];
        size                = dicAPIResponse[ @"size" ];
        is_incremental      = dicAPIResponse[ @"is_incremental" ];
        has_dependent_backups = dicAPIResponse[ @"has_dependent_backups" ];
        object_count        = dicAPIResponse[ @"object_count" ];
        fail_reason         = dicAPIResponse[ @"fail_reason" ];
        
    }
    return self;
}

- ( void ) refreshBackupFromAPIGETResponse:( NSDictionary * ) dicAPIGETResponse
                       andCheckConsistency:( BOOL ) bCheckForConsistency
{
    if( bCheckForConsistency &&
       ( ![self.objectType isEqualToString:IOStackObjectTypeBackup] ||
        ![self.uniqueID isEqualToString:dicAPIGETResponse[ @"id" ]] ) )
        return;
    
    else
    {
        self.objectType     = IOStackObjectTypeBackup;
        if( dicAPIGETResponse[ @"id" ] != nil )
            self.uniqueID       = dicAPIGETResponse[ @"id" ];
    }
    
    uidVolumeFrom       = dicAPIGETResponse[ @"volume_id" ];
    nameContainer       = dicAPIGETResponse[ @"container" ];
    availability_zone   = dicAPIGETResponse[ @"availability_zone" ];
    nameBackup          = dicAPIGETResponse[ @"name" ];
    descriptionBackup   = dicAPIGETResponse[ @"description" ];
    status              = dicAPIGETResponse[ @"status" ];
    created_at          = dicAPIGETResponse[ @"created_at" ];
    updated_at          = dicAPIGETResponse[ @"updated_at" ];
    size                = dicAPIGETResponse[ @"size" ];
    is_incremental      = dicAPIGETResponse[ @"is_incremental" ];
    has_dependent_backups = dicAPIGETResponse[ @"has_dependent_backups" ];
    object_count        = dicAPIGETResponse[ @"object_count" ];
    fail_reason         = dicAPIGETResponse[ @"fail_reason" ];
}

- ( void ) setAvailable:( BOOL ) isAvailable
{
    if( isAvailable )
        status = IOStackBackupStatusAvailable;
}


@end
