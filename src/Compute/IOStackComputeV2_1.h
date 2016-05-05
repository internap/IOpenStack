//
//  IOStackComputeV2.h
//  IOpenStack
//
//  Created by Bruno Morel on 2016-01-12.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "IOStackAuth.h"
#import "IOStackComputeServerV2_1.h"
#import "IOStackComputeFlavorV2_1.h"
#import "IOStackComputeKeypairV2_1.h"
#import "IOStackComputeSecurityGroupV2_1.h"
#import "IOStackComputeSecurityGroupRuleV2_1.h"
#import "IOStackComputeIPAllocationV2_1.h"
#import "IOStackComputeNetworkV2_1.h"


@interface IOStackComputeV2_1 : IOStackService


// local property accessors
@property (strong, strong, nonatomic) NSString * _Nonnull                       currentTokenID;
@property (strong, strong, nonatomic) NSString * _Nullable                      currentProjectOrTenantID;


+ ( nonnull instancetype ) initWithComputeURL:( nonnull NSString * ) strComputeRoot
                                   andTokenID:( nonnull NSString * ) strTokenID
                         forProjectOrTenantID:( nonnull NSString * ) strProjectOrTenantID;
+ ( nonnull instancetype ) initWithIdentity:( nonnull id<IOStackIdentityInfos> ) idUserIdentity;

- ( nonnull instancetype ) initWithComputeURL:( nonnull NSString * ) strComputeRoot
                                   andTokenID:( nonnull NSString * ) strTokenID
                         forProjectOrTenantID:( nonnull NSString * ) strProjectOrTenantID;
- ( nonnull instancetype ) initWithIdentity:( nonnull id<IOStackIdentityInfos> ) idUserIdentity;
- ( void ) listFlavorsThenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicFlavors ) ) doAfterList;
- ( void ) listServersThenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicServers, id _Nullable idFullResponse ) ) doAfterList;
- ( void ) createServerWithUrlParams:( nullable NSDictionary * ) dicUrlParams
                       andServerName:( nullable NSString * ) strServerName
                   waitUntilIsActive:( BOOL ) bWaitActive
                              thenDo:( nullable void ( ^ ) ( IOStackComputeServerV2_1 * _Nullable serverCreated,  NSDictionary * _Nullable dicFullResponse ) ) doAfterCreate;
- ( void ) createServerWithName:( nonnull NSString * ) strServerName
                    andFlavorID:( nonnull NSString * ) uuidFlavor
                     andImageID:( nonnull NSString * ) uuidImage
                 andKeypairName:( nullable NSString * ) strKeypairName
                    andUserData:( nullable NSString * ) strUserData
         andSecurityGroupsNames:( nullable NSArray * ) arrSecurityGroupsNames
              onNetworksWithIDs:( nullable NSArray * ) arrNetworksID
              waitUntilIsActive:( BOOL ) bWaitActive
                         thenDo:( nullable void ( ^ ) ( IOStackComputeServerV2_1 * _Nullable serverCreated, NSDictionary * _Nullable dicFullResponse ) ) doAfterCreate;
- ( void ) createServerWithName:( nonnull NSString * ) strServerName
                    andFlavorID:( nonnull NSString * ) uuidFlavor
                     andImageID:( nonnull NSString * ) uuidImage
              waitUntilIsActive:( BOOL ) bWaitActive
                         thenDo:( nullable void ( ^ ) ( IOStackComputeServerV2_1 * _Nullable serverCreated,  NSDictionary * _Nullable dicFullResponse ) ) doAfterCreate;
- ( void ) waitServerWithID:( nonnull NSString * ) uidServer
                  forStatus:( nonnull NSString * ) statusServer
                     thenDo:( nullable void ( ^ ) ( bool isWithStatus ) ) doAfterWait;
- ( void ) deleteServerWithID:( nonnull NSString * ) uuidServer
           waitUntilIsDeleted:( BOOL ) bWaitDeleted
                       thenDo:( nullable void ( ^ ) ( bool isDeleted, id _Nullable idFullResponse ) ) doAfterDelete;
- ( void ) deleteServerWithID:( nonnull NSString * ) uuidServer
                       thenDo:( nullable void ( ^ ) ( bool isDeleted, id _Nullable idFullResponse ) ) doAfterDelete;
- ( void ) listIPsForServerWithID:( nonnull NSString * ) uidServer
                           thenDo:( nullable void ( ^ ) ( NSArray * _Nullable dicPrivateIPs, NSArray * _Nullable dicPublicIPs, id _Nullable idFullResponse ) ) doAfterList;
- ( void ) listIPFromPoolWithStatus:( nullable NSString * ) statusIP
                  excludingFixedIPs:( BOOL ) bNoFixedIPs
                             thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicIPsFromPool, id _Nullable idFullResponse ) ) doAfterList;
- ( void ) createIPAllocationFromPool:( nullable NSString * ) strPoolName
                               thenDo:( nullable void ( ^ ) ( IOStackComputeIPAllocationV2_1 * _Nullable fipCreated, id _Nullable idFullResponse ) ) doAfterCreate;
- ( void ) deleteIPAllocationWithID:( nonnull NSString * ) uidFloatingIPAllocationID
                             thenDo:( nullable void ( ^ ) ( bool isDeleted ) ) doAfterDelete;
- ( void ) addIPToServerWithID:( nonnull NSString * ) uidServer
        usingFloatingIPAddress:( nonnull NSString * ) ipAddress
                        thenDo:( nullable void ( ^ ) ( BOOL isAssociated, id _Nullable idFullResponse ) ) doAfterAdd;
- ( void ) addIPToServerWithID:( nonnull NSString * ) uidServer
        usingFixedIPNetworkUID:( nonnull NSString * ) uidNetwork
                        thenDo:( nullable void ( ^ ) ( BOOL isAssociated, id _Nullable idFullResponse ) ) doAfterAdd;
- ( void ) listKeypairsThenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicKeypairs, id _Nullable idFulleResponse ) ) doAfterList;
- ( void ) createKeypairWithName:( nonnull NSString * ) strKeypairName
                    andPublicKey:( nullable NSString * ) strPublicKey
                          thenDo:( nullable void ( ^ ) ( IOStackComputeKeypairV2_1 * _Nullable keyCreated, id _Nullable idFullResponse ) ) doAfterCreate;
- ( void ) createKeypairWithName:( nonnull NSString * ) strKeypairName
            andPublicKeyFilePath:( nonnull NSString * ) strPublicKeyCompleteFilePath
                          thenDo:( nullable void ( ^ ) ( IOStackComputeKeypairV2_1 * _Nullable keyCreated, id _Nullable idFullResponse ) ) doAfterCreate;
- ( void ) deleteKeypairWithName:( nonnull NSString * ) strKeypairName
                          thenDo:( nullable void ( ^ ) ( bool isDeleted ) ) doAfterDelete;
- ( void ) listActionsForServer:( nonnull NSString * ) strServerUUID
                         thenDo:( nullable void ( ^ ) ( NSArray * _Nullable arrServerActions, id _Nullable idFullResponse ) ) doAfterList;
- ( void ) listSecurityGroupsThenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicSecurityGroups, id _Nullable idFullResponse ) ) doAfterList;
- ( void ) createSecurityGroupWithName:( nonnull NSString * ) strSecurityGroupName
                        andDescription:( nullable NSString * ) strSecurityGroupDescription
                                thenDo:( nullable void ( ^ ) ( IOStackComputeSecurityGroupV2_1 * _Nullable secCreated, id _Nullable idFullResponse ) ) doAfterCreate;
- ( void ) deleteSecurityGroupWithID:( nonnull NSString * ) strSecurityGroupID
                              thenDo:( nullable void ( ^ ) ( bool isDeleted ) ) doAfterDelete;
- ( void ) addRuleToSecurityGroupWithID:( nonnull NSString * ) uidSecurityGroupID
                           withProtocol:( nonnull NSString * ) strIPProtocolName
                               FromPort:( nonnull NSNumber * ) nPortFrom
                                 ToPort:( nullable NSNumber * ) nPortTo
                                AndCIDR:( nullable NSString * ) strCIDR
                                 thenDo:( nullable void ( ^ ) ( IOStackComputeSecurityGroupRuleV2_1 * _Nullable ruleCreated, id _Nullable idFullResponse ) ) doAfterCreate;
- ( void ) deleteSecurityGroupRuleWithID:( nonnull NSString * ) uidSecurityGroupRule
                                  thenDo:( nullable void ( ^ ) ( bool isDeleted ) ) doAfterDelete;
- ( void ) listNetworksThenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicNetworks, id _Nullable idFullResponse ) ) doAfterList;
- ( void ) createNetworkWithLabel:( nonnull NSString * ) nameNetwork
                          andCIDR:( nullable NSString * ) ipCIDR
                           andMTU:( nullable NSNumber * ) nMTU
                    andDHCPServer:( nullable NSString * ) ipDHCPServer
                       startingAt:( nullable NSString * ) ipStartingIP
                         endingAt:( nullable NSString * ) ipEndingIP
                 isSharingAddress:( BOOL ) isSharing
                           thenDo:( nullable void ( ^ ) ( IOStackComputeNetworkV2_1 * _Nullable networkCreated, id _Nullable idFullResponse ) ) doAfterCreate;
- ( void ) getDetailsForNetworkWithID:( nonnull NSString * ) uidNetwork
                               thenDo:( nullable void ( ^ ) ( IOStackComputeNetworkV2_1 * _Nullable networkDetails, id _Nullable idFullResponse ) ) doAfterGet;
- ( void ) addNetworkWithID:( nonnull NSString * ) uidNetwork
                     thenDo:( nullable void ( ^ ) ( BOOL isAdded, id _Nullable idFullResponse ) ) doAfterAdd;
- ( void ) deleteNetworkWithID:( nonnull NSString * ) uidNetwork
                        thenDo:( nullable void ( ^ ) ( bool isDeleted ) ) doAfterDelete;
- ( void ) findNetworksWithLabelContaining:( nonnull NSString * ) strNetworkLabelPart
                                    thenDo:( nullable void ( ^ ) ( NSArray * _Nullable arrNetworksWithLabelContaining, id _Nullable idFullResponse ) ) doAfterFind;
- ( void ) findNetworksWithExactLabel:( nonnull NSString * ) strNetworkLabel
                               thenDo:( nullable void ( ^ ) ( NSArray * _Nullable arrNetworksWithLabelContaining, id _Nullable idFullResponse ) ) doAfterFind;


@end
