//
//  IOStackAuth_INAP.h
//  IOpenStack
//
//  Created by Bruno Morel on 2015-11-26.
//  Copyright © 2015 Internap Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "IOStackAuthV3.h"


#define PROVIDERNAME_INAP       @"INAP"


@interface IOStackAuth_INAP : IOStackAuthV3 <IOStackIdentityProvider>


//IOStackIdentityProvider protocol
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
