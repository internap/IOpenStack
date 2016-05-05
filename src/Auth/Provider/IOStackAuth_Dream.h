//
//  IOStackAuth_Dream.h
//  IOpenStack
//
//  Created by Bruno Morel on 2016-01-12.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "IOStackAuthV2.h"


#define PROVIDERNAME_DREAMHOST      @"Dreamhost"


@interface IOStackAuth_Dream : IOStackAuthV2<IOStackIdentityProvider>


// IOStackIdentityProvider protocol
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
