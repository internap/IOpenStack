//
//  IOStackServerSecurityGroupRuleV2_1.h
//  IOpenStack
//
//  Created by Bruno Morel on 2016-02-05.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import "IOStackObject.h"


#define IOStackObjectTypeSecurityGroupRule @"securitygrouprule"


@interface IOStackComputeSecurityGroupRuleV2_1  : IOStackObject<IOStackObjectParsable>


@property (readonly, strong, nonatomic) NSString * _Nonnull                         parentGroupID;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         ipProtocol;
@property (readonly, strong, nonatomic) NSDictionary * _Nonnull                     ipRange;
@property (readonly, strong, nonatomic) NSNumber * _Nonnull                         nPortFrom;
@property (readonly, strong, nonatomic) NSNumber * _Nonnull                         nPortTo;


+ ( nonnull NSDictionary * ) parseFromAPIResponse:( nonnull NSArray * ) arrAPIResponseData;
+ ( nonnull instancetype ) initFromAPIResponse:( nonnull NSDictionary * ) dicAPIResponse;

- ( nonnull instancetype ) initFromAPIResponse:( nonnull NSDictionary * ) dicAPIResponse;


@end
