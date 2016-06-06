//
//  IOStackBStorageVolumeTransferV2.m
//  IOpenStack
//
//  Created by Bruno Morel on 2016-04-15.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import "IOStackBStorageVolumeTransferV2.h"

@implementation IOStackBStorageVolumeTransferV2


@synthesize uidVolumeToTransfer;
@synthesize nameVolumeTransfer;
@synthesize keyAuthentication;
@synthesize created_at;


+ ( NSDictionary * ) parseFromAPIResponse:( NSArray * ) arrAPIResponseData
{
    NSMutableDictionary * parsedVolumeTransfers = [[NSMutableDictionary alloc] init];
    
    for( id currentVolumeTransfer in arrAPIResponseData )
    {
        if( ![currentVolumeTransfer isKindOfClass:[NSDictionary class]] )
            break;
        
        if( [currentVolumeTransfer valueForKey:@"id"] == nil )
            break;
        
        IOStackBStorageVolumeTransferV2 * volumeTransfer = [[IOStackBStorageVolumeTransferV2 alloc] initFromAPIResponse:currentVolumeTransfer];
        
        [parsedVolumeTransfers setObject:volumeTransfer
                                  forKey:volumeTransfer.uniqueID];
    }
    
    return parsedVolumeTransfers;
}

+ ( instancetype ) initFromAPIResponse:( NSDictionary * ) dicAPIResponse
{
    return [ [self alloc] initFromAPIResponse:dicAPIResponse ];
}

+ ( instancetype ) initFromAPIGETResponse:( NSDictionary * ) dicAPIGETResponse
{
    IOStackBStorageVolumeTransferV2 * volResult = [[self alloc] init];
    
    [volResult refreshVolumeTransferFromAPIGETResponse:dicAPIGETResponse andCheckConsistency:NO];
    
    return volResult;
}

- ( instancetype ) initFromAPIResponse:( NSDictionary * ) dicAPIResponse
{
    if( dicAPIResponse == nil )
        return nil;
    
    if( self = [super init] )
    {
        self.objectType     = IOStackObjectTypeVolumeTransfer;
        self.uniqueID       = dicAPIResponse[ @"id" ];
        uidVolumeToTransfer = dicAPIResponse[ @"volume_id" ];
        nameVolumeTransfer  = dicAPIResponse[ @"name" ];
        created_at          = dicAPIResponse[ @"created_at" ];
        
        if( keyAuthentication == nil )
            keyAuthentication   = dicAPIResponse[ @"auth_key" ];
    }
    return self;
}

- ( void ) refreshVolumeTransferFromAPIGETResponse:( NSDictionary * ) dicAPIGETResponse
                         andCheckConsistency:( BOOL ) bCheckForConsistency
{
    if( bCheckForConsistency &&
       ( ![self.objectType isEqualToString:IOStackObjectTypeVolumeTransfer] ||
        ![self.uniqueID isEqualToString:dicAPIGETResponse[ @"id" ]] ) )
        return;
    
    else
    {
        self.objectType     = IOStackObjectTypeVolumeTransfer;
        if( dicAPIGETResponse[ @"id" ] != nil )
            self.uniqueID       = dicAPIGETResponse[ @"id" ];
    }
    
    uidVolumeToTransfer = dicAPIGETResponse[ @"volume_id" ];
    nameVolumeTransfer  = dicAPIGETResponse[ @"name" ];
    created_at          = dicAPIGETResponse[ @"created_at" ];
    
    if( keyAuthentication == nil )
        keyAuthentication   = dicAPIGETResponse[ @"auth_key" ];
}


@end
