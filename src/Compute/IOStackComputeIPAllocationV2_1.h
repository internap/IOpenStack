//
//  IOStackServerFloatingIPAddressV2_1.h
//  IOpenStack
//
//  Created by Bruno Morel on 2016-02-26.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import "IOStackObject.h"


#define IOStackObjectTypeFloatingIP         @"floatingip"


@interface IOStackComputeIPAllocationV2_1 : IOStackObject<IOStackObjectParsable>


@property (readonly, strong, nonatomic) NSString * _Nonnull                         uidInstance;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         namePool;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         ipAddress;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         ipAddressFixed;


+ ( nonnull instancetype ) initFromAPIResponse:( nonnull NSDictionary * ) dicAPIResponse;

- ( nonnull instancetype ) initFromAPIResponse:( nonnull NSDictionary * ) dicAPIResponse;


@end
