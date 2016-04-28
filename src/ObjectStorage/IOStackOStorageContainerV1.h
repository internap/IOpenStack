//
//  IOStackOStorageContainerV1.h
//  IOpenStack
//
//  Created by Bruno Morel on 2016-02-29.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import "IOStackObject.h"


#define IOStackObjectTypeOStoreContainer          @"ostore-container"


@interface IOStackOStorageContainerV1 : IOStackObject<IOStackObjectParsable>


@property (readonly, strong, nonatomic) NSString * _Nonnull                         nameContainer;
@property (readonly, strong, nonatomic) NSNumber * _Nonnull                         numOfObjects;
@property (readonly, strong, nonatomic) NSNumber * _Nonnull                         numOfBytes;


+ ( nonnull NSDictionary * ) parseFromAPIResponse:( nonnull NSArray * ) arrAPIResponseData;
+ ( nonnull instancetype ) initFromAPIResponse:( nonnull NSDictionary * ) dicAPIPOSTResponse;

- ( nonnull instancetype ) initFromAPIResponse:( nonnull NSDictionary * ) dicAPIPOSTResponse;


@end
