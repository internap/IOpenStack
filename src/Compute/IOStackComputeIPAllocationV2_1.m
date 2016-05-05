//
//  IOStackServerFloatingIPAddressV2_1.m
//  IOpenStack
//
//  Created by Bruno Morel on 2016-02-26.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import "IOStackComputeIPAllocationV2_1.h"

@implementation IOStackComputeIPAllocationV2_1

@synthesize uidInstance;
@synthesize namePool;
@synthesize ipAddress;
@synthesize ipAddressFixed;


+ ( instancetype ) initFromAPIResponse:( NSDictionary * ) dicAPIResponse
{
    return [ [self alloc] initFromAPIResponse:dicAPIResponse ];
}


- ( instancetype ) initFromAPIResponse:( NSDictionary * ) dicAPIResponse
{
    if( dicAPIResponse == nil )
        return nil;
    
    if( self = [super init] )
    {
        self.objectType     = IOStackObjectTypeFloatingIP;
        self.uniqueID       = dicAPIResponse[ @"id" ];
        uidInstance         = dicAPIResponse[ @"instance_id" ];
        namePool            = dicAPIResponse[ @"pool" ];
        ipAddress           = dicAPIResponse[ @"ip" ];
        ipAddressFixed      = dicAPIResponse[ @"fixed_ip" ];
    }
    return self;
}


@end
