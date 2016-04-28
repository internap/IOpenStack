//
//  IOStackAuth.h
//  IOpenStack
//
//  Created by Bruno Morel on 2016-01-14.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IOStackService.h"

@protocol IOStackIdentityInfos <IOStackServiceInfos>

@required
@property (readonly, strong, nonatomic) NSString * _Nullable                currentTokenID;
@property (readonly, strong, nonatomic) NSDictionary * _Nullable            currentServices;
@property (readonly, strong, nonatomic) NSString * _Nullable                currentDomain;
@property (readonly, strong, nonatomic) NSString * _Nullable                currentProjectOrTenant;
@property (readonly, strong, nonatomic) NSString * _Nullable                currentProjectOrTenantID;


@end


@protocol IOStackAuthenticator <IOStackIdentityInfos>

@required
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


@protocol IOStackIdentityVersion <IOStackAuthenticator>

@required
+ ( nonnull id ) initWithIdentityURL:( nonnull NSString * ) strIdentityRoot;
+ ( nonnull id ) initWithIdentityURL:( nonnull NSString * ) strIdentityRoot
                            andLogin:( nonnull NSString * ) strLogin
                         andPassword:( nullable NSString * ) strPassword
                    forDefaultDomain:( nullable NSString * ) strDomain
                  andProjectOrTenant:( nullable NSString * ) strProjectOrTenant
                              thenDo:( nullable void ( ^ ) ( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse ) ) doAfterInit;
+ ( nonnull id ) initWithIdentityURL:( nonnull NSString * ) strIdentityRoot
                          andTokenID:( nonnull NSString * ) strToken
                    forDefaultDomain:( nullable NSString * ) strDomain
                  andProjectOrTenant:( nullable NSString * ) strProjectOrTenant
                              thenDo:( nullable void ( ^ ) ( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse ) ) doAfterInit;

- ( nonnull id ) initWithIdentityURL:( nonnull NSString * ) strIdentityRoot
                            andLogin:( nonnull NSString * ) strLogin
                         andPassword:( nullable NSString * ) strPassword
                    forDefaultDomain:( nullable NSString * ) strDomain
                  andProjectOrTenant:( nullable NSString * ) strProjectOrTenant
                              thenDo:( nullable void ( ^ ) ( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse ) ) doAfterInit;
- ( nonnull id ) initWithIdentityURL:( nonnull NSString * ) strIdentityRoot
                          andTokenID:( nonnull NSString * ) strToken
                    forDefaultDomain:( nullable NSString * ) strDomain
                  andProjectOrTenant:( nullable NSString * ) strProjectOrTenant
                              thenDo:( nullable void ( ^ ) ( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse ) ) doAfterInit;


@end


@protocol IOStackIdentityProvider <IOStackAuthenticator>

@required
+ ( nonnull id ) init;
+ ( nonnull id ) initWithLogin:( nonnull NSString * ) strLogin
                   andPassword:( nullable NSString * ) strPassword
              forDefaultDomain:( nullable NSString * ) strDomain
            andProjectOrTenant:( nullable NSString * ) strProjectOrTenant
                        thenDo:( nullable void ( ^ ) ( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse ) ) doAfterInit;
+ ( nonnull id ) initWithTokenID:( nonnull NSString * ) strToken
                forDefaultDomain:( nullable NSString * ) strDomain
              andProjectOrTenant:( nullable NSString * ) strProjectOrTenant
                          thenDo:( nullable void ( ^ ) ( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse ) ) doAfterInit;

- ( nonnull id ) initWithLogin:( nonnull NSString * ) strLogin
                   andPassword:( nullable NSString * ) strPassword
              forDefaultDomain:( nullable NSString * ) strDomain
            andProjectOrTenant:( nullable NSString * ) strProjectOrTenant
                        thenDo:( nullable void ( ^ ) ( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse ) ) doAfterInit;
- ( nonnull id ) initWithTokenID:( nonnull NSString * ) strToken
                forDefaultDomain:( nullable NSString * ) strDomain
              andProjectOrTenant:( nullable NSString * ) strProjectOrTenant
                          thenDo:( nullable void ( ^ ) ( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse ) ) doAfterInit;


@end


@interface IOStackAuth : NSObject




@end
