//
//  IOStackBStorageBackupV2.h
//  IOpenStack
//
//  Created by Bruno Morel on 2016-04-06.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import "IOStackObject.h"


#define IOStackObjectTypeBackup         @"backup"

#define IOStackBackupStatusUnknown          @""
#define IOStackBackupStatusCreating         @"creating"
#define IOStackBackupStatusAvailable        @"available"
#define IOStackBackupStatusDeleting         @"deleting"
#define IOStackBackupStatusRestoring        @"restoring"
#define IOStackBackupStatusError            @"error"
#define IOStackBackupStatusErrorRestoring   @"error_restoring"

@interface IOStackBStorageBackupV2 : IOStackObject<IOStackObjectParsable>

@property (readonly, strong, nonatomic) NSString * _Nonnull                         uidVolumeFrom;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         nameContainer;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         availability_zone;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         nameBackup;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         descriptionBackup;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         status;
@property (readonly, strong, nonatomic) NSDate * _Nullable                          created_at;
@property (readonly, strong, nonatomic) NSDate * _Nullable                          updated_at;
@property (readonly, strong, nonatomic) NSNumber * _Nullable                        size;
@property (readonly, strong, nonatomic) NSNumber * _Nullable                        is_incremental;
@property (readonly, strong, nonatomic) NSNumber * _Nullable                        has_dependent_backups;
@property (readonly, strong, nonatomic) NSNumber * _Nullable                        object_count;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         fail_reason;



+ ( nonnull NSDictionary * ) parseFromAPIResponse:( nonnull NSArray * ) arrAPIResponseData;
+ ( nonnull instancetype ) initFromAPIResponse:( nonnull NSDictionary * ) dicAPIResponse;
+ ( nonnull instancetype ) initFromAPIGETResponse:( nonnull NSDictionary * ) dicAPIGETResponse;

- ( nonnull instancetype ) initFromAPIResponse:( nonnull NSDictionary * ) dicAPIResponse;
- ( void ) setAvailable:( BOOL ) isAvailable;


@end
