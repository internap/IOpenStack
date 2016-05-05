//
//  IOStackAuthV3.h
//  IOpenStack
//
//  Created by Bruno Morel on 2015-12-07.
//  Copyright © 2015 Internap Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "IOStackAuth.h"


@interface IOStackAuthV3 : IOStackService<IOStackIdentityInfos>

// IOStackIdentity protocol
@property (readonly, strong, nonatomic) NSString * _Nullable                currentTokenID;
@property (readonly, strong, nonatomic) NSDictionary * _Nullable            currentServices;
@property (readonly, strong, nonatomic) NSString * _Nullable                currentDomain;
@property (readonly, strong, nonatomic) NSString * _Nullable                currentProjectOrTenant;
@property (readonly, strong, nonatomic) NSString * _Nullable                currentProjectOrTenantID;

// local property accessors
@property (readonly, strong, nonatomic) NSDictionary * _Nullable        currentTokenObject;
@property (readonly, strong, nonatomic) NSArray * _Nullable             currentProjectsList;
@property (readonly, strong, nonatomic) NSString * _Nullable            currentDomainID;


+ ( nonnull instancetype ) initWithIdentityURL:( nonnull NSString * ) strIdentityRoot;
+ ( nonnull instancetype ) initWithIdentityURL:( nonnull NSString * ) strIdentityRoot
                                      andLogin:( nonnull NSString * ) strLogin
                                   andPassword:( nullable NSString * ) strPassword
                              forDefaultDomain:( nullable NSString * ) strDomain
                            andProjectOrTenant:( nullable NSString * ) strProjectOrTenant
                                        thenDo:( nullable void ( ^ ) ( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse ) ) doAfterInit;
+ ( nonnull instancetype ) initWithIdentityURL:( nonnull NSString * ) strIdentityRoot
                                    andTokenID:( nonnull NSString * ) strToken
                              forDefaultDomain:( nullable NSString * ) strDomain
                            andProjectOrTenant:( nullable NSString * ) strProjectOrTenant
                                        thenDo:( nullable void ( ^ ) ( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse ) ) doAfterInit;

- ( nonnull instancetype ) initWithIdentityURL:( nonnull NSString * ) strIdentityRoot;
- ( nonnull instancetype ) initWithIdentityURL:( nonnull NSString * ) strIdentityRoot
                                      andLogin:( nonnull NSString * ) strLogin
                                   andPassword:( nullable NSString * ) strPassword
                              forDefaultDomain:( nullable NSString * ) strDomain
                            andProjectOrTenant:( nullable NSString * ) strProjectOrTenant
                                        thenDo:( nullable void ( ^ ) ( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse ) ) doAfterInit;
- ( nonnull instancetype ) initWithIdentityURL:( nonnull NSString * ) strIdentityRoot
                                    andTokenID:( nonnull NSString * ) strToken
                              forDefaultDomain:( nullable NSString * ) strDomain
                            andProjectOrTenant:( nullable NSString * ) strProjectOrTenant
                                        thenDo:( nullable void ( ^ ) ( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse ) ) doAfterInit;
- ( void ) authenticateWithUrlParams:( nullable NSDictionary * ) dicUrlParams
                              thenDo:( nullable void ( ^ ) ( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse ) ) doAfterInit;
- ( void ) authenticateWithLogin:( nonnull NSString * ) strLogin
                     andPassword:( nullable NSString * ) strPassword
                       forDomain:( nullable NSString * ) strDomain
              andProjectOrTenant:( nullable NSString * ) strTenant
                          thenDo:( nullable void ( ^ ) ( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse ) ) doAfterInit;
- ( void ) authenticateWithTokenID:( nonnull NSString * ) strTokenID
                         forDomain:( nullable NSString * ) strDomain
                andProjectOrTenant:( nullable NSString * ) strTenant
                            thenDo:( nullable void ( ^ ) ( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse ) ) doAfterInit;
- ( void ) authenticateForDomain:( nullable NSString * ) strDomain
              andProjectOrTenant:( nullable NSString * ) strProjectOrTenant
                          thenDo:( nullable void ( ^ ) ( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse ) ) doAfterInit;
- ( void ) authenticateThenDo:( nullable void ( ^ ) ( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse ) ) doAfterInit;
- ( void ) listProjectsOrTenantsWithTokenID:( nonnull NSString * ) strTokenID
                                  forDomain:( nullable NSString * ) strDomainName
                                       From:( nullable NSString * ) strStartingFromID
                                         To:( nullable NSNumber * ) nLimit
                                     thenDo:( nullable void ( ^ ) ( NSArray * _Nullable arrProjectResponse ) ) doAfterList;
- ( void ) listProjectsOrTenantsWithLogin:( nonnull NSString * ) strLogin
                              andPassword:( nullable NSString * ) strPassword
                                forDomain:( nullable NSString * ) strDomainName
                       andProjectOrTenant:( nullable NSString * ) strProjectOrTenant
                                     From:( nullable NSString * ) strStartingFromID
                                       To:( nullable NSNumber * ) nLimit
                                   thenDo:( nullable void ( ^ ) ( NSArray * _Nullable arrProjectResponse ) ) doAfterList;
- ( void ) listProjectsOrTenantsFrom:( nullable NSString * ) strStartingFromID
                                  To:( nullable NSNumber * ) nLimit
                              thenDo:( nullable void ( ^ ) ( NSArray * _Nullable arrProjectResponse ) ) doAfterList;
- ( void ) listProjectsOrTenantsThenDo:( nullable void ( ^ ) ( NSArray * _Nullable arrProjectResponse ) ) doAfterList;


@end
