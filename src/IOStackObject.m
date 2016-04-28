//
//  IOStackObject.m
//  IOpenStack
//
//  Created by Bruno Morel on 2016-01-25.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import "IOStackObject.h"

@implementation IOStackObject
{
    NSURLSession *          _httpSession;
    NSMutableDictionary *   _dicActiveTasks;
    NSMutableDictionary *   _cacheResponseData;
}

@synthesize uniqueID;
@synthesize objectType;



@end
