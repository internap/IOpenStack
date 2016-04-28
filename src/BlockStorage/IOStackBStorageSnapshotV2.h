//
//  IOStackBStorageSnapshotV2.h
//  IOpenStack
//
//  Created by Bruno Morel on 2016-04-15.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import <IOpenStack/IOpenStack.h>


#define IOStackObjectTypeSnapshot         @"snapshot"

#define IOStackSnapshotStatusUnknown          @""
#define IOStackSnapshotStatusCreating         @"creating"
#define IOStackSnapshotStatusAvailable        @"available"
#define IOStackSnapshotStatusDeleting         @"deleting"
#define IOStackSnapshotStatusError            @"error"
#define IOStackSnapshotStatusErrorDeleting    @"error_deleting"


@interface IOStackBStorageSnapshotV2 : IOStackObject<IOStackObjectParsable>


@property (readonly, strong, nonatomic) NSString * _Nonnull                         uidVolumeFrom;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         nameSnapshot;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         descriptionSnapshot;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         status;
@property (readonly, strong, nonatomic) NSDate * _Nullable                          created_at;
@property (readonly, strong, nonatomic) NSNumber * _Nullable                        size;
@property (readonly, strong, nonatomic) NSNumber * _Nullable                        progress;
@property (readonly, strong, nonatomic) NSDictionary * _Nonnull                     metadatas;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         uidProjectOrTenant;



+ ( nonnull NSDictionary * ) parseFromAPIResponse:( nonnull NSArray * ) arrAPIResponseData;
+ ( nonnull instancetype ) initFromAPIResponse:( nonnull NSDictionary * ) dicAPIResponse;
+ ( nonnull instancetype ) initFromAPIGETResponse:( nonnull NSDictionary * ) dicAPIGETResponse;

- ( nonnull instancetype ) initFromAPIResponse:( nonnull NSDictionary * ) dicAPIResponse;
- ( void ) setAvailable:( BOOL ) isAvailable;


@end
