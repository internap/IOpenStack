//
//  IOStackComputeNetworkV2_1.h
//  IOpenStack
//
//  Created by Bruno Morel on 2016-05-03.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import "IOStackObject.h"


#define IOStackObjectTypeNetwork      @"network"


@interface IOStackComputeNetworkV2_1 : IOStackObject<IOStackObjectParsable>


@property (readonly, strong, nonatomic) NSString * _Nonnull                         labelNetwork;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         uidProject;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         nameBridge;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         nameBridgeInterface;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         ipv4CIDR;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         ipv6CIDR;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         ipv4Gateway;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         ipv6Gateway;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         ipBroadcast;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         ipv4Netmask;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         ipv6Netmask;
@property (readonly, strong, nonatomic) NSNumber * _Nonnull                         mtu;
@property (readonly, strong, nonatomic) NSNumber * _Nonnull                         priority;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         rxtx_base;
@property (readonly, strong, nonatomic) NSNumber * _Nonnull                         vlanNetwork;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         ipDHCP;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         ipDHCPStart;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         dnsServer1;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         dnsServer2;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         ipVPNPrivateAddress;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         ipVPNPublicAddress;
@property (readonly, strong, nonatomic) NSNumber * _Nonnull                         portVPNPublic;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         nameHost;
@property (readonly, strong, nonatomic) NSDate * _Nonnull                           dateCreated;
@property (readonly, strong, nonatomic) NSDate * _Nonnull                           dateUpdated;
@property (readonly, strong, nonatomic) NSDate * _Nonnull                           dateDeleted;
@property (readonly, strong, nonatomic) NSNumber * _Nonnull                         isDeleted;
@property (readonly, strong, nonatomic) NSNumber * _Nonnull                         isDHCPEnabled;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         isMultiHost;
@property (readonly, strong, nonatomic) NSNumber * _Nonnull                         isSharingAddress;
@property (readonly, strong, nonatomic) NSNumber * _Nonnull                         isInjected;


+ ( nonnull NSDictionary * ) parseFromAPIResponse:( nonnull NSArray * ) arrAPIResponseData;
+ ( nonnull instancetype ) initFromAPIResponse:( nonnull NSDictionary * ) dicAPIResponse;

+ ( nullable NSArray * ) findIDsForNetworks:( nonnull NSDictionary * ) dicNetworks
                        withLabelContaining:( nonnull NSString * ) strNetworkLabelPart;
+ ( nullable NSArray * ) findIDsForNetworks:( nonnull NSDictionary * ) dicNetworks
                             withExactLabel:( nonnull NSString * ) strNetworkLabel;

- ( nonnull instancetype ) initFromAPIResponse:( nonnull NSDictionary * ) dicAPIResponse;


@end
