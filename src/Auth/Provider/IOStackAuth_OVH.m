//
//  IOStackAuth_OVH.m
//  IOpenStack
//
//  Created by Bruno Morel on 2016-01-12.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import "IOStackAuth_OVH.h"


@implementation IOStackAuth_OVH

//IOStackService protocol
@synthesize serviceURLs;
@synthesize serviceType;
@synthesize serviceRootURL;
@synthesize versionMajor;
@synthesize versionMinor;
@synthesize providerName;

//IOStackIdentity protocol
@synthesize currentTokenID;
@synthesize currentDomain;
@synthesize currentProjectOrTenant;
@synthesize currentProjectOrTenantID;

//local properties accessors
@synthesize iostackV2Manager;


#define IDENTITY_OVH_URI @"https://auth.cloud.ovh.net/"


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
-( NSString * ) currentTokenID
{
    return iostackV2Manager.currentTokenID;
}

-( NSDictionary * ) currentServices
{
    return iostackV2Manager.currentServices;
}

-( NSString * ) currentDomain
{
    return iostackV2Manager.currentDomain;
}

-( NSString * ) currentProjectOrTenant
{
    return iostackV2Manager.currentProjectOrTenant;
}

-( NSString * ) currentProjectOrTenantID
{
    return iostackV2Manager.currentProjectOrTenantID;
}


#pragma mark - Object init
- ( id ) init
{
    serviceType = @"identity";
    serviceRootURL = IDENTITY_OVH_URI;
    versionMajor = @2;
    versionMinor = @0;
    providerName = @"OVH";
    
    iostackV2Manager = [IOStackAuthV2 initWithIdentityURL:IDENTITY_OVH_URI];
    
    return [super init];
}

- ( id ) initWithLogin:( NSString * ) strLogin
           andPassword:( NSString * ) strPassword
      forDefaultDomain:( NSString * ) strDomainName
    andProjectOrTenant:( NSString * ) strProjectOrTenant
                thenDo:( void ( ^ ) ( NSString * strTokenIDResponse, NSDictionary * dicFullResponse ) ) doAfterInit
{
    //always try to reuse the token if we got a valid one
    iostackV2Manager = [IOStackAuthV2 initWithIdentityURL:IDENTITY_OVH_URI
                                                 andLogin:strLogin
                                              andPassword:strPassword
                                         forDefaultDomain:nil
                                       andProjectOrTenant:strProjectOrTenant
                                                   thenDo:doAfterInit];
    return [super init];
}

- ( id ) initWithTokenID:( NSString * ) strTokenID
        forDefaultDomain:( NSString * ) strDomainName
      andProjectOrTenant:( NSString * ) strProjectOrTenant
                  thenDo:( void ( ^ ) ( NSString * strTokenIDResponse, NSDictionary * dicFullResponse ) ) doAfterInit
{
    iostackV2Manager = [IOStackAuthV2 initWithIdentityURL:IDENTITY_OVH_URI
                                               andTokenID:strTokenID
                                         forDefaultDomain:strDomainName
                                       andProjectOrTenant:strProjectOrTenant
                                                   thenDo:doAfterInit];
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
                                     thenDo:doAfterAuth];
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
                                     thenDo:doAfterAuth];
}

- ( void ) authenticateThenDo:( void ( ^ ) ( NSString * strTokenIDResponse, NSDictionary * dicFullResponse ) ) doAfterAuth
{
    [self authenticateForDomain:nil
             andProjectOrTenant:nil
                         thenDo:doAfterAuth];
}


#pragma mark - Project list methods
- ( void ) listProjectsOrTenantsWithTokenID:( NSString * ) strTokenID
                                  forDomain:( NSString * ) strDomainName
                                       From:( NSString * ) strStartingFromID
                                         To:( NSNumber * ) nLimit
                                     thenDo:( void ( ^ ) ( NSArray * arrProjectResponse ) ) doAfterList
{
    [iostackV2Manager listProjectsOrTenantsWithTokenID:strTokenID
                                             forDomain:strDomainName
                                                  From:strStartingFromID
                                                    To:nLimit
                                                thenDo:doAfterList];
}

- ( void ) listProjectsOrTenantsWithLogin:( NSString * ) strLogin
                              andPassword:( NSString * ) strPassword
                                forDomain:( NSString * ) strDomainName
                                     From:( NSString * ) strStartingFromID
                                       To:( NSNumber * ) nLimit
                                   thenDo:( void ( ^ ) ( NSArray * arrProjectResponse ) ) doAfterList
{
    [iostackV2Manager listProjectsOrTenantsWithLogin:strLogin
                                         andPassword:strPassword
                                           forDomain:strDomainName
                                                From:strStartingFromID
                                                  To:nLimit
                                              thenDo:doAfterList];
}

- ( void ) listProjectsOrTenantsFrom:( NSString * ) strStartingFromID
                                  To:( NSNumber * ) nLimit
                              thenDo:( void ( ^ ) ( NSArray * arrProjectResponse ) ) doAfterList
{
    [iostackV2Manager listProjectsOrTenantsFrom:strStartingFromID
                                             To:nLimit
                                         thenDo:doAfterList];
}

- ( void ) listProjectsOrTenantsThenDo:( void ( ^ ) ( NSArray * arrProjectResponse ) ) doAfterList
{
    [self listProjectsOrTenantsFrom:nil
                                 To:nil
                             thenDo:doAfterList];
}


@end
