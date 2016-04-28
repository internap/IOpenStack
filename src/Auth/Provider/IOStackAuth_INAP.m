//
//  IOStackAuth_INAP.m
//  IOpenStack
//
//  Created by Bruno Morel on 2015-11-26.
//  Copyright © 2015 Internap Inc. All rights reserved.
//

#import "IOStackAuth_INAP.h"


@implementation IOStackAuth_INAP

//IOStackIdentity protocol
@synthesize currentTokenID;
@synthesize currentDomain;
@synthesize currentProjectOrTenantID;

//local properties accessors
@synthesize iostackV2Manager;
@synthesize iostackV3Manager;


#define IDENTITY_INAP_URI                   @"https://identity.api.cloud.iweb.com/"
#define IDENTITY_INAP_DEFAULT_DOMAIN       @"Default"


#pragma mark - Class level init
+ ( id ) init
{
    return [ [ self alloc ] init];
}

+ ( id ) initWithLogin:( NSString * ) strLogin
           andPassword:( NSString * ) strPassword
      forDefaultDomain:( NSString * ) strDomainName
    andProjectOrTenant:( NSString * ) strProjectOrTenant
                thenDo:( void ( ^ ) ( NSString * strTokenIDResponse, NSDictionary * dicFullResponse ) ) doAfterInit
{
    return [ [ self alloc ] initWithLogin:strLogin
                              andPassword:strPassword
                         forDefaultDomain:strDomainName
                       andProjectOrTenant:strProjectOrTenant
                                   thenDo:doAfterInit];
}

+ ( id ) initWithTokenID:( NSString * ) strTokenID
        forDefaultDomain:( NSString * ) strDomainName
      andProjectOrTenant:( NSString * ) strProjectOrTenant
                  thenDo:( void ( ^ ) ( NSString * strTokenIDResponse, NSDictionary * dicFullResponse ) ) doAfterInit
{
    return [ [ self alloc ] initWithTokenID:strTokenID
                           forDefaultDomain:strDomainName
                         andProjectOrTenant:strProjectOrTenant
                                     thenDo:doAfterInit];
}


#pragma mark - Property accessors
-( NSString * ) serviceType
{
    if( iostackV3Manager.serviceType != nil )
        return iostackV3Manager.serviceType;
    
    return iostackV2Manager.serviceType;
}

-( NSNumber * ) versionMajor
{
    if( iostackV3Manager.versionMajor != 0 )
        return iostackV3Manager.versionMajor;
    
    return iostackV2Manager.versionMajor;
}

-( NSNumber * ) versionMinor
{
    if( iostackV3Manager.versionMinor != 0 )
        return iostackV3Manager.versionMinor;
    
    return iostackV2Manager.versionMinor;
}

-( NSString * ) nameProvider
{
    if( iostackV3Manager.nameProvider != nil )
        return iostackV3Manager.nameProvider;
    
    return iostackV2Manager.nameProvider;
}

-( NSString * ) serviceID
{
    if( iostackV3Manager.serviceID != nil )
        return iostackV3Manager.serviceID;
    
    return iostackV2Manager.serviceID;
}

-( NSString * ) currentTokenID
{
    if( iostackV3Manager.currentTokenID != nil )
        return iostackV3Manager.currentTokenID;
    
    return iostackV2Manager.currentTokenID;
}

-( NSDictionary * ) currentServices
{
    if( iostackV3Manager.currentServices != nil )
        return iostackV3Manager.currentServices;
    
    return iostackV2Manager.currentServices;
}

-( NSString * ) currentDomain
{
    if( iostackV3Manager.currentDomain!= nil )
        return iostackV3Manager.currentDomain;
    
    return iostackV2Manager.currentDomain;
}

-( NSString * ) currentProjectOrTenant
{
    if( iostackV3Manager.currentProjectOrTenant != nil )
        return iostackV3Manager.currentProjectOrTenant;
    
    return iostackV2Manager.currentProjectOrTenant;
}

-( NSString * ) currentProjectOrTenantID
{
    if( iostackV3Manager.currentProjectOrTenantID != nil )
        return iostackV3Manager.currentProjectOrTenantID;
    
    return iostackV2Manager.currentProjectOrTenantID;
}


#pragma mark - Object init
- ( id ) init
{
    iostackV2Manager = [IOStackAuthV2 initWithIdentityURL:IDENTITY_INAP_URI];
    iostackV3Manager = [IOStackAuthV3 initWithIdentityURL:IDENTITY_INAP_URI];
    
    return [super init];
}

- ( id ) initWithLogin:( NSString * ) strLogin
           andPassword:( NSString * ) strPassword
      forDefaultDomain:( NSString * ) strDomainName
    andProjectOrTenant:( NSString * ) strProjectOrTenant
                thenDo:( void ( ^ ) ( NSString * strTokenIDResponse, NSDictionary * dicFullResponse ) ) doAfterInit
{
    //always try to reuse the token if we got a valid one
    iostackV2Manager = [IOStackAuthV2 initWithIdentityURL:IDENTITY_INAP_URI
                                                 andLogin:strLogin
                                              andPassword:strPassword
                                         forDefaultDomain:IDENTITY_INAP_DEFAULT_DOMAIN
                                       andProjectOrTenant:strProjectOrTenant
                                                   thenDo:^(NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse) {
                                                       if( strTokenIDResponse == nil )
                                                       {
                                                           iostackV2Manager = nil;
                                                           NSLog( @"WARNING : v2 authenticate has failed - trying V3" );
                                                           iostackV3Manager = [IOStackAuthV3 initWithIdentityURL:IDENTITY_INAP_URI
                                                                                                        andLogin:strLogin
                                                                                                     andPassword:strPassword
                                                                                                forDefaultDomain:strDomainName
                                                                                              andProjectOrTenant:strProjectOrTenant
                                                                                                          thenDo:doAfterInit];
                                                       }
                                                       else
                                                           iostackV3Manager = [iostackV3Manager initWithIdentityURL:IDENTITY_INAP_URI
                                                                                                         andTokenID:strTokenIDResponse
                                                                                                   forDefaultDomain:strDomainName
                                                                                                 andProjectOrTenant:strProjectOrTenant
                                                                                                             thenDo:doAfterInit];
                                                   }];
    return [super init];
}

- ( id ) initWithTokenID:( NSString * ) strTokenID
        forDefaultDomain:( NSString * ) strDomainName
      andProjectOrTenant:( NSString * ) strProjectOrTenant
                  thenDo:( void ( ^ ) ( NSString * strTokenIDResponse, NSDictionary * dicFullResponse ) ) doAfterInit
{
    iostackV2Manager = [IOStackAuthV2 initWithIdentityURL:IDENTITY_INAP_URI
                                               andTokenID:strTokenID
                                         forDefaultDomain:strDomainName
                                       andProjectOrTenant:strProjectOrTenant
                                                   thenDo:^(NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse) {
                                                       if( strTokenIDResponse == nil )
                                                       {
                                                           iostackV2Manager = nil;
                                                           NSLog( @"WARNING : v2 authenticate has failed - trying V3" );
                                                           iostackV3Manager = [IOStackAuthV3 initWithIdentityURL:IDENTITY_INAP_URI
                                                                                                      andTokenID:strTokenID
                                                                                                forDefaultDomain:strDomainName
                                                                                              andProjectOrTenant:strProjectOrTenant
                                                                                                          thenDo:doAfterInit];
                                                       }
                                                       else
                                                           iostackV3Manager = [iostackV3Manager initWithIdentityURL:IDENTITY_INAP_URI
                                                                                                         andTokenID:strTokenIDResponse
                                                                                                   forDefaultDomain:strDomainName
                                                                                                 andProjectOrTenant:strProjectOrTenant
                                                                                                             thenDo:doAfterInit];
                                                   }];
    return [super init];
}


#pragma mark - authenticate methods
- ( void ) authenticateWithLogin:( NSString * ) strLogin
                     andPassword:( NSString * ) strPassword
                       forDomain:( NSString * ) strDomainName
              andProjectOrTenant:( NSString * ) strProjectOrTenant
                          thenDo:( void ( ^ ) ( NSString * strTokenIDResponse, NSDictionary * dicFullResponse ) ) doAfterAuth
{
    [iostackV2Manager authenticateWithLogin:strLogin
                                andPassword:strPassword
                                  forDomain:strDomainName
                         andProjectOrTenant:strProjectOrTenant
                                     thenDo:^(NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse) {
                                         if( strTokenIDResponse == nil )
                                         {
                                             iostackV2Manager = nil;
                                             NSLog( @"WARNING : v2 authenticate has failed" );
                                             [iostackV3Manager authenticateWithLogin:strLogin
                                                                         andPassword:strPassword
                                                                           forDomain:strDomainName
                                                                  andProjectOrTenant:strProjectOrTenant
                                                                              thenDo:doAfterAuth];
                                         }
                                         else
                                             [iostackV3Manager authenticateWithTokenID:strTokenIDResponse
                                                                             forDomain:strDomainName
                                                                    andProjectOrTenant:strProjectOrTenant
                                                                                thenDo:doAfterAuth];
                                     }];
}

- ( void ) authenticateWithTokenID:( NSString * ) newTokenID
                         forDomain:( NSString * ) strDomainName
                andProjectOrTenant:( NSString * ) strProjectOrTenant
                            thenDo:( void ( ^ ) ( NSString * strTokenIDResponse, NSDictionary * dicFullResponse ) ) doAfterAuth
{
    [self authenticateWithTokenID:newTokenID
                        forDomain:strDomainName
               andProjectOrTenant:strProjectOrTenant
                           thenDo:doAfterAuth];
}

- ( void ) authenticateForDomain:( NSString * ) strDomainName
              andProjectOrTenant:( NSString * ) strProjectOrTenant
                          thenDo:( void ( ^ ) ( NSString * strTokenIDResponse, NSDictionary * dicFullResponse ) ) doAfterAuth
{
    [iostackV2Manager authenticateForDomain:strDomainName
                         andProjectOrTenant:strProjectOrTenant
                                     thenDo:^(NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse) {
                                         if( strTokenIDResponse == nil )
                                         {
                                             NSLog( @"WARNING : v2 authenticate has failed" );
                                             [iostackV3Manager authenticateForDomain:strDomainName
                                                                  andProjectOrTenant:strProjectOrTenant
                                                                              thenDo:doAfterAuth];
                                         }
                                         else
                                             [iostackV3Manager authenticateWithTokenID:strTokenIDResponse
                                                                             forDomain:strDomainName
                                                                    andProjectOrTenant:strProjectOrTenant
                                                                                thenDo:doAfterAuth];
                                     }];
}

- ( void ) authenticateThenDo:( void ( ^ ) ( NSString * strTokenIDResponse, NSDictionary * dicFullResponse ) ) doAfterAuth
{
    [self authenticateForDomain:nil
             andProjectOrTenant:nil
                         thenDo:doAfterAuth];
}

- ( void ) authenticate
{
    [self authenticateThenDo:nil];
}


#pragma mark - Project list methods
- ( void ) listProjectsOrTenantsWithTokenID:( NSString * ) strTokenID
                                  forDomain:( NSString * ) strDomainName
                                       From:( NSString * ) strStartingFromID
                                         To:( NSNumber * ) nLimit
                                     thenDo:( void ( ^ ) ( NSArray * arrProjectResponse ) ) doAfterList
{
    //we're trying V3 and falling back to V2 if it fails...
    
    [iostackV3Manager listProjectsOrTenantsWithTokenID:strTokenID
                                             forDomain:strDomainName
                                                  From:strStartingFromID
                                                    To:nLimit
                                                thenDo:^(NSArray * _Nullable arrProjectResponse) {
                                                    if( arrProjectResponse == nil )
                                                    {
                                                        NSLog( @"WARNING : V3 list projects failed - falling back to V2" );
                                                        [iostackV2Manager listProjectsOrTenantsWithTokenID:strTokenID
                                                                                                 forDomain:strDomainName
                                                                                                      From:strStartingFromID
                                                                                                        To:nLimit
                                                                                                    thenDo:doAfterList];
                                                    }
                                                    else
                                                        doAfterList( arrProjectResponse );
                                                }];
}

- ( void ) listProjectsOrTenantsWithLogin:( NSString * ) strLogin
                              andPassword:( NSString * ) strPassword
                                forDomain:( NSString * ) strDomainName
                                     From:( NSString * ) strStartingFromID
                                       To:( NSNumber * ) nLimit
                                   thenDo:( void ( ^ ) ( NSArray * arrProjectResponse ) ) doAfterList
{
    [iostackV3Manager listProjectsOrTenantsWithLogin:strLogin
                                         andPassword:strPassword
                                           forDomain:strDomainName
                                                From:strStartingFromID
                                                  To:nLimit
                                              thenDo:^(NSArray * _Nullable arrProjectResponse) {
                                                  if( arrProjectResponse == nil )
                                                  {
                                                      NSLog( @"WARNING : V3 list projects failed - falling back to V2" );
                                                      [iostackV2Manager listProjectsOrTenantsWithLogin:strLogin
                                                                                           andPassword:strPassword
                                                                                             forDomain:strDomainName
                                                                                                  From:strStartingFromID
                                                                                                    To:nLimit
                                                                                                thenDo:doAfterList];
                                                  }
                                                  else
                                                      doAfterList( arrProjectResponse );
                                              }];
}

- ( void ) listProjectsOrTenantsFrom:( NSString * ) strStartingFromID
                                  To:( NSNumber * ) nLimit
                              thenDo:( void ( ^ ) ( NSArray * arrProjectResponse ) ) doAfterList
{
    //trying first with V3 token, then falling back on V2
    [iostackV3Manager listProjectsOrTenantsFrom:strStartingFromID
                                             To:nLimit
                                         thenDo:^(NSArray * _Nullable arrProjectResponse) {
                                             if( arrProjectResponse == nil )
                                             {
                                                 NSLog( @"WARNING : V3 list projects failed - falling back to V2" );
                                                 [iostackV2Manager listProjectsOrTenantsFrom:strStartingFromID
                                                                                          To:nLimit
                                                                                      thenDo:doAfterList];
                                             }
                                             else
                                                 doAfterList( arrProjectResponse );
                                         }];
}

- ( void ) listProjectsOrTenantsThenDo:( void ( ^ ) ( NSArray * arrProjectResponse ) ) doAfterList
{
    [self listProjectsOrTenantsFrom:nil
                                 To:nil
                             thenDo:doAfterList];
}


@end
