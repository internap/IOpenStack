//
//  IOStackAuth_INAP.h
//  IOpenStack
//
//  Created by Bruno Morel on 2015-11-26.
//  Copyright © 2015 Internap Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "IOStackAuthV2.h"
#include "IOStackAuthV3.h"

#define PROVIDERNAME_INAP       @"INAP"


@interface IOStackAuth_INAP : NSObject <IOStackIdentityProvider>


// IOStackIdentity protocol
@property (readonly, strong, nonatomic) NSString * _Nullable                currentTokenID;
@property (readonly, strong, nonatomic) NSDictionary * _Nullable            currentServices;
@property (readonly, strong, nonatomic) NSString * _Nullable                currentDomain;
@property (readonly, strong, nonatomic) NSString * _Nullable                currentProjectOrTenant;
@property (readonly, strong, nonatomic) NSString * _Nullable                currentProjectOrTenantID;

// local property accessors
@property (readonly, strong, nonatomic) NSString * _Nonnull                 serviceRootURL;
@property (readonly, strong, nonatomic) IOStackAuthV2 * _Nullable               iostackV2Manager;
@property (readonly, strong, nonatomic) IOStackAuthV3 * _Nullable               iostackV3Manager;


+ ( nonnull id ) init;
+ ( nonnull id ) initWithLogin:( nonnull NSString * ) strLogin
                   andPassword:( nullable NSString * ) strPassword
              forDefaultDomain:( nullable NSString * ) strDomainName
            andProjectOrTenant:( nullable NSString * ) strProjectOrTenant
                        thenDo:( nullable void ( ^ ) ( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse ) ) doAfterInit;
+ ( nonnull id ) initWithTokenID:( nonnull NSString * ) strTokenID
                forDefaultDomain:( nullable NSString * ) strDomainName
              andProjectOrTenant:( nullable NSString * ) strProjectOrTenant
                          thenDo:( nullable void ( ^ ) ( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse ) ) doAfterInit;

- ( nonnull id ) init;
- ( nonnull id ) initWithLogin:( nonnull NSString * ) strLogin
                   andPassword:( nullable NSString * ) strPassword
              forDefaultDomain:( nullable NSString * ) strDomainName
            andProjectOrTenant:( nullable NSString * ) strProjectOrTenant
                        thenDo:( nullable void ( ^ ) ( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse ) ) doAfterInit;
- ( nonnull id ) initWithTokenID:( nonnull NSString * ) strTokenID
                forDefaultDomain:( nullable NSString * ) strDomainName
              andProjectOrTenant:( nullable NSString * ) strProjectOrTenant
                          thenDo:( nullable void ( ^ ) ( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse ) ) doAfterInit;
- ( void ) authenticateWithLogin:( nonnull NSString * ) strLogin
                     andPassword:( nullable NSString * ) strPassword
                       forDomain:( nullable NSString * ) strDomainName
              andProjectOrTenant:( nullable NSString * ) strProjectOrTenant
                          thenDo:( nullable void ( ^ ) ( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse ) ) doAfterAuth;
- ( void ) authenticateWithTokenID:( nonnull NSString * ) strTokenID
                         forDomain:( nullable NSString * ) strDomainName
                andProjectOrTenant:( nullable NSString * ) strProjectOrTenant
                            thenDo:( nullable void ( ^ ) ( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse ) ) doAfterAuth;
- ( void ) authenticateForDomain:( nullable NSString * ) strDomainName
              andProjectOrTenant:( nullable NSString * ) strProjectOrTenant
                          thenDo:( nullable void ( ^ ) ( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse ) ) doAfterAuth;
- ( void ) authenticateThenDo:( nullable void ( ^ ) ( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse ) ) doAfterAuth;
- ( void ) listProjectsOrTenantsWithTokenID:( nonnull NSString * ) strTokenID
                                  forDomain:( nullable NSString * ) strDomainName
                                       From:( nullable NSString * ) strStartingFromID
                                         To:( nullable NSNumber * ) nLimit
                                     thenDo:( nullable void ( ^ ) ( NSArray * _Nullable arrProjectResponse ) ) doAfterListProject;
- ( void ) listProjectsOrTenantsWithLogin:( nonnull NSString * ) strLogin
                              andPassword:( nullable NSString * ) strPassword
                                forDomain:( nullable NSString * ) strDomainName
                                     From:( nullable NSString * ) strStartingFromID
                                       To:( nullable NSNumber * ) nLimit
                                   thenDo:( nullable void ( ^ ) ( NSArray * _Nullable arrProjectResponse ) ) doAfterListProject;
- ( void ) listProjectsOrTenantsFrom:( nullable NSString * ) strStartingFromID
                                  To:( nullable NSNumber * ) nLimit
                              thenDo:( nullable void ( ^ ) ( NSArray * _Nullable arrProjectResponse ) ) doAfterListProject;
- ( void ) listProjectsOrTenantsThenDo:( nullable void ( ^ ) ( NSArray * _Nullable arrProjectResponse ) ) doAfterListProject;


@end
