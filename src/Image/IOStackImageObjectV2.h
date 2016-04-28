//
//  IOStackImageObject.h
//  IOpenStack
//
//  Created by Bruno Morel on 2016-01-25.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import "IOStackObject.h"


#define IOStackObjectTypeImage         @"image"


@interface IOStackImageObjectV2 : IOStackObject<IOStackObjectParsable>


//inherited @property (readonly, nonatomic) NSString * _Nullable                        "id" : 1f66e987-0406-4d64-b8d4-60dba71cc3a5 ,
@property (readonly, strong, nonatomic) NSString * _Nonnull                         name;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         status;
@property (readonly, strong, nonatomic) NSDate * _Nullable                          created_at;
@property (readonly, strong, nonatomic) NSDate * _Nullable                          updated_at;
@property (readonly, strong, nonatomic) NSString * _Nullable                        schema;
@property (readonly, strong, nonatomic) NSString * _Nullable                        container_format;
@property (readonly, strong, nonatomic) NSString * _Nullable                        disk_format;
@property (readonly, strong, nonatomic) NSString * _Nullable                        owner;
@property (readonly, strong, nonatomic) NSString * _Nullable                        visibility;
@property (readonly, strong, nonatomic) NSString * _Nullable                        filePath;
@property (readonly, strong, nonatomic) NSString * _Nullable                        fileChecksum;
@property (readonly, strong, nonatomic) NSNumber * _Nullable                        fileSize;
@property (readonly, strong, nonatomic) NSNumber * _Nullable                        virtual_size;
@property (readonly, strong, nonatomic) NSNumber * _Nullable                        min_ram;
@property (readonly, strong, nonatomic) NSNumber * _Nullable                        min_disk;
@property (readonly, strong, nonatomic) NSNumber * _Nullable                        isProtected;

@property (readonly, strong, nonatomic) NSString * _Nullable                        ramdisk_id;
@property (readonly, strong, nonatomic) NSString * _Nullable                        kernel_id;


+ ( nonnull NSDictionary * ) parseFromAPIResponse:( nonnull NSArray * ) arrAPIResponseData;
+ ( nonnull instancetype ) initFromAPIResponse:( nonnull NSDictionary * ) dicAPIResponse;

- ( nonnull instancetype ) initFromAPIResponse:( nonnull NSDictionary * ) dicAPIResponse;


@end
