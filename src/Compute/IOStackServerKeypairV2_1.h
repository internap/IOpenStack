//
//  IOStackServerKeypair.h
//  IOpenStack
//
//  Created by Bruno Morel on 2016-02-05.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import "IOStackObject.h"


#define IOStackObjectTypeKeypair             @"keypair"


@interface IOStackServerKeypairV2_1 : IOStackObject<IOStackObjectParsable>


@property (readonly, nonatomic) NSString * _Nonnull                         fingerprint;
@property (readonly, nonatomic) NSString * _Nonnull                         name;
@property (readonly, nonatomic) NSString * _Nonnull                         publicKey;


+ ( nonnull NSDictionary * ) parseFromAPIResponse:( nonnull NSArray * ) arrAPIResponseData;
+ ( nonnull instancetype ) initFromAPIResponse:( nonnull NSDictionary * ) dicAPIResponse;

- ( nonnull instancetype ) initFromAPIResponse:( nonnull NSDictionary * ) dicAPIResponse;

@end
