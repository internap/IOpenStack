//
//  IOStackServerSecurityGroupV2_1.m
//  IOpenStack
//
//  Created by Bruno Morel on 2016-02-05.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import "IOStackComputeSecurityGroupV2_1.h"

@implementation IOStackComputeSecurityGroupV2_1


@synthesize groupDescription;
@synthesize name;
@synthesize rules;
@synthesize projectOrTenantID;


+ ( NSDictionary * ) parseFromAPIResponse:( NSArray * ) arrAPIResponseData
{
    NSMutableDictionary * parsedSecurityGroups = [[NSMutableDictionary alloc] init];
    
    for( id currentSecurityGroup in arrAPIResponseData )
    {
        if( ![currentSecurityGroup isKindOfClass:[NSDictionary class]] )
            break;
        
        if( [currentSecurityGroup valueForKey:@"id"] == nil )
            break;
        
        IOStackComputeSecurityGroupV2_1 * securityGroup = [[IOStackComputeSecurityGroupV2_1 alloc] initFromAPIResponse:currentSecurityGroup];
        
        [parsedSecurityGroups setObject:securityGroup
                                 forKey:securityGroup.uniqueID];
    }
    
    return parsedSecurityGroups;
}

+ ( id ) initFromAPIResponse:( NSDictionary * ) dicAPIResponse
{
    return [ [self alloc] initFromAPIResponse:dicAPIResponse ];
}

+ ( NSArray * ) createSecurityGroupNameArrayForAPIFromNameArray:( NSArray * ) arrSecurityGroupsNames
{
    NSMutableArray * arrSecurityGroupNamesObjects = [NSMutableArray arrayWithCapacity:[arrSecurityGroupsNames count]];
    for( NSString * currentSecGroupName in arrSecurityGroupsNames )
        [arrSecurityGroupNamesObjects addObject:@{ @"name" : currentSecGroupName }];
    
    return arrSecurityGroupNamesObjects;
}


- ( instancetype ) initFromAPIResponse:( NSDictionary * ) dicAPIResponse
{
    if( dicAPIResponse == nil )
        return nil;
    
    if( self = [super init] )
    {
        self.objectType     = IOStackObjectTypeSecurityGroup;
        self.uniqueID       = dicAPIResponse[ @"id" ];
        groupDescription    = dicAPIResponse[ @"description" ];
        name                = dicAPIResponse[ @"name" ];
        rules               = dicAPIResponse[ @"rules" ];
        projectOrTenantID   = dicAPIResponse[ @"tenant_id" ];
    }
    return self;
}


@end
