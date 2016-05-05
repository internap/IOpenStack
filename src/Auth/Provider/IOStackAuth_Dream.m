//
//  IOStackAuth_Dream.m
//  IOpenStack
//
//  Created by Bruno Morel on 2016-01-12.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import "IOStackAuth_Dream.h"


@implementation IOStackAuth_Dream


#define IDENTITY_DREAM_URI  @"https://iad2.dream.io:5000"


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
    if( self = [super initWithIdentityURL:IDENTITY_DREAM_URI] )
    {
        self.nameProvider = PROVIDERNAME_DREAMHOST;
    }
    
    return self;
}

- ( id ) initWithLogin:( NSString * ) strLogin
           andPassword:( NSString * ) strPassword
      forDefaultDomain:( NSString * ) strDomainName
    andProjectOrTenant:( NSString * ) strProjectOrTenant
                thenDo:( void ( ^ ) ( NSString * strTokenIDResponse, NSDictionary * dicFullResponse ) ) doAfterInit
{
    if( self = [super initWithIdentityURL:IDENTITY_DREAM_URI
                                 andLogin:strLogin
                              andPassword:strPassword
                         forDefaultDomain:strDomainName
                       andProjectOrTenant:strProjectOrTenant
                                   thenDo:doAfterInit] )
    {
        self.nameProvider = PROVIDERNAME_DREAMHOST;
    }
    
    return self;
}

- ( id ) initWithTokenID:( NSString * ) strTokenID
        forDefaultDomain:( NSString * ) strDomainName
      andProjectOrTenant:( NSString * ) strProjectOrTenant
                  thenDo:( void ( ^ ) ( NSString * strTokenIDResponse, NSDictionary * dicFullResponse ) ) doAfterInit
{
    if( self = [super initWithIdentityURL:IDENTITY_DREAM_URI
                               andTokenID:strTokenID
                         forDefaultDomain:strDomainName
                       andProjectOrTenant:strProjectOrTenant
                                   thenDo:doAfterInit] )
    {
        self.nameProvider = PROVIDERNAME_DREAMHOST;
    }
    
    return self;
}

@end
