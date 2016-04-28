//
//  IOStackServerSecurityGroupRuleV2_1.m
//  IOpenStack
//
//  Created by Bruno Morel on 2016-02-05.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import "IOStackServerSecurityGroupRuleV2_1.h"

@implementation IOStackServerSecurityGroupRuleV2_1

@synthesize parentGroupID;
@synthesize ipProtocol;
@synthesize ipRange;
@synthesize nPortFrom;
@synthesize nPortTo;


+ ( NSDictionary * ) parseFromAPIResponse:( NSArray * ) arrAPIResponseData
{
    NSMutableDictionary * parsedSecurityGroupRules = [[NSMutableDictionary alloc] init];
    
    for( id currentSecurityGroupRule in arrAPIResponseData )
    {
        if( ![currentSecurityGroupRule isKindOfClass:[NSDictionary class]] )
            break;
        
        if( [currentSecurityGroupRule valueForKey:@"id"] == nil )
            break;
        
        IOStackServerSecurityGroupRuleV2_1 * securityGroupRule = [[IOStackServerSecurityGroupRuleV2_1 alloc] initFromAPIResponse:currentSecurityGroupRule];
        
        [parsedSecurityGroupRules setObject:securityGroupRule
                                     forKey:securityGroupRule.uniqueID];
    }
    
    return parsedSecurityGroupRules;
}

+ ( id ) initFromAPIResponse:( NSDictionary * ) dicAPIResponse
{
    return [ [self alloc] initFromAPIResponse:dicAPIResponse ];
}


- ( instancetype ) initFromAPIResponse:( NSDictionary * ) dicAPIResponse
{
    if( self = [super init] )
    {
        self.objectType     = IOStackObjectTypeSecurityGroupRule;
        self.uniqueID       = dicAPIResponse[ @"id" ];
        parentGroupID       = dicAPIResponse[ @"parent_group_id" ];
        ipProtocol          = dicAPIResponse[ @"ip_protocol" ];
        ipRange             = dicAPIResponse[ @"ip_range" ];
        nPortFrom           = dicAPIResponse[ @"from_port" ];
        nPortTo             = dicAPIResponse[ @"to_port" ];
    }
    return self;
}


@end
