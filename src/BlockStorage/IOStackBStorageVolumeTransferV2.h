//
//  IOStackBStorageVolumeTransferV2.h
//  IOpenStack
//
//  Created by Bruno Morel on 2016-04-15.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import <IOpenStack/IOpenStack.h>


#define IOStackObjectTypeVolumeTransfer         @"volume-transfer"


@interface IOStackBStorageVolumeTransferV2 : IOStackObject<IOStackObjectParsable>


@property (readonly, strong, nonatomic) NSString * _Nonnull                         uidVolumeToTransfer;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         nameVolumeTransfer;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         keyAuthentication;
@property (readonly, strong, nonatomic) NSDate * _Nullable                          created_at;


+ ( nonnull NSDictionary * ) parseFromAPIResponse:( nonnull NSArray * ) arrAPIResponseData;
+ ( nonnull instancetype ) initFromAPIResponse:( nonnull NSDictionary * ) dicAPIResponse;
+ ( nonnull instancetype ) initFromAPIGETResponse:( nonnull NSDictionary * ) dicAPIGETResponse;

- ( nonnull instancetype ) initFromAPIResponse:( nonnull NSDictionary * ) dicAPIResponse;


@end
