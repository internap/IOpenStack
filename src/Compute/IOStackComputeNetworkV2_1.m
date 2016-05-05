//
//  IOStackComputeNetworkV2_1.m
//  IOpenStack
//
//  Created by Bruno Morel on 2016-05-03.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import "IOStackComputeNetworkV2_1.h"


@implementation IOStackComputeNetworkV2_1


@synthesize labelNetwork;
@synthesize uidProject;
@synthesize nameBridge;
@synthesize nameBridgeInterface;
@synthesize ipv4CIDR;
@synthesize ipv6CIDR;
@synthesize ipv4Gateway;
@synthesize ipv6Gateway;
@synthesize ipv4Netmask;
@synthesize ipv6Netmask;
@synthesize ipBroadcast;
@synthesize mtu;
@synthesize priority;
@synthesize rxtx_base;
@synthesize vlanNetwork;
@synthesize ipDHCP;
@synthesize ipDHCPStart;
@synthesize dnsServer1;
@synthesize dnsServer2;
@synthesize ipVPNPrivateAddress;
@synthesize ipVPNPublicAddress;
@synthesize portVPNPublic;
@synthesize nameHost;
@synthesize dateCreated;
@synthesize dateUpdated;
@synthesize dateDeleted;
@synthesize isDeleted;
@synthesize isDHCPEnabled;
@synthesize isSharingAddress;
@synthesize isMultiHost;
@synthesize isInjected;


+ ( NSDictionary * ) parseFromAPIResponse:( NSArray * ) arrAPIResponseData
{
    NSMutableDictionary * parsedNetworks = [[NSMutableDictionary alloc] init];
    
    for( id currentNetwork in arrAPIResponseData )
    {
        if( ![currentNetwork isKindOfClass:[NSDictionary class]] )
            break;
        
        if( [currentNetwork valueForKey:@"id"] == nil )
            break;
        
        IOStackComputeNetworkV2_1 * network = [[IOStackComputeNetworkV2_1 alloc] initFromAPIResponse:currentNetwork];
        
        [parsedNetworks setObject:network
                           forKey:network.uniqueID];
    }
    
    return parsedNetworks;
}

+ ( id ) initFromAPIResponse:( NSDictionary * ) dicAPIResponse
{
    return [ [self alloc] initFromAPIResponse:dicAPIResponse ];
}


+ ( NSArray * ) findIDsForNetworks:( NSDictionary * ) dicNetworks
                    withLabelContaining:( NSString * ) strNetworkLabelPart
{
    NSMutableArray * foundID = [NSMutableArray array];
    
    for( NSString * currentNetworkID in dicNetworks )
    {
        IOStackComputeNetworkV2_1 * currentNetwork = [dicNetworks valueForKey:currentNetworkID];
        if( [currentNetwork.labelNetwork containsString:strNetworkLabelPart] )
            [foundID addObject:currentNetwork.uniqueID];
    }
    
    return foundID;
}

+ ( NSArray * ) findIDsForNetworks:( NSDictionary * ) dicNetworks
                    withExactLabel:( NSString * ) strNetworkLabel
{
    NSMutableArray * foundID = [NSMutableArray array];
    
    for( NSString * currentNetworkID in dicNetworks )
    {
        IOStackComputeNetworkV2_1 * currentNetwork = [dicNetworks valueForKey:currentNetworkID];
        if( [currentNetwork.labelNetwork isEqualToString:strNetworkLabel] )
            [foundID addObject:currentNetwork.uniqueID];
    }
    
    return foundID;
}


- ( instancetype ) initFromAPIResponse:( NSDictionary * ) dicAPIResponse
{
    if( dicAPIResponse == nil )
        return nil;
    
    if( self = [super init] )
    {
        self.objectType     = IOStackObjectTypeNetwork;
        self.uniqueID       = dicAPIResponse[ @"id" ];
        
        labelNetwork            = dicAPIResponse[ @"label" ];
        uidProject              = dicAPIResponse[ @"project_id" ];
        nameBridge              = dicAPIResponse[ @"bridge" ];
        nameBridgeInterface     = dicAPIResponse[ @"bridge_interface" ];
        ipv4CIDR                = dicAPIResponse[ @"cidr" ];
        ipv6CIDR                = dicAPIResponse[ @"cidr_v6" ];
        ipv4Gateway             = dicAPIResponse[ @"gateway" ];
        ipv6Gateway             = dicAPIResponse[ @"gateway_v6" ];
        ipBroadcast             = dicAPIResponse[ @"broadcast" ];
        ipv4Netmask             = dicAPIResponse[ @"netmask" ];
        ipv6Netmask             = dicAPIResponse[ @"netmask_v6" ];
        mtu                     = dicAPIResponse[ @"mtu" ];
        priority                = dicAPIResponse[ @"priority" ];
        rxtx_base               = dicAPIResponse[ @"rxtx_base" ];
        vlanNetwork             = dicAPIResponse[ @"vlan" ];
        ipDHCP                  = dicAPIResponse[ @"dhcp_server" ];
        ipDHCPStart             = dicAPIResponse[ @"dhcp_start" ];
        dnsServer1              = dicAPIResponse[ @"dns1" ];
        dnsServer2              = dicAPIResponse[ @"dns2" ];
        ipVPNPrivateAddress     = dicAPIResponse[ @"vpn_private_address" ];
        ipVPNPublicAddress      = dicAPIResponse[ @"vpn_public_address" ];
        portVPNPublic           = dicAPIResponse[ @"vpn_public_port" ];
        nameHost                = dicAPIResponse[ @"host" ];
        dateUpdated             = dicAPIResponse[ @"updated_at" ];
        dateCreated             = dicAPIResponse[ @"created_at" ];
        dateDeleted             = dicAPIResponse[ @"deleted_at" ];
        isDeleted               = dicAPIResponse[ @"deleted" ];
        isDHCPEnabled           = dicAPIResponse[ @"enable_dhcp" ];
        isMultiHost             = dicAPIResponse[ @"multi_host" ];
        isSharingAddress        = dicAPIResponse[ @"share_address" ];
        isInjected              = dicAPIResponse[ @"injected" ];
    }
    return self;
}


@end
