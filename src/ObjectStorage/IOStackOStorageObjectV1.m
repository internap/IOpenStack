//
//  IOStackOStorageObjectV1.m
//  IOpenStack
//
//  Created by Bruno Morel on 2016-03-03.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import "IOStackOStorageObjectV1.h"



@implementation IOStackOStorageObjectV1


@synthesize uriFilename;
@synthesize mimeType;
@synthesize numOfBytes;
@synthesize eTag;
@synthesize dateLastModified;


+ ( NSDictionary * ) parseFromAPIResponse:( NSArray * ) arrAPIResponseData
{
    NSMutableDictionary * parsedContainers = [[NSMutableDictionary alloc] init];
    
    for( id currentContainer in arrAPIResponseData )
    {
        if( ![currentContainer isKindOfClass:[NSDictionary class]] )
            break;
        
        if( [currentContainer valueForKey:@"name"] == nil )
            break;
        
        IOStackOStorageObjectV1 * object = [[IOStackOStorageObjectV1 alloc] initFromAPIResponse:currentContainer];
        
        [parsedContainers setObject:object
                             forKey:object.uniqueID];
    }
    
    return parsedContainers;
}

+ ( instancetype ) initFromAPIResponse:( NSDictionary * ) dicAPIResponse
{
    return [ [self alloc] initFromAPIResponse:dicAPIResponse ];
}


- ( instancetype ) initFromAPIResponse:( NSDictionary * ) dicAPIResponse
{
    if( self = [super init] )
    {
        self.objectType     = IOStackObjectTypeOStoreContainer;
        self.uniqueID       = dicAPIResponse[ @"name" ];
        uriFilename         = self.uniqueID;
        mimeType            = dicAPIResponse[ @"content_type" ];
        numOfBytes          = dicAPIResponse[ @"bytes" ];
        eTag                = dicAPIResponse[ @"hash" ];
        dateLastModified    = dicAPIResponse[ @"last_modified" ];
    }
    return self;
}



@end
