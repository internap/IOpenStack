//
//  IOStackOStorageContainerV1.m
//  IOpenStack
//
//  Created by Bruno Morel on 2016-02-29.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import "IOStackOStorageContainerV1.h"


@implementation IOStackOStorageContainerV1


@synthesize nameContainer;
@synthesize numOfObjects;
@synthesize numOfBytes;


+ ( NSDictionary * ) parseFromAPIResponse:( NSArray * ) arrAPIResponseData
{
    NSMutableDictionary * parsedContainers = [[NSMutableDictionary alloc] init];
    
    for( id currentContainer in arrAPIResponseData )
    {
        if( ![currentContainer isKindOfClass:[NSDictionary class]] )
            break;
        
        if( [currentContainer valueForKey:@"name"] == nil )
            break;
        
        IOStackOStorageContainerV1 * container = [[IOStackOStorageContainerV1 alloc] initFromAPIResponse:currentContainer];
        
        [parsedContainers setObject:container
                             forKey:container.uniqueID];
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
        nameContainer       = self.uniqueID;
        numOfObjects        = dicAPIResponse[ @"count" ];
        numOfBytes          = dicAPIResponse[ @"bytes" ];
    }
    return self;
}


@end
