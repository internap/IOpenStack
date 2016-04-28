//
//  IOStackServerFlavorsV2_1.h
//  IOpenStack
//
//  Created by Bruno Morel on 2016-02-08.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import "IOStackObject.h"


#define IOStackObjectTypeFlavor         @"flavor"


@interface IOStackServerFlavorsV2_1 : IOStackObject<IOStackObjectParsable>


@property (readonly, nonatomic) NSString * _Nonnull                         name;


+ ( nonnull NSDictionary * ) parseFromAPIResponse:( nonnull NSArray * ) arrAPIResponseData;
+ ( nonnull instancetype ) initFromAPIResponse:( nonnull NSDictionary * ) dicAPIResponse;
+ ( nullable NSString * ) findIDForFlavors:( nonnull NSDictionary * ) dicFlavors
                        withNameContaining:( nonnull NSString * ) strFlavorName;

- ( nonnull instancetype ) initFromAPIResponse:( nonnull NSDictionary * ) dicAPIResponse;


@end
