//
//  IOStackComputeV2.m
//  IOpenStack
//
//  Created by Bruno Morel on 2016-01-12.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import "IOStackComputeV2_1.h"


#define COMPUTEV2_1_SERVICE_URI             @"v2.1/"
#define COMPUTEV2_1_SERVER_URN              @"servers"
#define COMPUTEV2_1_SERVERSDETAIL_URN       @"servers/detail"
#define COMPUTEV2_1_FLAVOR_URN              @"flavors"
#define COMPUTEV2_1_IP_URN                  @"ips"
#define COMPUTEV2_1_ACTION_URN              @"action"
#define COMPUTEV2_1_KEYPAIR_URN             @"os-keypairs"
#define COMPUTEV2_1_INSTANCEACTION_URN      @"os-instance-actions"
#define COMPUTEV2_1_SECURITYGROUP_URN       @"os-security-groups"
#define COMPUTEV2_1_SECURITYGROUPRULES_URN  @"os-security-group-rules"
#define COMPUTEV2_1_FLOATINGIP_URN          @"os-floating-ips"
#define COMPUTEV2_1_NETWORKS_URN            @"os-networks"
#define COMPUTEV2_1_NETWORKADD_URN          @"add"


@implementation IOStackComputeV2_1

@synthesize currentTokenID;
@synthesize currentProjectOrTenantID;


+ ( instancetype ) initWithComputeURL:( NSString * ) strComputeRoot
                           andTokenID:( NSString * ) strTokenID
                 forProjectOrTenantID:( NSString * ) strProjectOrTenant
{
    return [ [ self alloc ] initWithComputeURL:strComputeRoot
                                    andTokenID:strTokenID
                          forProjectOrTenantID:strProjectOrTenant ];
}

+ ( instancetype ) initWithIdentity:( id<IOStackIdentityInfos> ) idUserIdentity
{
    return [ [ self alloc ] initWithIdentity:idUserIdentity ];
}


#pragma mark - Object init
- ( instancetype ) initWithComputeURL:( NSString * ) strComputeRoot
                           andTokenID:( NSString * ) strTokenID
                 forProjectOrTenantID:( NSString * ) strProjectOrTenantID

{
    if( self = [super initWithPublicURL:[NSURL URLWithString:strComputeRoot]
                                andType:COMPUTE_SERVICE
                        andMajorVersion:@2
                        andMinorVersion:@0
                        andProviderName:GENERIC_SERVICENAME] )
    {
        currentTokenID = strTokenID;
        currentProjectOrTenantID = strProjectOrTenantID;
        
        [self setHTTPHeader:@"X-Auth-Token"
                  withValue:currentTokenID];
        
    }
    
    return self;
}

- ( instancetype ) initWithIdentity:( id<IOStackIdentityInfos> ) idUserIdentity
{
    IOStackService * currentService = [idUserIdentity.currentServices valueForKey:COMPUTE_SERVICE];
    
    if( idUserIdentity.currentProjectOrTenantID == nil )
        return nil;
    
    return [self initWithComputeURL:[[currentService urlPublic] absoluteString]
                         andTokenID:idUserIdentity.currentTokenID
               forProjectOrTenantID:idUserIdentity.currentProjectOrTenantID];
}


#pragma mark - Flavor management
- ( void ) listFlavorsThenDo:( void ( ^ ) ( NSDictionary * dicFlavours ) ) doAfterList
{
    [self listResource:COMPUTEV2_1_FLAVOR_URN
            withHeader:nil
          andUrlParams:nil
             insideKey:@"flavors"
                thenDo:^(NSArray * _Nullable arrFound, id  _Nullable dataResponse)
    {
        if( doAfterList != nil )
            doAfterList( [IOStackComputeFlavorV2_1 parseFromAPIResponse:arrFound] );
    }];
}


#pragma mark - Server management
- ( void ) listServersThenDo:( void ( ^ ) ( NSDictionary * dicServers, id idFullResponse ) ) doAfterList
{
    [self listResource:COMPUTEV2_1_SERVER_URN
            withHeader:nil
          andUrlParams:nil
             insideKey:@"servers"
                thenDo:^(NSArray * _Nullable arrFound, id  _Nullable dataResponse)
    {
        if( doAfterList != nil )
            doAfterList( [IOStackComputeServerV2_1 parseFromAPIResponse:arrFound], dataResponse );
    }];
}

- ( void ) createServerWithUrlParams:( NSDictionary * ) dicUrlParams
                       andServerName:( NSString * ) strServerName
                   waitUntilIsActive:( BOOL ) bWaitActive
                              thenDo:( void ( ^ ) ( IOStackComputeServerV2_1 * serverCreated, NSDictionary * dicFullResponse ) ) doAfterCreate
{
    [self createResource:COMPUTEV2_1_SERVER_URN
              withHeader:nil
            andUrlParams:dicUrlParams
                  thenDo:^(NSDictionary * _Nullable dicResponseHeaders, id  _Nullable idFullResponse)
    {
        NSMutableDictionary * dicServerResultWithName = [NSMutableDictionary dictionaryWithDictionary:[idFullResponse objectForKey:@"server"]];
        [dicServerResultWithName setObject:strServerName
                                    forKey:@"name"];
        IOStackComputeServerV2_1 * newServer = [IOStackComputeServerV2_1 initFromAPIResponse:dicServerResultWithName];
        
        if( bWaitActive )
            [self waitServerWithID:newServer.uniqueID
                         forStatus:IOStackServerStatusActive
                            thenDo:^( bool isWithStatus )
             {
                 if( doAfterCreate != nil )
                 {
                     if( isWithStatus )
                         doAfterCreate( newServer, idFullResponse );
                     
                     else
                     {
                         NSLog( @"Creation failed" );
                         doAfterCreate( nil, nil );
                     }
                 }
             }];
        
        else
            doAfterCreate( newServer, idFullResponse );
    }];
}

- ( void ) createServerWithName:( NSString * ) strServerName
                    andFlavorID:( NSString * ) uuidFlavor
                     andImageID:( NSString * ) uuidImage
                 andKeypairName:( NSString * ) strKeypairName
                    andUserData:( NSString * ) strUserData
         andSecurityGroupsNames:( NSArray * ) arrSecurityGroupsNames
              onNetworksWithIDs:( NSArray * ) arrNetworksID
              waitUntilIsActive:( BOOL ) bWaitActive
                         thenDo:( void ( ^ ) ( IOStackComputeServerV2_1 * serverCreated, NSDictionary * dicFullResponse ) ) doAfterCreate
{
    //NSDictionary * dicParams        = nil;
    NSMutableDictionary * dicParams = [NSMutableDictionary dictionaryWithObject:strServerName forKey:@"name"];
    
    dicParams[ @"flavorRef" ] = uuidFlavor;
    dicParams[ @"imageRef" ] = uuidImage;
    
    if( strKeypairName != nil )
        dicParams[ @"key_name" ] = strKeypairName;
    
    if( strUserData != nil )
    {
        NSData * dataUTF8User           = [strUserData dataUsingEncoding:NSUTF8StringEncoding];
        NSString * strBase64            = [dataUTF8User base64EncodedStringWithOptions:0];
        dicParams[ @"user_data" ] = strBase64;
    }
    
    if( arrSecurityGroupsNames != nil &&
       [arrSecurityGroupsNames count] > 0 )
    {
        NSArray * arrSecurityGroupNamesObjects = [IOStackComputeSecurityGroupV2_1 createSecurityGroupNameArrayForAPIFromNameArray:arrSecurityGroupsNames];
        if( arrSecurityGroupNamesObjects == nil )
        {
            if( doAfterCreate != nil )
                doAfterCreate( nil, nil );
            
            return;
        }
        dicParams[ @"security_groups" ] = arrSecurityGroupNamesObjects;
    }
    
    if( arrNetworksID != nil )
    {
        NSMutableArray * arrNetworksIDParams = [NSMutableArray array];
        for (NSString * currentNetworkID in arrNetworksID)
            [arrNetworksIDParams addObject:@{@"uuid" : currentNetworkID}];
        
        dicParams[ @"networks" ] = arrNetworksIDParams;
    }
    
    [self createServerWithUrlParams:@{@"server": dicParams}
                      andServerName:strServerName
                  waitUntilIsActive:bWaitActive
                             thenDo:doAfterCreate];
}


- ( void ) createServerWithName:( NSString * ) strServerName
                    andFlavorID:( NSString * ) uidFlavor
                     andImageID:( NSString * ) uidImage
              waitUntilIsActive:( BOOL ) bWaitActive
                         thenDo:( void ( ^ ) ( IOStackComputeServerV2_1 * serverCreated, NSDictionary * dicFullResponse ) ) doAfterCreate
{
    [self createServerWithName:strServerName
                   andFlavorID:uidFlavor
                    andImageID:uidImage
                andKeypairName:nil
                   andUserData:nil
        andSecurityGroupsNames:nil
             onNetworksWithIDs:nil
             waitUntilIsActive:bWaitActive
                        thenDo:doAfterCreate];
}

- ( void ) deleteServerWithID:( NSString * ) uidServer
           waitUntilIsDeleted:( BOOL ) bWaitDeleted
                       thenDo:( void ( ^ ) ( bool isDeleted, id idFullResponse ) ) doAfterDelete
{
    NSString * urlServer = [NSString stringWithFormat:@"%@/%@", COMPUTEV2_1_SERVER_URN, uidServer];
    [self deleteResource:urlServer
              withHeader:nil
                  thenDo:^(NSDictionary * _Nullable dicResults, id  _Nullable idFullResponse)
    {
        if( bWaitDeleted)
            [self waitServerWithID:uidServer
                         forStatus:IOStackServerStatusDeleted
                            thenDo:^(bool isWithStatus)
        {
            if( doAfterDelete != nil )
                doAfterDelete( isWithStatus, idFullResponse );
        }];
        else
            doAfterDelete( ( idFullResponse == nil ) ||
                                ( idFullResponse[ @"response" ] == nil ) ||
                                ( [idFullResponse[ @"response" ] isEqualToString:@""] ),
                          idFullResponse );
    }];
}

- ( void ) deleteServerWithID:( NSString * ) uidServer
                       thenDo:( void ( ^ ) ( bool isDeleted, id idFullResponse ) ) doAfterDelete
{
    [self deleteServerWithID:uidServer
          waitUntilIsDeleted:NO
                      thenDo:doAfterDelete];
}


#pragma mark - Refresh status info loop mechanism
- ( void ) waitServerWithID:( NSString * ) uidServer
                  forStatus:( NSString * ) statusServer
                     thenDo:( void ( ^ ) ( bool isWithStatus ) ) doAfterWait
{
    NSString * urlServer = [NSString stringWithFormat:@"%@/%@", COMPUTEV2_1_SERVER_URN, uidServer];
    if( [statusServer isEqualToString:IOStackServerStatusDeleted] )
        [self waitResource:urlServer
             withUrlParams:nil
                 insideKey:@"server"
                  forField:nil
              toEqualValue:nil
             orErrorValues:IOStackServerStatusErrorArray
                    thenDo:doAfterWait];
    
    else
        [self waitResource:urlServer
             withUrlParams:nil
                 insideKey:@"server"
                  forField:@"status"
              toEqualValue:statusServer
             orErrorValues:IOStackServerStatusErrorArray
                    thenDo:doAfterWait];
}


#pragma mark - IPs management
- ( void ) listIPsForServerWithID:( NSString * ) uidServer
                           thenDo:( void ( ^ ) ( NSArray * dicPrivateIPs, NSArray * dicPublicIPs, id idFullResponse ) ) doAfterList
{
    NSString * urlServer = [NSString stringWithFormat:@"%@/%@/%@", COMPUTEV2_1_SERVER_URN, uidServer, COMPUTEV2_1_IP_URN ];
    [self readResource:urlServer
            withHeader:nil
          andUrlParams:nil
             insideKey:@"addresses"
                thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable dataResponse)
    {
        NSMutableArray * arrPrivateIPs = [NSMutableArray array];
        NSMutableArray * arrPublicIPs = [NSMutableArray array];
        
        if( [dicObjectFound valueForKey:@"private"] )
            [arrPrivateIPs addObject:[dicObjectFound valueForKey:@"private"]];

        if( [dicObjectFound valueForKey:@"public"] )
            [arrPublicIPs addObject:[dicObjectFound valueForKey:@"public"]];

        for( NSString * currentAddressNetworkLabel in dicObjectFound )
        {
            if( [currentAddressNetworkLabel isEqualToString:@"private"] ||
                [currentAddressNetworkLabel isEqualToString:@"public"] )
                break;
            
            NSDictionary * dicAddressDetail = [dicObjectFound valueForKey:currentAddressNetworkLabel];
            
            if( [currentAddressNetworkLabel containsString:@"LAN"] && [dicAddressDetail valueForKey:@"addr"])
                [arrPrivateIPs addObject:[dicAddressDetail valueForKey:@"addr"]];

            if( [currentAddressNetworkLabel containsString:@"WAN"] && [dicAddressDetail valueForKey:@"addr"])
                [arrPublicIPs addObject:[dicAddressDetail valueForKey:@"addr"]];
        }
        
        if( doAfterList != nil )
            doAfterList( arrPrivateIPs, arrPublicIPs, dataResponse );
    }];
}

- ( void ) listIPFromPoolWithStatus:( NSString * ) statusIP
                  excludingFixedIPs:( BOOL ) bNoFixedIPs
                             thenDo:( void ( ^ ) ( NSDictionary * dicIPsFromPool, id idFullResponse ) ) doAfterList
{
    [self listResource:COMPUTEV2_1_FLOATINGIP_URN
            withHeader:nil
          andUrlParams:nil
             insideKey:@"floating_ips"
                thenDo:^(NSArray * _Nullable arrFound, id  _Nullable dataResponse)
    {
        NSMutableDictionary * dicIPs = [NSMutableDictionary dictionary];
        for( NSDictionary * currentIP in arrFound )
        {
            if( ( !bNoFixedIPs || ( currentIP[ @"fixed_ip"] == nil ) ) &&
                    ( statusIP == nil || [currentIP[ @"status" ] isEqualToString:statusIP] )  )
            {
                NSMutableDictionary * dicCurrentIPValues = [NSMutableDictionary dictionary];
                
                if( currentIP[ @"router_id" ] != nil )
                    dicCurrentIPValues[ @"uidRouter" ]          = currentIP[ @"router_id" ];
                if( currentIP[ @"tenant_id" ] != nil )
                    dicCurrentIPValues[ @"uidTenant" ]          = currentIP[ @"tenant_id" ];
                if( currentIP[ @"floating_network_id" ] != nil )
                    dicCurrentIPValues[ @"uidFloatingNetwork" ] = currentIP[ @"floating_network_id" ];
                if( currentIP[ @"port_id" ] != nil )
                    dicCurrentIPValues[ @"uidPort" ]            = currentIP[ @"port_id" ];
                if( currentIP[ @"fixed_ip" ] != nil )
                    dicCurrentIPValues[ @"ipAddressFixed" ]     = currentIP[ @"fixed_ip" ];
                if( currentIP[ @"ip" ] != nil )
                    dicCurrentIPValues[ @"ipAddressFloating" ]  = currentIP[ @"ip" ];
                if( currentIP[ @"status" ] != nil )
                    dicCurrentIPValues[ @"status" ]             = currentIP[ @"status" ];

                [dicIPs setValue:dicCurrentIPValues
                          forKey:currentIP[ @"id" ]];

            }
        }
        
        if( doAfterList != nil )
            doAfterList( dicIPs, dataResponse );
    }];
}

- ( void ) createIPAllocationFromPool:( NSString * ) strPoolName
                               thenDo:( void ( ^ ) ( IOStackComputeIPAllocationV2_1 * fipCreated, id idFullResponse ) ) doAfterCreate
{
    NSDictionary * dicUrlParams = nil;
    
    if( strPoolName != nil )
        dicUrlParams = @{@"pool": strPoolName };
    
    [self createResource:COMPUTEV2_1_FLOATINGIP_URN
              withHeader:nil
            andUrlParams:dicUrlParams
                  thenDo:^(NSDictionary * _Nullable dicResponseHeaders, id  _Nullable idFullResponse)
    {
        IOStackComputeIPAllocationV2_1 * fipCreated = [IOStackComputeIPAllocationV2_1 initFromAPIResponse:[idFullResponse objectForKey:@"floating_ip"]];
        
        if( doAfterCreate != nil )
        {
            if( strPoolName == nil ||
               [fipCreated.namePool isEqualToString:strPoolName] )
                doAfterCreate( fipCreated, idFullResponse );
            
            else
                doAfterCreate( nil, nil );
        }
    }];
}

- ( void ) deleteIPAllocationWithID:( NSString * ) uidFloatingIPAllocationID
                             thenDo:( void ( ^ ) ( bool isDeleted ) ) doAfterDelete
{
    NSString * urlFloatingIPAllocation = [NSString stringWithFormat:@"%@/%@", COMPUTEV2_1_FLOATINGIP_URN, uidFloatingIPAllocationID];
    [self deleteResource:urlFloatingIPAllocation
              withHeader:nil
                  thenDo:^(NSDictionary * _Nullable dicResults, id  _Nullable idFullResponse)
    {
        if( doAfterDelete != nil )
            doAfterDelete( ( idFullResponse == nil ) ||
                          ( idFullResponse[ @"response" ] == nil ) ||
                          ( [idFullResponse[ @"response" ] isEqualToString:@""] ) );
    }];
}

- ( void ) addIPToServerWithID:( NSString * ) uidServer
        usingFloatingIPAddress:( NSString * ) ipAddress
                        thenDo:( void ( ^ ) ( BOOL isAssociated, id idFullResponse ) ) doAfterAdd
{
    NSString * urlActionServer = [NSString stringWithFormat:@"%@/%@/%@", COMPUTEV2_1_SERVER_URN, uidServer, COMPUTEV2_1_ACTION_URN ];
    NSDictionary * dicUrlParams = nil;
    
    if( ipAddress != nil )
        dicUrlParams = @{ @"addFloatingIp": @{ @"address": ipAddress } };
    
    [self createResource:urlActionServer
              withHeader:nil
            andUrlParams:dicUrlParams
                  thenDo:^(NSDictionary * _Nullable dicResponseHeaders, id  _Nullable idFullResponse)
     {
         if( doAfterAdd != nil )
             doAfterAdd( YES, idFullResponse );
     }];
}

- ( void ) addIPToServerWithID:( NSString * ) uidServer
        usingFixedIPNetworkUID:( NSString * ) uidNetwork
                        thenDo:( void ( ^ ) ( BOOL isAssociated, id idFullResponse ) ) doAfterAdd
{
    NSString * urlActionServer = [NSString stringWithFormat:@"%@/%@/%@", COMPUTEV2_1_SERVER_URN, uidServer, COMPUTEV2_1_ACTION_URN ];
    NSDictionary * dicUrlParams = @{ @"addFixedIp": @{ @"networkId" : uidNetwork } };
    
    [self createResource:urlActionServer
              withHeader:nil
            andUrlParams:dicUrlParams
                  thenDo:^(NSDictionary * _Nullable dicResponseHeaders, id  _Nullable idFullResponse)
     {
         
         if( doAfterAdd != nil )
             doAfterAdd( YES, idFullResponse );
     }];
}


#pragma mark - Keypair management
- ( void ) listKeypairsThenDo:( void ( ^ ) ( NSDictionary * dicKeypairs, id idFullResponse ) ) doAfterList
{
    [self listResource:COMPUTEV2_1_KEYPAIR_URN
            withHeader:nil
          andUrlParams:nil
             insideKey:@"keypairs"
                thenDo:^(NSArray * _Nullable arrFound, id  _Nullable dataResponse)
    {
        if( doAfterList != nil )
            doAfterList( [IOStackComputeKeypairV2_1 parseFromAPIResponse:arrFound], dataResponse );
    }];
}

- ( void ) createKeypairWithName:( NSString * ) strKeypairName
                    andPublicKey:( NSString * ) strPublicKey
                          thenDo:( void ( ^ ) ( IOStackComputeKeypairV2_1 * keyCreated, id idFullResponse ) ) doAfterCreate
{
    NSDictionary * dicUrlParams = nil;
    
    if( strPublicKey != nil )
        dicUrlParams = @{@"keypair": @{ @"name": strKeypairName, @"public_key" : strPublicKey } };
    
    else
        dicUrlParams = @{@"keypair": @{ @"name": strKeypairName} };
    
    [self createResource:COMPUTEV2_1_KEYPAIR_URN
              withHeader:nil
            andUrlParams:dicUrlParams
                  thenDo:^(NSDictionary * _Nullable dicResponseHeaders, id  _Nullable idFullResponse)
    {
        IOStackComputeKeypairV2_1 * keyCreated = [IOStackComputeKeypairV2_1 initFromAPIResponse:[idFullResponse objectForKey:@"keypair"]];
        
        if( [keyCreated.uniqueID isEqualToString:strKeypairName] &&
           doAfterCreate != nil )
            doAfterCreate( keyCreated, idFullResponse );
    }];
}


- ( void ) createKeypairWithName:( NSString * ) strKeypairName
            andPublicKeyFilePath:( NSString * ) strPublicKeyCompleteFilePath
                          thenDo:( void ( ^ ) ( IOStackComputeKeypairV2_1 * keyCreated, id idFullResponse ) ) doAfterCreate
{
    NSError * errRead;
    NSString * strPublicKeyData     = [NSString stringWithContentsOfFile:strPublicKeyCompleteFilePath
                                                                encoding:NSUTF8StringEncoding
                                                                   error:&errRead];
    if( strPublicKeyData != nil )
        [self createKeypairWithName:strKeypairName
                       andPublicKey:strPublicKeyData
                             thenDo:doAfterCreate];

    else
        doAfterCreate( nil, nil );
}

- ( void ) deleteKeypairWithName:( NSString * ) strKeypairName
                          thenDo:( void ( ^ ) ( bool isDeleted ) ) doAfterDelete
{
    NSString * urlKeypair = [NSString stringWithFormat:@"%@/%@", COMPUTEV2_1_KEYPAIR_URN, strKeypairName];
    
    [self deleteResource:urlKeypair
              withHeader:nil
                  thenDo:^(NSDictionary * _Nullable dicResults, id  _Nullable idFullResponse)
    {
        if( doAfterDelete != nil )
            doAfterDelete( ( idFullResponse == nil ) ||
                          ( idFullResponse[ @"response" ] == nil ) ||
                          ( [idFullResponse[ @"response" ] isEqualToString:@""] ) );
    }];
}


#pragma mark - Action management
- ( void ) listActionsForServer:( NSString * ) uidServer
                         thenDo:( void ( ^ ) ( NSArray * arrServerActions, id idFullResponse ) ) doAfterList
{
    NSString * urlServerAction = [NSString stringWithFormat:@"%@/%@/%@", COMPUTEV2_1_SERVER_URN, uidServer, COMPUTEV2_1_INSTANCEACTION_URN ];
    [self listResource:urlServerAction
            withHeader:nil
          andUrlParams:nil
             insideKey:@"instanceActions"
                thenDo:^(NSArray * _Nullable arrFound, id  _Nullable dataResponse)
    {
        if( doAfterList != nil )
        {
            if( [arrFound count] > 0 )
                doAfterList( arrFound, dataResponse );
            else
                doAfterList( nil, dataResponse );
        }
    }];
}


#pragma mark - Security group management
- ( void ) listSecurityGroupsThenDo:( void ( ^ ) ( NSDictionary * dicSecurityGroups, id idFullResponse ) ) doAfterList
{
    [self listResource:COMPUTEV2_1_SECURITYGROUP_URN
            withHeader:nil
          andUrlParams:nil
             insideKey:@"security_groups"
                thenDo:^(NSArray * _Nullable arrFound, id  _Nullable dataResponse)
    {
        if( doAfterList != nil )
            doAfterList( [IOStackComputeSecurityGroupV2_1 parseFromAPIResponse:arrFound], dataResponse );
    }];
}

- ( void ) createSecurityGroupWithName:( NSString * ) strSecurityGroupName
                        andDescription:( NSString * ) strSecurityGroupDescription
                                thenDo:( void ( ^ ) ( IOStackComputeSecurityGroupV2_1 * secCreated, id idFullResponse ) ) doAfterCreate
{
    NSDictionary * dicUrlParams = nil;
    
    if( strSecurityGroupDescription != nil )
        dicUrlParams = @{@"security_group": @{ @"name": strSecurityGroupName, @"description" : strSecurityGroupDescription } };
    
    else
        dicUrlParams = @{@"security_group": @{ @"name": strSecurityGroupName, @"description" : @"default" } };
    
    [self createResource:COMPUTEV2_1_SECURITYGROUP_URN
              withHeader:nil
            andUrlParams:dicUrlParams
                  thenDo:^(NSDictionary * _Nullable dicResponseHeaders, id _Nullable idFullResponse)
    {
        IOStackComputeSecurityGroupV2_1 * secCreated = [IOStackComputeSecurityGroupV2_1 initFromAPIResponse:[idFullResponse objectForKey:@"security_group"]];
        
        if( secCreated.uniqueID != nil &&
            doAfterCreate != nil )
            doAfterCreate( secCreated, idFullResponse );
    }];
}

- ( void ) deleteSecurityGroupWithID:( NSString * ) uidSecurityGroup
                              thenDo:( void ( ^ ) ( bool isDeleted ) ) doAfterDelete
{
    NSString * urlSecurityGroup = [NSString stringWithFormat:@"%@/%@", COMPUTEV2_1_SECURITYGROUP_URN, uidSecurityGroup];
    
    [self deleteResource:urlSecurityGroup
              withHeader:nil
                  thenDo:^(NSDictionary * _Nullable dicResults, id  _Nullable idFullResponse)
    {
        if( doAfterDelete != nil )
            doAfterDelete( ( idFullResponse == nil ) ||
                                ( idFullResponse[ @"response" ] == nil ) ||
                                ( [idFullResponse[ @"response" ] isEqualToString:@""] ) );
    }];
}

- ( void ) addRuleToSecurityGroupWithID:( NSString * ) uidSecurityGroupID
                           withProtocol:( NSString * ) strIPProtocolName
                               FromPort:( NSNumber * ) nPortFrom
                                 ToPort:( NSNumber * ) nPortTo
                                AndCIDR:( NSString * ) strCIDR
                                 thenDo:( void ( ^ ) ( IOStackComputeSecurityGroupRuleV2_1 * ruleCreated, id idFullResponse ) ) doAfterCreate
{
    NSDictionary * dicUrlParams = nil;
    
    if( uidSecurityGroupID == nil )
        return;
    
    if( nPortTo != nil && strCIDR != nil )
        dicUrlParams = @{@"security_group_rule": @{
                                 @"parent_group_id": uidSecurityGroupID,
                                 @"ip_protocol": strIPProtocolName,
                                 @"from_port": [nPortFrom stringValue],
                                 @"to_port" : [nPortTo stringValue],
                                 @"cidr": strCIDR
                             } };
    else if( nPortTo != nil )
        dicUrlParams = @{@"security_group_rule": @{
                                 @"parent_group_id": uidSecurityGroupID,
                                 @"ip_protocol": strIPProtocolName,
                                 @"from_port": [nPortFrom stringValue],
                                 @"to_port" : [nPortTo stringValue],
                                 @"cidr": @"0.0.0.0/0"
                                 } };
    
    else
        dicUrlParams = @{@"security_group_rule": @{
                                 @"parent_group_id": uidSecurityGroupID,
                                 @"ip_protocol": strIPProtocolName,
                                 @"from_port": [nPortFrom stringValue],
                                 @"to_port" : [nPortFrom stringValue],
                                 @"cidr": strCIDR
                                 } };
        
    [self createResource:COMPUTEV2_1_SECURITYGROUPRULES_URN
              withHeader:nil
            andUrlParams:dicUrlParams
                  thenDo:^(NSDictionary * _Nullable dicResponseHeaders, id  _Nullable idFullResponse)
    {
        if( doAfterCreate != nil )
            doAfterCreate( [IOStackComputeSecurityGroupRuleV2_1 initFromAPIResponse:[idFullResponse objectForKey:@"security_group_rule"]], idFullResponse );
    }];
}

- ( void ) deleteSecurityGroupRuleWithID:( NSString * ) uidSecurityGroupRule
                                  thenDo:( void ( ^ ) ( bool isDeleted ) ) doAfterDelete
{
    NSString * urlSecurityGroup = [NSString stringWithFormat:@"%@/%@", COMPUTEV2_1_SECURITYGROUPRULES_URN, uidSecurityGroupRule];
    
    [self deleteResource:urlSecurityGroup
              withHeader:nil
                  thenDo:^(NSDictionary * _Nullable dicResults, id  _Nullable idFullResponse)
    {
        if( doAfterDelete != nil )
            doAfterDelete( ( idFullResponse == nil ) ||
                          ( idFullResponse[ @"response" ] == nil ) ||
                          ( [idFullResponse[ @"response" ] isEqualToString:@""] ) );
    }];
}

#pragma mark - Networks management
- ( void ) listNetworksThenDo:( void ( ^ ) ( NSDictionary * dicNetworks, id idFullResponse ) ) doAfterList
{
    [self listResource:COMPUTEV2_1_NETWORKS_URN
            withHeader:nil
          andUrlParams:nil
             insideKey:@"networks"
                thenDo:^(NSArray * _Nullable arrFound, id  _Nullable dataResponse)
     {
         if( doAfterList != nil )
             doAfterList( [IOStackComputeNetworkV2_1 parseFromAPIResponse:arrFound], dataResponse );
     }];
}

- ( void ) createNetworkWithLabel:( NSString * ) nameNetwork
                          andCIDR:( NSString * ) ipCIDR
                           andMTU:( NSNumber * ) nMTU
                    andDHCPServer:( NSString * ) ipDHCPServer
                       startingAt:( NSString * ) ipStartingIP
                         endingAt:( NSString * ) ipEndingIP
                 isSharingAddress:( BOOL ) isSharing
                                thenDo:( void ( ^ ) ( IOStackComputeNetworkV2_1 * networkCreated, id idFullResponse ) ) doAfterCreate
{
    NSMutableDictionary * mdicValues = [NSMutableDictionary dictionaryWithObject:nameNetwork
                                                                          forKey:@"label"];
    
    if( ipCIDR != nil )
        mdicValues[ @"cidr" ] = ipCIDR;
    
    if( nMTU != nil )
        mdicValues[ @"mtu" ] = nMTU;
    
    mdicValues[ @"enable_dhcp" ] = [NSNumber numberWithBool:NO];
    if( nMTU != nil )
    {
        mdicValues[ @"dhcp_server" ] = ipDHCPServer;
        mdicValues[ @"enable_dhcp" ] = [NSNumber numberWithBool:YES];
    }
    
    mdicValues[ @"share_address" ] = [NSNumber numberWithBool:NO];
    if( isSharing )
        mdicValues[ @"share_address" ] = [NSNumber numberWithBool:YES];
    
    if( ipStartingIP != nil )
        mdicValues[ @"allowed_start" ] = ipStartingIP;
    
    if( ipEndingIP != nil )
        mdicValues[ @"allowed_end" ] = ipEndingIP;
    
    [self createResource:COMPUTEV2_1_NETWORKS_URN
              withHeader:nil
            andUrlParams:@{ @"network" : mdicValues }
                  thenDo:^(NSDictionary * _Nullable dicResponseHeaders, id _Nullable idFullResponse)
     {
         IOStackComputeNetworkV2_1 * networkCreated = [IOStackComputeNetworkV2_1 initFromAPIResponse:[idFullResponse objectForKey:@"security_group"]];
         
         if( networkCreated.uniqueID != nil &&
            doAfterCreate != nil )
             doAfterCreate( networkCreated, idFullResponse );
     }];
}

- ( void ) getDetailsForNetworkWithID:( NSString * ) uidNetwork
                               thenDo:( void ( ^ ) ( IOStackComputeNetworkV2_1 * networkDetails, id idFullResponse ) ) doAfterGet
{
    NSString * urlNetwork = [NSString stringWithFormat:@"%@/%@", COMPUTEV2_1_NETWORKS_URN, uidNetwork];
    
    [self readResource:urlNetwork
            withHeader:nil
          andUrlParams:nil
             insideKey:@"networks"
                thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable dataResponse)
     {
         if( doAfterGet != nil )
             doAfterGet( [IOStackComputeNetworkV2_1 initFromAPIResponse:dicObjectFound], dataResponse );
     }];
}

- ( void ) addNetworkWithID:( NSString * ) uidNetwork
                     thenDo:( void ( ^ ) ( BOOL isAdded, id idFullResponse ) ) doAfterAdd
{
    NSString * urlNetworkAdd = [NSString stringWithFormat:@"%@/%@", COMPUTEV2_1_NETWORKS_URN, COMPUTEV2_1_NETWORKADD_URN];
    [self createResource:urlNetworkAdd
              withHeader:nil
            andUrlParams:@{ @"id" : uidNetwork }
                  thenDo:^(NSDictionary * _Nullable dicResponseHeaders, id _Nullable idFullResponse)
     {
         if( doAfterAdd != nil )
             doAfterAdd( ( idFullResponse == nil ) ||
                        ( idFullResponse[ @"response" ] == nil ) ||
                        ( [idFullResponse[ @"response" ] isEqualToString:@""] ), idFullResponse );
     }];
}

- ( void ) deleteNetworkWithID:( NSString * ) uidNetwork
                              thenDo:( void ( ^ ) ( bool isDeleted ) ) doAfterDelete
{
    NSString * urlNetwork = [NSString stringWithFormat:@"%@/%@", COMPUTEV2_1_NETWORKS_URN, uidNetwork];
    
    [self deleteResource:urlNetwork
              withHeader:nil
                  thenDo:^(NSDictionary * _Nullable dicResults, id  _Nullable idFullResponse)
     {
         if( doAfterDelete != nil )
             doAfterDelete( ( idFullResponse == nil ) ||
                           ( idFullResponse[ @"response" ] == nil ) ||
                           ( [idFullResponse[ @"response" ] isEqualToString:@""] ) );
     }];
}

- ( void ) findIDForNetworkWithLabelContaining:( NSString * ) strNetworkLabelPart
                                    thenDo:( void ( ^ ) ( NSArray * arrNetworksWithLabelContaining, id idFullResponse ) ) doAfterFind
{
    [self listNetworksThenDo:^(NSDictionary * dicNetworks, id idFullResponse) {
        NSMutableArray * marrNetworksLabelContaining = [NSMutableArray array];
        
        for( IOStackComputeNetworkV2_1 * currentNetwork in dicNetworks )
        {
            if( [currentNetwork.labelNetwork containsString:strNetworkLabelPart] )
                [marrNetworksLabelContaining addObject:currentNetwork];
        }
        
        if( doAfterFind != nil )
            doAfterFind( marrNetworksLabelContaining, idFullResponse );
    }];
}


- ( void ) findNetworksWithLabelContaining:( NSString * ) strNetworkLabelPart
                                    thenDo:( void ( ^ ) ( NSArray * arrNetworksWithLabelContaining, id idFullResponse ) ) doAfterFind
{
    [self listNetworksThenDo:^(NSDictionary * dicNetworks, id idFullResponse) {
        NSArray * arrNetworkWithLabelContaining = [IOStackComputeNetworkV2_1 findIDsForNetworks:dicNetworks
                                                                            withLabelContaining:strNetworkLabelPart];
        if( doAfterFind != nil )
            doAfterFind( arrNetworkWithLabelContaining, idFullResponse );
    }];
}

- ( void ) findNetworksWithExactLabel:( NSString * ) strNetworkLabel
                               thenDo:( void ( ^ ) ( NSArray * arrNetworksWithLabelContaining, id idFullResponse ) ) doAfterFind
{
    [self listNetworksThenDo:^(NSDictionary * dicNetworks, id idFullResponse) {
        NSArray * arrNetworkWithLabelContaining = [IOStackComputeNetworkV2_1 findIDsForNetworks:dicNetworks
                                                                            withExactLabel:strNetworkLabel];
        if( doAfterFind != nil )
            doAfterFind( arrNetworkWithLabelContaining, idFullResponse );
    }];
}




@end
