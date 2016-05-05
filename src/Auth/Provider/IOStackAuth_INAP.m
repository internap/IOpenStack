//
//  IOStackAuth_INAP.m
//  IOpenStack
//
//  Created by Bruno Morel on 2015-11-26.
//  Copyright © 2015 Internap Inc. All rights reserved.
//

#import "IOStackAuth_INAP.h"


@implementation IOStackAuth_INAP


#define IDENTITY_INAP_URI                   @"https://identity.api.cloud.iweb.com"


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



#pragma mark - Object init
- ( id ) init
{
    if( self = [super initWithIdentityURL:IDENTITY_INAP_URI] )
    {
        self.nameProvider = PROVIDERNAME_INAP;
    }
    
    return self;
}

- ( id ) initWithLogin:( NSString * ) strLogin
           andPassword:( NSString * ) strPassword
      forDefaultDomain:( NSString * ) strDomainName
    andProjectOrTenant:( NSString * ) strProjectOrTenant
                thenDo:( void ( ^ ) ( NSString * strTokenIDResponse, NSDictionary * dicFullResponse ) ) doAfterInit
{
    if( self = [super initWithIdentityURL:IDENTITY_INAP_URI
                                 andLogin:strLogin
                              andPassword:strPassword
                         forDefaultDomain:strDomainName
                       andProjectOrTenant:strProjectOrTenant
                                   thenDo:doAfterInit] )
    {
        self.nameProvider = PROVIDERNAME_INAP;
    }
    
    return self;
}

- ( id ) initWithTokenID:( NSString * ) strTokenID
        forDefaultDomain:( NSString * ) strDomainName
      andProjectOrTenant:( NSString * ) strProjectOrTenant
                  thenDo:( void ( ^ ) ( NSString * strTokenIDResponse, NSDictionary * dicFullResponse ) ) doAfterInit
{
    if( self = [super initWithIdentityURL:IDENTITY_INAP_URI
                               andTokenID:strTokenID
                         forDefaultDomain:strDomainName
                       andProjectOrTenant:strProjectOrTenant
                                   thenDo:doAfterInit] )
    {
        self.nameProvider = PROVIDERNAME_INAP;
    }
    
    return self;
}


@end
