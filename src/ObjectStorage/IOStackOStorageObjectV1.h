//
//  IOStackOStorageObjectV1.h
//  IOpenStack
//
//  Created by Bruno Morel on 2016-03-03.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import <IOpenStack/IOpenStack.h>



#define IOStackObjectTypeOStoreObject          @"ostore-object"



@interface IOStackOStorageObjectV1 : IOStackObject<IOStackObjectParsable>


@property (readonly, strong, nonatomic) NSString * _Nonnull                         uriFilename;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         mimeType;
@property (readonly, strong, nonatomic) NSNumber * _Nonnull                         numOfBytes;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         eTag;
@property (readonly, strong, nonatomic) NSDate * _Nonnull                           dateLastModified;


+ ( nonnull NSDictionary * ) parseFromAPIResponse:( nonnull NSArray * ) arrAPIResponseData;
+ ( nonnull instancetype ) initFromAPIResponse:( nonnull NSDictionary * ) dicAPIPOSTResponse;

- ( nonnull instancetype ) initFromAPIResponse:( nonnull NSDictionary * ) dicAPIPOSTResponse;

@end
