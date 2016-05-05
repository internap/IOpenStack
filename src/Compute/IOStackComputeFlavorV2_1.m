//
//  IOStackServerFlavorsV2_1.m
//  IOpenStack
//
//  Created by Bruno Morel on 2016-02-08.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import "IOStackComputeFlavorV2_1.h"


@implementation IOStackComputeFlavorV2_1


@synthesize name;


+ ( NSDictionary * ) parseFromAPIResponse:( NSArray * ) arrAPIResponseData
{
    NSMutableDictionary * parsedFlavors = [[NSMutableDictionary alloc] init];
    
    for( id currentFlavor in arrAPIResponseData )
    {
        if( ![currentFlavor isKindOfClass:[NSDictionary class]] )
            break;
        
        if( [currentFlavor valueForKey:@"id"] == nil )
            break;
        
        IOStackComputeFlavorV2_1 * flavor = [[IOStackComputeFlavorV2_1 alloc] initFromAPIResponse:currentFlavor];
        
        [parsedFlavors setObject:flavor
                          forKey:flavor.uniqueID];
    }
    
    return parsedFlavors;
}

+ ( id ) initFromAPIResponse:( NSDictionary * ) dicAPIResponse
{
    return [ [self alloc] initFromAPIResponse:dicAPIResponse ];
}


+ ( NSString * ) findIDForFlavors:( NSDictionary * ) dicFlavors
               withNameContaining:( NSString * ) strFlavorName
{
    NSString * foundID = nil;
    
    for( NSString * currentFlavorID in dicFlavors )
    {
        IOStackComputeFlavorV2_1 * currentFlavor = [dicFlavors valueForKey:currentFlavorID];
        if( [currentFlavor.name containsString:strFlavorName] )
            foundID = currentFlavor.uniqueID;
    }
    
    return foundID;
}

- ( instancetype ) initFromAPIResponse:( NSDictionary * ) dicAPIResponse
{
    if( dicAPIResponse == nil )
        return nil;
    
    if( self = [super init] )
    {
        self.objectType     = IOStackObjectTypeFlavor;
        self.uniqueID       = dicAPIResponse[ @"id" ];
        name                = dicAPIResponse[ @"name" ];
        
    }
    return self;
}

@end
