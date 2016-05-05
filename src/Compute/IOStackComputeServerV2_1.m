//
//  IOStackServerObjectV2_1.m
//  IOpenStack
//
//  Created by Bruno Morel on 2016-01-25.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import "IOStackComputeServerV2_1.h"

@implementation IOStackServerObjectV2_1

@synthesize name;
@synthesize adminPassword;
@synthesize securityGroups;
@synthesize uidFlavor;
@synthesize uidHost;
@synthesize uidImage;
@synthesize uidTenant;
@synthesize uidUser;
@synthesize nameKeypair;
@synthesize created;
@synthesize status;
@synthesize statusHost;

@synthesize progress;

@synthesize metadata;

@synthesize arrIPsPrivate;
@synthesize arrIPsPublic;

//Extensions
@synthesize OSDCFDiskConfig;
@synthesize OSEXTAZAvailability_zone;
@synthesize OSEXTSRVATTRHost;
@synthesize OSEXTSRVATTRHypervisor_hostname;
@synthesize OSEXTSRVATTRInstance_name;
@synthesize OSEXTSTSPower_state;
@synthesize OSEXTSTSTask_state;
@synthesize OSEXTSTSVm_state;
@synthesize OSSRVUSGLaunched_at;
@synthesize OSSRVUSGTerminated_at;

@synthesize OSEXTENDEDVOLUMESVolumes_attached;


+ ( NSDictionary * ) parseFromAPIResponse:( NSArray * ) arrAPIResponseData
{
    NSMutableDictionary * parsedServers = [[NSMutableDictionary alloc] init];
    
    for( id currentServer in arrAPIResponseData )
    {
        if( ![currentServer isKindOfClass:[NSDictionary class]] )
            break;
        
        if( [currentServer valueForKey:@"id"] == nil )
            break;
        
        IOStackServerObjectV2_1 * server = [[IOStackComputeServerV2_1 alloc] initFromAPIResponse:currentServer];
        
        [parsedServers setObject:server
                          forKey:server.uniqueID];
    }
    
    return parsedServers;
}

+ ( instancetype ) initFromAPIResponse:( NSDictionary * ) dicAPIResponse
{
    return [ [self alloc] initFromAPIResponse:dicAPIResponse ];
}

+ ( instancetype ) initFromAPIGETResponse:( NSDictionary * ) dicAPIGETResponse
{
    IOStackComputeServerV2_1 * servResult = [[self alloc] init];
    
    [servResult refreshServerFromAPIGETResponse:dicAPIGETResponse andCheckConsistency:NO];
    
    return servResult;
}

- ( instancetype ) initFromAPIResponse:( NSDictionary * ) dicAPIResponse
{
    if( self = [super init] )
    {
        self.objectType     = IOStackObjectTypeServer;
        self.uniqueID       = dicAPIResponse[ @"id" ];
        name                = dicAPIResponse[ @"name" ];
        adminPassword       = dicAPIResponse[ @"adminPass" ];
        securityGroups      = dicAPIResponse[ @"security_groups" ];
    }
    return self;
}

- ( void ) refreshServerFromAPIGETResponse:( NSDictionary * ) dicAPIGETResponse
                       andCheckConsistency:( BOOL ) bCheckForConsistency
{
    if( bCheckForConsistency &&
       ( ![self.objectType isEqualToString:IOStackObjectTypeServer] ||
         ![self.uniqueID isEqualToString:dicAPIGETResponse[ @"id" ]] ) )
        return;
    
    name                = dicAPIGETResponse[ @"name" ];
    created             = dicAPIGETResponse[ @"created" ];
    uidTenant           = dicAPIGETResponse[ @"tenant_id" ];
    uidUser             = dicAPIGETResponse[ @"user_id" ];
    if( dicAPIGETResponse[ @"flavor" ] != nil )
        uidFlavor       = dicAPIGETResponse[ @"flavor" ][ @"id" ];
    
    uidHost = dicAPIGETResponse[ @"image" ];
    if( dicAPIGETResponse[ @"flavor" ] != nil )
        uidImage        = dicAPIGETResponse[ @"image" ][ @"id" ];
    
    nameKeypair         = dicAPIGETResponse[ @"key_name" ];
    progress            = dicAPIGETResponse[ @"progress" ];
    securityGroups      = dicAPIGETResponse[ @"security_groups" ];
    status              = dicAPIGETResponse[ @"status" ];
    statusHost          = dicAPIGETResponse[ @"host_status" ];
    
    metadata = dicAPIGETResponse[ @"metadata" ];

    if( dicAPIGETResponse[ @"addresses" ] != nil )
    {
        NSDictionary * dicAddresses = dicAPIGETResponse[ @"addresses" ];
        if( dicAddresses[ @"private" ] != nil )
            arrIPsPrivate = dicAddresses[ @"private" ];
        
        
        if( dicAddresses[ @"public" ] != nil )
            arrIPsPublic = dicAddresses[ @"public" ];
    };
    
    OSDCFDiskConfig                     = dicAPIGETResponse[ @"OS-DCF:diskConfig" ];
    OSEXTAZAvailability_zone            = dicAPIGETResponse[ @"OS-EXT-AZ:availability_zone" ];
    OSEXTSRVATTRHost                    = dicAPIGETResponse[ @"OS-EXT-SRV-ATTR:host" ];
    OSEXTSRVATTRHypervisor_hostname     = dicAPIGETResponse[ @"OS-EXT-SRV-ATTR:hypervisor_hostname" ];
    OSEXTSRVATTRInstance_name           =  dicAPIGETResponse[ @"OS-EXT-SRV-ATTR:instance_name" ];
    
    OSEXTSTSPower_state                 = dicAPIGETResponse[ @"OS-EXT-STS:power_state" ];
    OSEXTSTSTask_state                  = dicAPIGETResponse[ @"OS-EXT-STS:task_state" ];
    OSEXTSTSVm_state                    = dicAPIGETResponse[ @"OS-EXT-STS:vm_state" ];
    OSEXTENDEDVOLUMESVolumes_attached   = dicAPIGETResponse[ @"os-extended-volumes:volumes_attached" ];
    OSSRVUSGLaunched_at                 = dicAPIGETResponse[ @"OS-SRV-USG:launched_at	plain" ];
    OSSRVUSGTerminated_at               = dicAPIGETResponse[ @"OS-SRV-USG:terminated_at" ];
}

- ( void ) refreshServerFromAPIGETResponse:( NSDictionary * ) dicAPIGETResponse
{
    [self refreshServerFromAPIGETResponse:dicAPIGETResponse
                      andCheckConsistency:YES];
}


@end
