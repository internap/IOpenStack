//
//  IOStackServerSecurityGroupV2_1.h
//  IOpenStack
//
//  Created by Bruno Morel on 2016-02-05.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import "IOStackObject.h"


#define IOStackObjectTypeSecurityGroup      @"securitygroup"


@interface IOStackServerSecurityGroupV2_1 : IOStackObject<IOStackObjectParsable>


@property (readonly, strong, nonatomic) NSString * _Nonnull                         groupDescription;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         name;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         rules;
@property (readonly, strong, nonatomic) NSString * _Nonnull                         projectOrTenantID;


+ ( nonnull NSDictionary * ) parseFromAPIResponse:( nonnull NSArray * ) arrAPIResponseData;
+ ( nonnull instancetype ) initFromAPIResponse:( nonnull NSDictionary * ) dicAPIResponse;
+ ( nonnull NSArray * ) createSecurityGroupNameArrayForAPIFromNameArray:( nonnull NSArray * ) arrSecurityGroupsNames;

- ( nonnull instancetype ) initFromAPIResponse:( nonnull NSDictionary * ) dicAPIResponse;


@end
