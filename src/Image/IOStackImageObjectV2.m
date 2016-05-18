//
//  IOStackImageObject.m
//  IOpenStack
//
//  Created by Bruno Morel on 2016-01-25.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import "IOStackImageObjectV2.h"

@implementation IOStackImageObjectV2

@synthesize name;
@synthesize status;
@synthesize created_at;
@synthesize updated_at;
@synthesize schema;
@synthesize container_format;
@synthesize disk_format;
@synthesize owner;
@synthesize visibility;
@synthesize filePath;
@synthesize fileChecksum;
@synthesize fileSize;
@synthesize virtual_size;
@synthesize min_ram;
@synthesize min_disk;
@synthesize isProtected;
@synthesize ramdisk_id;
@synthesize kernel_id;
@synthesize tags;


+ ( NSDictionary * ) parseFromAPIResponse:( NSArray * ) arrAPIResponseData
{
    NSMutableDictionary * parsedImages = [[NSMutableDictionary alloc] init];
    
    for( id currentImage in arrAPIResponseData )
    {
        if( ![currentImage isKindOfClass:[NSDictionary class]] )
            break;
        
        if( [currentImage valueForKey:@"id"] == nil )
            break;
        
        IOStackImageObjectV2 * image = [[IOStackImageObjectV2 alloc] initFromAPIResponse:currentImage];
        
        [parsedImages setObject:image
                         forKey:image.uniqueID];
    }
    
    return parsedImages;
}

+ ( id ) initFromAPIResponse:( NSDictionary * ) dicAPIResponse
{
    return [ [self alloc] initFromAPIResponse:dicAPIResponse ];
}


- ( instancetype ) initFromAPIResponse:( NSDictionary * ) dicAPIResponse
{
    if( dicAPIResponse == nil )
        return nil;
    
    if( self = [super init] )
    {
        self.objectType     = IOStackObjectTypeImage;
        self.uniqueID       = dicAPIResponse[ @"id" ];
        name                = dicAPIResponse[ @"name" ];
        status              = dicAPIResponse[ @"status" ];
        created_at          = dicAPIResponse[ @"created_at" ];
        updated_at          = dicAPIResponse[ @"updated_at" ];
        schema              = dicAPIResponse[ @"schema" ];
        container_format    = dicAPIResponse[ @"container_format" ];
        disk_format         = dicAPIResponse[ @"disk_format" ];
        owner               = dicAPIResponse[ @"owner" ];
        visibility          = dicAPIResponse[ @"visibility" ];
        filePath            = dicAPIResponse[ @"file" ];
        fileChecksum        = dicAPIResponse[ @"checksum" ];
        fileSize            = dicAPIResponse[ @"size" ];
        virtual_size        = dicAPIResponse[ @"virtual_size" ];
        min_ram             = dicAPIResponse[ @"min_ram" ];
        min_disk            = dicAPIResponse[ @"min_disk" ];
        isProtected         = dicAPIResponse[ @"protected" ];
        
        ramdisk_id          = dicAPIResponse[ @"ramdisk_id" ];
        kernel_id           = dicAPIResponse[ @"kernel_id" ];
        
        tags                = dicAPIResponse[ @"tags" ];

    }
    return self;
}

@end
