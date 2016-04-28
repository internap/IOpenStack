//
//  IOStackBStorageSnapshotV2.m
//  IOpenStack
//
//  Created by Bruno Morel on 2016-04-15.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import "IOStackBStorageSnapshotV2.h"

@implementation IOStackBStorageSnapshotV2


@synthesize uidVolumeFrom;
@synthesize nameSnapshot;
@synthesize descriptionSnapshot;
@synthesize status;
@synthesize created_at;
@synthesize size;
@synthesize progress;
@synthesize metadatas;
@synthesize uidProjectOrTenant;


+ ( NSDictionary * ) parseFromAPIResponse:( NSArray * ) arrAPIResponseData
{
    NSMutableDictionary * parsedVolumes = [[NSMutableDictionary alloc] init];
    
    for( id currentVolume in arrAPIResponseData )
    {
        if( ![currentVolume isKindOfClass:[NSDictionary class]] )
            break;
        
        if( [currentVolume valueForKey:@"id"] == nil )
            break;
        
        IOStackBStorageSnapshotV2 * snapshot = [[IOStackBStorageSnapshotV2 alloc] initFromAPIResponse:currentVolume];
        
        [parsedVolumes setObject:snapshot
                          forKey:snapshot.uniqueID];
    }
    
    return parsedVolumes;
}

+ ( instancetype ) initFromAPIResponse:( NSDictionary * ) dicAPIResponse
{
    return [ [self alloc] initFromAPIResponse:dicAPIResponse ];
}

+ ( instancetype ) initFromAPIGETResponse:( NSDictionary * ) dicAPIGETResponse
{
    IOStackBStorageSnapshotV2 * snapshotResult = [[self alloc] init];
    
    [snapshotResult refreshSnapshotFromAPIGETResponse:dicAPIGETResponse andCheckConsistency:NO];
    
    return snapshotResult;
}

- ( instancetype ) initFromAPIResponse:( NSDictionary * ) dicAPIResponse
{
    if( self = [super init] )
    {
        self.objectType     = IOStackObjectTypeSnapshot;
        self.uniqueID       = dicAPIResponse[ @"id" ];
        uidVolumeFrom       = dicAPIResponse[ @"volume_id" ];
        nameSnapshot        = dicAPIResponse[ @"name" ];
        descriptionSnapshot = dicAPIResponse[ @"description" ];
        status              = dicAPIResponse[ @"status" ];
        created_at          = dicAPIResponse[ @"created_at" ];
        size                = dicAPIResponse[ @"size" ];
        metadatas           = dicAPIResponse[ @"metadata" ];
        progress            = dicAPIResponse[ @"os-extended-snapshot-attributes:progress" ];
        uidProjectOrTenant  = dicAPIResponse[ @"os-extended-snapshot-attributes:project_id" ];
        
    }
    return self;
}

- ( void ) refreshSnapshotFromAPIGETResponse:( NSDictionary * ) dicAPIGETResponse
                         andCheckConsistency:( BOOL ) bCheckForConsistency
{
    if( bCheckForConsistency &&
       ( ![self.objectType isEqualToString:IOStackObjectTypeSnapshot] ||
        ![self.uniqueID isEqualToString:dicAPIGETResponse[ @"id" ]] ) )
        return;
    
    uidVolumeFrom       = dicAPIGETResponse[ @"volume_id" ];
    nameSnapshot        = dicAPIGETResponse[ @"name" ];
    descriptionSnapshot = dicAPIGETResponse[ @"description" ];
    status              = dicAPIGETResponse[ @"status" ];
    created_at          = dicAPIGETResponse[ @"created_at" ];
    size                = dicAPIGETResponse[ @"size" ];
    metadatas           = dicAPIGETResponse[ @"metadata" ];
    progress            = dicAPIGETResponse[ @"os-extended-snapshot-attributes:progress" ];
    uidProjectOrTenant  = dicAPIGETResponse[ @"os-extended-snapshot-attributes:project_id" ];
}

- ( void ) setAvailable:( BOOL ) isAvailable
{
    if( isAvailable )
        status = IOStackSnapshotStatusAvailable;
}



@end
