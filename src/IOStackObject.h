//
//  IOStackObject.h
//  IOpenStack
//
//  Created by Bruno Morel on 2016-01-25.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@class IOStackObject;


@protocol IOStackObjectParsable


@required
+ ( nonnull IOStackObject * ) initFromAPIResponse:( nonnull NSDictionary * ) dicAPIPOSTResponse;

@optional
+ ( nonnull NSDictionary * ) parseFromAPIResponse:( nonnull NSArray * ) arrAPIResponseData;


@end



@interface IOStackObject : NSObject


@property (strong, nonatomic) NSString * _Nullable                   uniqueID;
@property (strong, nonatomic) NSString * _Nullable                   objectType;


@end
