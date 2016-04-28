//
//  IOStackImage.h
//  IOpenStack
//
//  Created by Bruno Morel on 2016-01-24.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "IOStackAuth.h"

#import "IOStackImageObjectV2.h"


@interface IOStackImageV2 : IOStackService


// local property accessors
@property (strong, nonatomic) NSString * _Nonnull                       currentTokenID;


+ ( nonnull instancetype ) initWithImageURL:( nonnull NSString * ) strImageRoot
                                 andTokenID:( nonnull NSString * ) strTokenID;
+ ( nonnull instancetype ) initWithIdentity:( nonnull id<IOStackIdentityInfos> ) idUserIdentity;

- ( nonnull instancetype ) initWithImageURL:( nonnull NSString * ) strImageRoot
                                 andTokenID:( nonnull NSString * ) strTokenID;
- ( nonnull instancetype ) initWithIdentity:( nonnull id<IOStackIdentityInfos> ) idUserIdentity;
- ( void ) listImagesThenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicImages ) ) doAfterList;


@end
