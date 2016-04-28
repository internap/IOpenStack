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
    [self serviceGET:COMPUTEV2_1_FLAVOR_URN
          withParams:nil
    onServiceSuccess:^( NSString * uidServiceTask, id responseObject, NSDictionary * dicResponseHeaders ) {
        if( ![responseObject isKindOfClass:[NSDictionary class]] )
            [NSException exceptionWithName:[NSString stringWithFormat:@"Method %@ bad return", COMPUTEV2_1_FLAVOR_URN]
                                    reason:@"response object is not a NSDictionnary"
                                  userInfo:@{@"tenant_id": currentProjectOrTenantID,
                                             @"returnedValue": responseObject}];
        NSDictionary * dicResponse     = responseObject;
        
        NSArray * arrFlavorsFound = [dicResponse valueForKey:@"flavors"];
        if( ![arrFlavorsFound isKindOfClass:[NSArray class]] )
            [NSException exceptionWithName:[NSString stringWithFormat:@"Method %@ bad return", COMPUTEV2_1_FLAVOR_URN]
                                    reason:@"flavors object is not a NSArray"
                                  userInfo:@{@"tenant_id": currentProjectOrTenantID,
                                             @"returnedValue": responseObject}];
        
        if( doAfterList != nil )
            doAfterList( [IOStackServerFlavorsV2_1 parseFromAPIResponse:arrFlavorsFound] );
    }
    onServiceFailure:^( NSString * uidServiceTask, NSError * error, NSUInteger nHTTPStatus ) {
        NSLog( @"call failed : %@ - task %@", error, uidServiceTask );
        
        if( doAfterList != nil )
            doAfterList( nil );
    }];
}


#pragma mark - Server management
- ( void ) listServersThenDo:( void ( ^ ) ( NSDictionary * dicServers, id idFullResponse ) ) doAfterList
{
    [self serviceGET:COMPUTEV2_1_SERVER_URN
          withParams:nil
    onServiceSuccess:^( NSString * uidServiceTask, id responseObject, NSDictionary * dicResponseHeaders ) {
        if( ![responseObject isKindOfClass:[NSDictionary class]] )
            [NSException exceptionWithName:[NSString stringWithFormat:@"Method %@ bad return", COMPUTEV2_1_SERVER_URN]
                                    reason:@"Return value is not a NSDictionnary"
                                  userInfo:@{@"returnedValue": responseObject}];
        
        NSDictionary * dicResponse     = responseObject;
        if( ![[dicResponse objectForKey:@"servers"] isKindOfClass:[NSArray class]] )
            [NSException exceptionWithName:[NSString stringWithFormat:@"Method %@ bad return", COMPUTEV2_1_SERVER_URN]
                                    reason:@"Access object is not a NSDictionnary"
                                  userInfo:@{@"returnedValue": responseObject}];
        
        if( doAfterList != nil )
            doAfterList( [IOStackServerObjectV2_1 parseFromAPIResponse:[dicResponse objectForKey:@"servers"]], dicResponse );
    }
    onServiceFailure:^( NSString * uidServiceTask, NSError * error, NSUInteger nHTTPStatus ) {
        NSLog( @"token not valid : %@", error );
        
        if( doAfterList != nil )
            doAfterList( nil, nil );
    }];
}

- ( void ) createServerWithUrlParams:( NSDictionary * ) dicUrlParams
                       andServerName:( NSString * ) strServerName
                   waitUntilIsActive:( BOOL ) bWaitActive
                              thenDo:( void ( ^ ) ( IOStackServerObjectV2_1 * serverCreated, NSDictionary * dicFullResponse ) ) doAfterCreate
{
    [self servicePOST:COMPUTEV2_1_SERVER_URN
           withParams:dicUrlParams
     onServiceSuccess:^( NSString * uidServiceTask, id responseObject, NSDictionary * dicResponseHeaders ) {
                     if( ![responseObject isKindOfClass:[NSDictionary class]] )
                         [NSException exceptionWithName:[NSString stringWithFormat:@"Method %@ bad return", COMPUTEV2_1_SERVER_URN]
                                                 reason:@"Return value is not a NSDictionnary"
                                               userInfo:@{@"urlParams": dicUrlParams, @"returnedValue": responseObject}];
                     
                     NSDictionary * dicResponse     = responseObject;
                     if( ![[dicResponse objectForKey:@"server"] isKindOfClass:[NSDictionary class]] )
                         [NSException exceptionWithName:[NSString stringWithFormat:@"Method %@ bad return", COMPUTEV2_1_SERVER_URN]
                                                 reason:@"Access object is not a NSDictionnary"
                                               userInfo:@{@"urlParams": dicUrlParams, @"returnedValue": responseObject}];
                     
                     NSMutableDictionary * dicServerResultWithName = [NSMutableDictionary dictionaryWithDictionary:[dicResponse objectForKey:@"server"]];
                     [dicServerResultWithName setObject:strServerName
                                                 forKey:@"name"];
                     IOStackServerObjectV2_1 * newServer = [IOStackServerObjectV2_1 initFromAPIResponse:dicServerResultWithName];
                     
                     if( bWaitActive )
                         [self waitServerWithID:newServer.uniqueID
                                      forStatus:IOStackServerStatusActive
                                         thenDo:^( bool isWithStatus )
                          {
                              if( doAfterCreate != nil )
                              {
                                  if( isWithStatus )
                                      doAfterCreate( newServer, dicResponse );
                                  
                                  else
                                  {
                                      NSLog( @"Creation failed" );
                                      doAfterCreate( nil, nil );
                                  }
                              }
                          }];
                     
                     else
                         doAfterCreate( newServer, dicResponse );
                 }
     onServiceFailure:^( NSString * uidServiceTask, NSError * error, NSUInteger nHTTPStatus ) {
                     NSLog( @"token not valid : %@", error );
                     
                     if( doAfterCreate != nil )
                         doAfterCreate( nil, nil );
                 }];
}

- ( void ) createServerWithName:( NSString * ) strServerName
                    andFlavorID:( NSString * ) uuidFlavor
                     andImageID:( NSString * ) uuidImage
              waitUntilIsActive:( BOOL ) bWaitActive
                         thenDo:( void ( ^ ) ( IOStackServerObjectV2_1 * serverCreated, NSDictionary * dicFullResponse ) ) doAfterCreate
{
    NSDictionary * dicParams = @{@"server": @{
                                         @"name": strServerName,
                                         @"imageRef" : uuidImage,
                                         @"flavorRef": uuidFlavor
                                         } };
    
    [self createServerWithUrlParams:dicParams
                      andServerName:strServerName
                  waitUntilIsActive:bWaitActive
                             thenDo:doAfterCreate];
}

- ( void ) createServerWithName:( NSString * ) strServerName
                    andFlavorID:( NSString * ) uuidFlavor
                     andImageID:( NSString * ) uuidImage
                         thenDo:( void ( ^ ) ( IOStackServerObjectV2_1 * serverCreated, NSDictionary * dicFullResponse ) ) doAfterCreate
{
    [self createServerWithName:strServerName
                   andFlavorID:uuidFlavor
                    andImageID:uuidImage
             waitUntilIsActive:NO
                        thenDo:doAfterCreate];
}

- ( void ) createServerWithName:( NSString * ) strServerName
                    andFlavorID:( NSString * ) uuidFlavor
                     andImageID:( NSString * ) uuidImage
                 andKeypairName:( NSString * ) strKeypairName
         andSecurityGroupsNames:( NSArray * ) arrSecurityGroupsNames
              waitUntilIsActive:( BOOL ) bWaitActive
                         thenDo:( void ( ^ ) ( IOStackServerObjectV2_1 * serverCreated, NSDictionary * dicFullResponse ) ) doAfterCreate
{
    NSDictionary * dicParams = nil;
    
  
    if( arrSecurityGroupsNames != nil &&
        [arrSecurityGroupsNames count] > 0 )
    {
        NSArray * arrSecurityGroupNamesObjects = [IOStackServerSecurityGroupV2_1 createSecurityGroupNameArrayForAPIFromNameArray:arrSecurityGroupsNames];
        if( arrSecurityGroupNamesObjects == nil )
        {
            if( doAfterCreate != nil )
                doAfterCreate( nil, nil );
            
            return;
        }
        
        dicParams = @{@"server":
                          @{
                              @"name": strServerName,
                              @"imageRef" : uuidImage,
                              @"flavorRef": uuidFlavor,
                              @"key_name": strKeypairName,
                              @"security_groups": arrSecurityGroupNamesObjects
                              }
                      };
    }
    else
        
        dicParams = @{@"server":
                          @{
                              @"name": strServerName,
                              @"imageRef" : uuidImage,
                              @"flavorRef": uuidFlavor,
                              @"key_name": strKeypairName
                              }
                      };
    
    [self createServerWithUrlParams:dicParams
                      andServerName:strServerName
                  waitUntilIsActive:bWaitActive
                             thenDo:doAfterCreate];
}

- ( void ) createServerWithName:( NSString * ) strServerName
                    andFlavorID:( NSString * ) uuidFlavor
                     andImageID:( NSString * ) uuidImage
                 andKeypairName:( NSString * ) strKeypairName
         andSecurityGroupsNames:( NSArray * ) arrSecurityGroupsNames
                         thenDo:( void ( ^ ) ( IOStackServerObjectV2_1 * serverCreated, NSDictionary * dicFullResponse ) ) doAfterCreate
{
    [self createServerWithName:strServerName
                   andFlavorID:uuidFlavor
                    andImageID:uuidImage
                andKeypairName:strKeypairName
        andSecurityGroupsNames:arrSecurityGroupsNames
             waitUntilIsActive:NO
                        thenDo:doAfterCreate];
}

- ( void ) createServerWithName:( NSString * ) strServerName
                    andFlavorID:( NSString * ) uuidFlavor
                     andImageID:( NSString * ) uuidImage
                 andKeypairName:( NSString * ) strKeypairName
                    andUserData:( NSString * ) strUserData
         andSecurityGroupsNames:( NSArray * ) arrSecurityGroupsNames
              waitUntilIsActive:( BOOL ) bWaitActive
                         thenDo:( void ( ^ ) ( IOStackServerObjectV2_1 * serverCreated, NSDictionary * dicFullResponse ) ) doAfterCreate
{
    NSDictionary * dicParams    = nil;
    NSData * dataUTF8User       = [strUserData dataUsingEncoding:NSUTF8StringEncoding];
    NSString * strBase64        = [dataUTF8User base64EncodedStringWithOptions:0];
    
    
    if( arrSecurityGroupsNames != nil &&
       [arrSecurityGroupsNames count] > 0 )
    {
        NSArray * arrSecurityGroupNamesObjects = [IOStackServerSecurityGroupV2_1 createSecurityGroupNameArrayForAPIFromNameArray:arrSecurityGroupsNames];
        if( arrSecurityGroupNamesObjects == nil )
        {
            if( doAfterCreate != nil )
                doAfterCreate( nil, nil );
            
            return;
        }
        
        dicParams = @{@"server":
                          @{
                              @"name": strServerName,
                              @"imageRef" : uuidImage,
                              @"flavorRef": uuidFlavor,
                              @"key_name": strKeypairName,
                              @"user_data" : strBase64,
                              @"security_groups": arrSecurityGroupNamesObjects
                              }
                      };
    }
    else
        
        dicParams = @{@"server":
                          @{
                              @"name": strServerName,
                              @"imageRef" : uuidImage,
                              @"flavorRef": uuidFlavor,
                              @"key_name": strKeypairName,
                              @"user_data" : strBase64
                              }
                      };
    
    [self createServerWithUrlParams:dicParams
                      andServerName:strServerName
                  waitUntilIsActive:bWaitActive
                             thenDo:doAfterCreate];
}

- ( void ) createServerWithName:( NSString * ) strServerName
                    andFlavorID:( NSString * ) uuidFlavor
                     andImageID:( NSString * ) uuidImage
                 andKeypairName:( NSString * ) strKeypairName
                    andUserData:( NSString * ) strUserData
         andSecurityGroupsNames:( NSArray * ) arrSecurityGroupsNames
                         thenDo:( void ( ^ ) ( IOStackServerObjectV2_1 * serverCreated, NSDictionary * dicFullResponse ) ) doAfterCreate
{
    [self createServerWithName:strServerName
                   andFlavorID:uuidFlavor
                    andImageID:uuidImage
                andKeypairName:strKeypairName
        andSecurityGroupsNames:arrSecurityGroupsNames
             waitUntilIsActive:NO
                        thenDo:doAfterCreate];
}

- ( void ) deleteServerWithID:( NSString * ) uidServer
           waitUntilIsDeleted:( BOOL ) bWaitDeleted
                       thenDo:( void ( ^ ) ( bool isDeleted, id idFullResponse ) ) doAfterDelete
{
    NSString * strServerURL = [NSString stringWithFormat:@"%@/%@", COMPUTEV2_1_SERVER_URN, uidServer];
    [self serviceDELETE:strServerURL
       onServiceSuccess:^( NSString * uidServiceTask, id responseObject, NSDictionary * dicResponseHeaders ) {
           if( bWaitDeleted)
               [self waitServerWithID:uidServer
                            forStatus:IOStackServerStatusDeleted
                               thenDo:^(bool isWithStatus) {
                                   if( doAfterDelete != nil )
                                       doAfterDelete( isWithStatus, responseObject );
                               }];
           else
               doAfterDelete( YES, responseObject );
       }
       onServiceFailure:^( NSString * uidServiceTask, NSError * error, NSUInteger nHTTPStatus ) {
           NSLog( @"token not valid : %@", error );
           
           if( doAfterDelete != nil )
               doAfterDelete( NO, nil );
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
                    thenDo:doAfterWait];
    
    else
        [self waitResource:urlServer
             withUrlParams:nil
                 insideKey:@"server"
                  forField:@"status"
              toEqualValue:statusServer
                    thenDo:doAfterWait];
}


#pragma mark - IPs management
- ( void ) listIPsForServerWithID:( NSString * ) uidServer
                           thenDo:( void ( ^ ) ( NSArray * dicPrivateIPs, NSArray * dicPublicIPs, id idFullResponse ) ) doAfterList
{
    NSString * strServerURL = [NSString stringWithFormat:@"%@/%@/%@", COMPUTEV2_1_SERVER_URN, uidServer, COMPUTEV2_1_IP_URN ];
    [self serviceGET:strServerURL
          withParams:nil
    onServiceSuccess:^( NSString * uidServiceTask, id responseObject, NSDictionary * dicResponseHeaders ) {
        if( ![responseObject isKindOfClass:[NSDictionary class]] )
            [NSException exceptionWithName:[NSString stringWithFormat:@"Method %@ bad return", COMPUTEV2_1_IP_URN]
                                    reason:@"Return value is not a NSDictionnary"
                                  userInfo:@{@"returnedValue": responseObject}];
        
        NSDictionary * dicResponse     = responseObject;
        
        if( ![[dicResponse objectForKey:@"addresses"] isKindOfClass:[NSDictionary class]] )
            [NSException exceptionWithName:[NSString stringWithFormat:@"Method %@ bad return", COMPUTEV2_1_IP_URN]
                                    reason:@"Access object is not a NSDictionnary"
                                  userInfo:@{@"returnedValue": responseObject}];
        NSDictionary * dicIPType = [dicResponse objectForKey:@"addresses"];
        
        if( ![[dicIPType objectForKey:@"private"] isKindOfClass:[NSArray class]] )
            [NSException exceptionWithName:[NSString stringWithFormat:@"Method %@ bad return", COMPUTEV2_1_IP_URN]
                                    reason:@"Access object is not a NSArray"
                                  userInfo:@{@"returnedValue": responseObject}];
        NSArray * arrPrivateIPs = [dicIPType valueForKey:@"private"];
        
        if( ![[dicIPType objectForKey:@"private"] isKindOfClass:[NSArray class]] )
            [NSException exceptionWithName:[NSString stringWithFormat:@"Method %@ bad return", COMPUTEV2_1_IP_URN]
                                    reason:@"Access object is not a NSArray"
                                  userInfo:@{@"returnedValue": responseObject}];
        NSArray * arrPublicIPs = [dicIPType valueForKey:@"public"];
        
        if( doAfterList != nil )
            doAfterList( arrPrivateIPs, arrPublicIPs, dicResponse );
    }
    onServiceFailure:^( NSString * uidServiceTask, NSError * error, NSUInteger nHTTPStatus ) {
        NSLog( @"token not valid : %@", error );
        
        if( doAfterList != nil )
            doAfterList( nil, nil, nil );
    }];
}

- ( void ) listIPFromPoolWithStatus:( NSString * ) statusIP
                  excludingFixedIPs:( BOOL ) bNoFixedIPs
                             thenDo:( void ( ^ ) ( NSDictionary * dicIPsFromPool, id idFullResponse ) ) doAfterList
{
    [self serviceGET:COMPUTEV2_1_FLOATINGIP_URN
          withParams:nil
    onServiceSuccess:^( NSString * uidServiceTask, id responseObject, NSDictionary * dicResponseHeaders ) {
        if( ![responseObject isKindOfClass:[NSDictionary class]] )
            [NSException exceptionWithName:[NSString stringWithFormat:@"Method %@ bad return", COMPUTEV2_1_IP_URN]
                                    reason:@"Return value is not a NSDictionnary"
                                  userInfo:@{@"returnedValue": responseObject}];
        
        NSDictionary * dicResponse     = responseObject;
        
        if( ![[dicResponse objectForKey:@"floatingips"] isKindOfClass:[NSArray class]] )
            [NSException exceptionWithName:[NSString stringWithFormat:@"Method %@ bad return", COMPUTEV2_1_IP_URN]
                                    reason:@"floatingips object is not a NSArray"
                                  userInfo:@{@"returnedValue": responseObject}];
        NSArray * arrIPs = [dicResponse objectForKey:@"floatingips"];
        
        NSMutableDictionary * dicIPs = [NSMutableDictionary dictionaryWithCapacity:1];
        for( NSDictionary * currentIP in arrIPs )
        {
            if( ( statusIP != nil && [currentIP[ @"status" ] isEqualToString:statusIP] ) &&
               ( ( currentIP[ @"fixed_ip_address"] == nil ) ||
                !bNoFixedIPs ) )
                [dicIPs setValue:@{
                                   @"uidRouter"         : currentIP[ @"router_id" ],
                                   @"uidTenant"         : currentIP[ @"tenant_id" ],
                                   @"uidFloatingNetwork" : currentIP[ @"floating_network_id" ],
                                   @"uidPort"           : currentIP[ @"port_id" ],
                                   @"ipAddressFixed"    : currentIP[ @"fixed_ip_address" ],
                                   @"ipAddressFloating" : currentIP[ @"floating_ip_address" ],
                                   @"status"            : currentIP[ @"status" ]
                                   }
                          forKey:currentIP[ @"id" ]];
        }
        
        if( doAfterList != nil )
            doAfterList( dicIPs, dicResponse );
    }
    onServiceFailure:^( NSString * uidServiceTask, NSError * error, NSUInteger nHTTPStatus ) {
        NSLog( @"token not valid : %@", error );
        
        if( doAfterList != nil )
            doAfterList( nil, nil );
    }];
}

- ( void ) createIPAllocationFromPool:( NSString * ) strPoolName
                               thenDo:( void ( ^ ) ( IOStackServerIPAllocationV2_1 * fipCreated, id idFullResponse ) ) doAfterCreate
{
    NSDictionary * dicUrlParams = nil;
    
    if( strPoolName != nil )
        dicUrlParams = @{@"pool": strPoolName };
    
    [self servicePOST:COMPUTEV2_1_FLOATINGIP_URN
           withParams:dicUrlParams
     onServiceSuccess:^( NSString * uidServiceTask, id responseObject, NSDictionary * dicResponseHeaders ) {
         if( ![responseObject isKindOfClass:[NSDictionary class]] )
             [NSException exceptionWithName:[NSString stringWithFormat:@"Method %@ bad return", COMPUTEV2_1_FLOATINGIP_URN]
                                     reason:@"Return value is not a NSDictionnary"
                                   userInfo:@{@"urlParams": dicUrlParams, @"returnedValue": responseObject}];
         
         NSDictionary * dicResponse     = responseObject;
         if( ![[dicResponse objectForKey:@"floating_ip"] isKindOfClass:[NSDictionary class]] )
             [NSException exceptionWithName:[NSString stringWithFormat:@"Method %@ bad return", COMPUTEV2_1_FLOATINGIP_URN]
                                     reason:@"floating_ip object is not a NSDictionnary"
                                   userInfo:@{@"urlParams": dicUrlParams, @"returnedValue": responseObject}];
         
         IOStackServerIPAllocationV2_1 * fipCreated = [IOStackServerIPAllocationV2_1 initFromAPIResponse:[dicResponse objectForKey:@"floating_ip"]];
         
         if( doAfterCreate != nil )
         {
             if( strPoolName == nil ||
                [fipCreated.namePool isEqualToString:strPoolName] )
                 doAfterCreate( fipCreated, dicResponse );
             
             else
                 doAfterCreate( nil, nil );
         }
     }
     onServiceFailure:^( NSString * uidServiceTask, NSError * error, NSUInteger nHTTPStatus ) {
         NSLog( @"token not valid : %@", error );
         
         if( doAfterCreate != nil )
             doAfterCreate( nil, nil );
     }];
}

- ( void ) deleteIPAllocationWithID:( NSString * ) uidFloatingIPAllocationID
                             thenDo:( void ( ^ ) ( bool isDeleted ) ) doAfterDelete
{
    NSString * strFloatingIPAllocationURL = [NSString stringWithFormat:@"%@/%@", COMPUTEV2_1_FLOATINGIP_URN, uidFloatingIPAllocationID];
    
    [self serviceDELETE:strFloatingIPAllocationURL
       onServiceSuccess:^( NSString * uidServiceTask, id responseObject, NSDictionary * dicResponseHeaders ) {
           
           if( doAfterDelete != nil )
               doAfterDelete( YES );
           
       }
       onServiceFailure:^( NSString * uidServiceTask, NSError * error, NSUInteger nHTTPStatus ) {
           NSLog( @"token not valid : %@", error );
           
           if( doAfterDelete != nil )
               doAfterDelete( NO );
       }];
}

- ( void ) addIPToServerWithID:( NSString * ) uidServer
        usingFloatingIPAddress:( NSString * ) ipAddress
                        thenDo:( void ( ^ ) ( BOOL isAssociated, id idFullResponse ) ) doAfterAdd
{
    NSString * strActionServerURL = [NSString stringWithFormat:@"%@/%@/%@", COMPUTEV2_1_SERVER_URN, uidServer, COMPUTEV2_1_ACTION_URN ];
    NSDictionary * dicUrlParams = nil;
    
    if( ipAddress != nil )
        dicUrlParams = @{ @"addFloatingIp": @{ @"address": ipAddress } };
    
    [self servicePOST:strActionServerURL
           withParams:dicUrlParams
     onServiceSuccess:^( NSString * uidServiceTask, id responseObject, NSDictionary * dicResponseHeaders ) {
         
         if( doAfterAdd != nil )
             doAfterAdd( YES, responseObject );
         
     }
     onServiceFailure:^( NSString * uidServiceTask, NSError * error, NSUInteger nHTTPStatus ) {
         NSLog( @"token not valid : %@", error );
         
         if( doAfterAdd != nil )
             doAfterAdd( NO, nil );
     }];
}

- ( void ) addIPToServerWithID:( NSString * ) uidServer
        usingFixedIPNetworkUID:( NSString * ) uidNetwork
                        thenDo:( void ( ^ ) ( BOOL isAssociated, id idFullResponse ) ) doAfterAdd
{
    NSString * strActionServerURL = [NSString stringWithFormat:@"%@/%@/%@", COMPUTEV2_1_SERVER_URN, uidServer, COMPUTEV2_1_ACTION_URN ];
    NSDictionary * dicUrlParams = @{ @"addFixedIp": @{ @"networkId" : uidNetwork } };
    
    [self servicePOST:strActionServerURL
           withParams:dicUrlParams
     onServiceSuccess:^( NSString * uidServiceTask, id responseObject, NSDictionary * dicResponseHeaders ) {
         
         if( doAfterAdd != nil )
             doAfterAdd( YES, responseObject );
         
     }
     onServiceFailure:^( NSString * uidServiceTask, NSError * error, NSUInteger nHTTPStatus ) {
         NSLog( @"token not valid : %@", error );
         
         if( doAfterAdd != nil )
             doAfterAdd( NO, nil );
     }];
}


#pragma mark - Keypair management
- ( void ) listKeypairsThenDo:( void ( ^ ) ( NSDictionary * dicKeypairs, id idFullResponse ) ) doAfterList
{
    [self serviceGET:COMPUTEV2_1_KEYPAIR_URN
          withParams:nil
    onServiceSuccess:^( NSString * uidServiceTask, id responseObject, NSDictionary * dicResponseHeaders ) {
        if( ![responseObject isKindOfClass:[NSDictionary class]] )
            [NSException exceptionWithName:[NSString stringWithFormat:@"Method %@ bad return", COMPUTEV2_1_KEYPAIR_URN]
                                    reason:@"Return value is not a NSDictionnary"
                                  userInfo:@{@"returnedValue": responseObject}];
        
        NSDictionary * dicResponse     = responseObject;
        if( ![[dicResponse objectForKey:@"keypairs"] isKindOfClass:[NSArray class]] )
            [NSException exceptionWithName:[NSString stringWithFormat:@"Method %@ bad return", COMPUTEV2_1_KEYPAIR_URN]
                                    reason:@"Access object is not a NSDictionnary"
                                  userInfo:@{@"returnedValue": responseObject}];
        
        if( doAfterList != nil )
            doAfterList( [IOStackServerKeypairV2_1 parseFromAPIResponse:[dicResponse objectForKey:@"keypairs"]], dicResponse );
    }
    onServiceFailure:^( NSString * uidServiceTask, NSError * error, NSUInteger nHTTPStatus ) {
        NSLog( @"token not valid : %@", error );
        
        if( doAfterList != nil )
            doAfterList( nil, nil );
    }];
}

- ( void ) createKeypairWithName:( NSString * ) strKeypairName
                    andPublicKey:( NSString * ) strPublicKey
                          thenDo:( void ( ^ ) ( IOStackServerKeypairV2_1 * keyCreated, id idFullResponse ) ) doAfterCreate
{
    NSDictionary * dicUrlParams = nil;
    
    if( strPublicKey != nil )
        dicUrlParams = @{@"keypair": @{ @"name": strKeypairName, @"public_key" : strPublicKey } };
    
    else
        dicUrlParams = @{@"keypair": @{ @"name": strKeypairName} };
    
    [self servicePOST:COMPUTEV2_1_KEYPAIR_URN
           withParams:dicUrlParams
     onServiceSuccess:^( NSString * uidServiceTask, id responseObject, NSDictionary * dicResponseHeaders ) {
         if( ![responseObject isKindOfClass:[NSDictionary class]] )
             [NSException exceptionWithName:[NSString stringWithFormat:@"Method %@ bad return", COMPUTEV2_1_KEYPAIR_URN]
                                     reason:@"Return value is not a NSDictionnary"
                                   userInfo:@{@"urlParams": dicUrlParams, @"returnedValue": responseObject}];
         
         NSDictionary * dicResponse     = responseObject;
         if( ![[dicResponse objectForKey:@"keypair"] isKindOfClass:[NSDictionary class]] )
             [NSException exceptionWithName:[NSString stringWithFormat:@"Method %@ bad return", COMPUTEV2_1_KEYPAIR_URN]
                                     reason:@"Access object is not a NSDictionnary"
                                   userInfo:@{@"urlParams": dicUrlParams, @"returnedValue": responseObject}];
         
         IOStackServerKeypairV2_1 * keyCreated = [IOStackServerKeypairV2_1 initFromAPIResponse:[dicResponse objectForKey:@"keypair"]];
         
         if( [keyCreated.uniqueID isEqualToString:strKeypairName] &&
            doAfterCreate != nil )
             doAfterCreate( keyCreated, dicResponse );
         
     }
     onServiceFailure:^( NSString * uidServiceTask, NSError * error, NSUInteger nHTTPStatus ) {
         NSLog( @"token not valid : %@", error );
         
         if( doAfterCreate != nil )
             doAfterCreate( nil, nil );
     }];
}


- ( void ) createKeypairWithName:( NSString * ) strKeypairName
            andPublicKeyFilePath:( NSString * ) strPublicKeyCompleteFilePath
                          thenDo:( void ( ^ ) ( IOStackServerKeypairV2_1 * keyCreated, id idFullResponse ) ) doAfterCreate
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
    NSString * strKeypairURL = [NSString stringWithFormat:@"%@/%@", COMPUTEV2_1_KEYPAIR_URN, strKeypairName];
    
    [self serviceDELETE:strKeypairURL
       onServiceSuccess:^( NSString * uidServiceTask, id responseObject, NSDictionary * dicResponseHeaders ) {
           
           if( doAfterDelete != nil )
               doAfterDelete( YES );
           
       }
       onServiceFailure:^( NSString * uidServiceTask, NSError * error, NSUInteger nHTTPStatus ) {
           NSLog( @"token not valid : %@", error );
           
           if( doAfterDelete != nil )
               doAfterDelete( NO );
       }];
}


#pragma mark - Action management
- ( void ) listActionsForServer:( NSString * ) uidServer
                         thenDo:( void ( ^ ) ( NSArray * arrServerActions, id idFullResponse ) ) doAfterList
{
    NSString * strActionServerURL = [NSString stringWithFormat:@"%@/%@/%@", COMPUTEV2_1_SERVER_URN, uidServer, COMPUTEV2_1_INSTANCEACTION_URN ];
    [self serviceGET:strActionServerURL
             withParams:nil
    onServiceSuccess:^( NSString * uidServiceTask, id responseObject, NSDictionary * dicResponseHeaders ) {
        if( ![responseObject isKindOfClass:[NSDictionary class]] )
            [NSException exceptionWithName:[NSString stringWithFormat:@"Method %@ bad return", COMPUTEV2_1_INSTANCEACTION_URN]
                                    reason:@"Return value is not a NSDictionnary"
                                  userInfo:@{@"server_id": uidServer, @"returnedValue": responseObject}];
        
        NSDictionary * dicResponse     = responseObject;
        if( ![[dicResponse objectForKey:@"instanceActions"] isKindOfClass:[NSArray class]] )
            [NSException exceptionWithName:[NSString stringWithFormat:@"Method %@ bad return", COMPUTEV2_1_INSTANCEACTION_URN]
                                    reason:@"instanceActions object is not a NSArray"
                                  userInfo:@{@"server_id": uidServer, @"returnedValue": responseObject}];
        
        NSArray * arrActions = [dicResponse objectForKey:@"instanceActions"];
        
        if( [arrActions count] > 0 &&
           doAfterList != nil )
            doAfterList( arrActions, dicResponse );
        
    }
    onServiceFailure:^( NSString * uidServiceTask, NSError * error, NSUInteger nHTTPStatus ) {
        NSLog( @"token not valid : %@", error );
        
        if( doAfterList != nil )
            doAfterList( nil, nil );
    }];
}


#pragma mark - Security group management
- ( void ) listSecurityGroupsThenDo:( void ( ^ ) ( NSDictionary * dicSecurityGroups, id idFullResponse ) ) doAfterList
{
    [self serviceGET:COMPUTEV2_1_SECURITYGROUP_URN
          withParams:nil
    onServiceSuccess:^( NSString * uidServiceTask, id responseObject, NSDictionary * dicResponseHeaders ) {
        if( ![responseObject isKindOfClass:[NSDictionary class]] )
            [NSException exceptionWithName:[NSString stringWithFormat:@"Method %@ bad return", COMPUTEV2_1_SECURITYGROUP_URN]
                                    reason:@"Return value is not a NSDictionnary"
                                  userInfo:@{@"returnedValue": responseObject}];
        
        NSDictionary * dicResponse     = responseObject;
        if( ![[dicResponse objectForKey:@"security_groups"] isKindOfClass:[NSArray class]] )
            [NSException exceptionWithName:[NSString stringWithFormat:@"Method %@ bad return", COMPUTEV2_1_SECURITYGROUP_URN]
                                    reason:@"Access object is not a NSDictionnary"
                                  userInfo:@{@"returnedValue": responseObject}];
        
        if( doAfterList != nil )
            doAfterList( [IOStackServerSecurityGroupV2_1 parseFromAPIResponse:[dicResponse objectForKey:@"security_groups"]], dicResponse );
    }
    onServiceFailure:^( NSString * uidServiceTask, NSError * error, NSUInteger nHTTPStatus ) {
        NSLog( @"token not valid : %@", error );
        
        if( doAfterList != nil )
            doAfterList( nil, nil );
    }];
}

- ( void ) createSecurityGroupWithName:( NSString * ) strSecurityGroupName
                        andDescription:( NSString * ) strSecurityGroupDescription
                                thenDo:( void ( ^ ) ( IOStackServerSecurityGroupV2_1 * secCreated, id idFullResponse ) ) doAfterCreate
{
    NSDictionary * dicUrlParams = nil;
    
    if( strSecurityGroupDescription != nil )
        dicUrlParams = @{@"security_group": @{ @"name": strSecurityGroupName, @"description" : strSecurityGroupDescription } };
    
    else
        dicUrlParams = @{@"security_group": @{ @"name": strSecurityGroupName, @"description" : @"default" } };
    
    [self servicePOST:COMPUTEV2_1_SECURITYGROUP_URN
           withParams:dicUrlParams
     onServiceSuccess:^( NSString * uidServiceTask, id responseObject, NSDictionary * dicResponseHeaders ) {
         if( ![responseObject isKindOfClass:[NSDictionary class]] )
             [NSException exceptionWithName:[NSString stringWithFormat:@"Method %@ bad return", COMPUTEV2_1_SECURITYGROUP_URN]
                                     reason:@"Return value is not a NSDictionnary"
                                   userInfo:@{@"urlParams": dicUrlParams, @"returnedValue": responseObject}];
         
         NSDictionary * dicResponse     = responseObject;
         if( ![[dicResponse objectForKey:@"keypair"] isKindOfClass:[NSDictionary class]] )
             [NSException exceptionWithName:[NSString stringWithFormat:@"Method %@ bad return", COMPUTEV2_1_SECURITYGROUP_URN]
                                     reason:@"Access object is not a NSDictionnary"
                                   userInfo:@{@"urlParams": dicUrlParams, @"returnedValue": responseObject}];
         
         IOStackServerSecurityGroupV2_1 * secCreated = [IOStackServerSecurityGroupV2_1 initFromAPIResponse:[dicResponse objectForKey:@"security_group"]];
         
         if( secCreated.uniqueID != nil &&
            doAfterCreate != nil )
             doAfterCreate( secCreated, dicResponse );
         
     }
     onServiceFailure:^( NSString * uidServiceTask, NSError * error, NSUInteger nHTTPStatus ) {
         NSLog( @"token not valid : %@", error );
         
         if( doAfterCreate != nil )
             doAfterCreate( nil, nil );
     }];
}

- ( void ) deleteSecurityGroupWithID:( NSString * ) uidSecurityGroup
                              thenDo:( void ( ^ ) ( bool isDeleted ) ) doAfterDelete
{
    NSString * strSecurityGroupURL = [NSString stringWithFormat:@"%@/%@", COMPUTEV2_1_SECURITYGROUP_URN, uidSecurityGroup];
    
    [self serviceDELETE:strSecurityGroupURL
       onServiceSuccess:^( NSString * uidServiceTask, id responseObject, NSDictionary * dicResponseHeaders ) {
           
           if( doAfterDelete != nil )
               doAfterDelete( YES );
           
       }
       onServiceFailure:^( NSString * uidServiceTask, NSError * error, NSUInteger nHTTPStatus ) {
           NSLog( @"token not valid : %@", error );
           
           if( doAfterDelete != nil )
               doAfterDelete( NO );
       }];
}

- ( void ) addRuleToSecurityGroupWithID:( NSString * ) uidSecurityGroupID
                           withProtocol:( NSString * ) strIPProtocolName
                               FromPort:( NSNumber * ) nPortFrom
                                 ToPort:( NSNumber * ) nPortTo
                                AndCIDR:( NSString * ) strCIDR
                                 thenDo:( void ( ^ ) ( IOStackServerSecurityGroupRuleV2_1 * ruleCreated, id idFullResponse ) ) doAfterCreate
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
        
    
    [self servicePOST:COMPUTEV2_1_SECURITYGROUPRULES_URN
           withParams:dicUrlParams
     onServiceSuccess:^( NSString * uidServiceTask, id responseObject, NSDictionary * dicResponseHeaders ) {
         if( ![responseObject isKindOfClass:[NSDictionary class]] )
             [NSException exceptionWithName:[NSString stringWithFormat:@"Method %@ bad return", COMPUTEV2_1_SECURITYGROUPRULES_URN]
                                     reason:@"Return value is not a NSDictionnary"
                                   userInfo:@{@"urlParams": dicUrlParams, @"returnedValue": responseObject}];
         
         NSDictionary * dicResponse     = responseObject;
         if( ![[dicResponse objectForKey:@"keypair"] isKindOfClass:[NSDictionary class]] )
             [NSException exceptionWithName:[NSString stringWithFormat:@"Method %@ bad return", COMPUTEV2_1_SECURITYGROUPRULES_URN]
                                     reason:@"Access object is not a NSDictionnary"
                                   userInfo:@{@"urlParams": dicUrlParams, @"returnedValue": responseObject}];
         
         if( doAfterCreate != nil )
             doAfterCreate( [IOStackServerSecurityGroupRuleV2_1 initFromAPIResponse:[dicResponse objectForKey:@"security_group_rule"]], dicResponse );
         
     }
     onServiceFailure:^( NSString * uidServiceTask, NSError * error, NSUInteger nHTTPStatus ) {
         NSLog( @"token not valid : %@", error );
         
         if( doAfterCreate != nil )
             doAfterCreate( nil, nil );
     }];
}

- ( void ) deleteSecurityGroupRuleWithID:( NSString * ) uidSecurityGroupRule
                                  thenDo:( void ( ^ ) ( bool isDeleted ) ) doAfterDelete
{
    NSString * strSecurityGroupURL = [NSString stringWithFormat:@"%@/%@", COMPUTEV2_1_SECURITYGROUPRULES_URN, uidSecurityGroupRule];
    
    [self serviceDELETE:strSecurityGroupURL
       onServiceSuccess:^( NSString * uidServiceTask, id responseObject, NSDictionary * dicResponseHeaders ) {
           
           if( doAfterDelete != nil )
               doAfterDelete( YES );
           
       }
       onServiceFailure:^( NSString * uidServiceTask, NSError * error, NSUInteger nHTTPStatus ) {
           NSLog( @"token not valid : %@", error );
           
           if( doAfterDelete != nil )
               doAfterDelete( NO );
       }];
}


@end
