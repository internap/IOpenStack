//
//  IOStackObject.m
//  IOpenStack
//
//  Created by Bruno Morel on 2016-01-25.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import "IOStackObject.h"

#import <objc/runtime.h>

@implementation IOStackObject
{
    NSURLSession *          _httpSession;
    NSMutableDictionary *   _dicActiveTasks;
    NSMutableDictionary *   _cacheResponseData;
}

@synthesize uniqueID;
@synthesize objectType;

- ( NSString * ) description
{
    return [self descriptionForInstance:self throughType:[self class]];
}

- ( NSString * ) descriptionForInstance:( id ) objInstance
                            throughType:( Class ) classInstance
{
    NSMutableString * strDescription = [NSMutableString stringWithFormat:@"<%@:%p ", NSStringFromClass(classInstance), objInstance];
    
    unsigned int count;
    objc_property_t * propList  = class_copyPropertyList( classInstance, &count );
    NSMutableString * propPrint = [NSMutableString string];
    
    for ( int i = 0; i < count; i++ )
    {
        objc_property_t property = propList[ i ];
        
        const char * propName = property_getName(property);
        NSString * propNameString =[NSString stringWithCString:propName encoding:NSASCIIStringEncoding];
        
        if(propName)
        {
            id value = [objInstance valueForKey:propNameString];
            [propPrint appendFormat:@"%@=%@", propNameString, value];
        }
        if( i < ( count - 1 ) )
           [propPrint appendString:@" "];
    }
    free(propList);
    
    Class classSuper = class_getSuperclass( classInstance );
    if ( classSuper != nil &&
            ! [classSuper isEqual:[NSObject class]] )
        [propPrint appendString:[self descriptionForInstance:objInstance
                                                 throughType:classSuper]];
    
    [propPrint appendString:@">"];
    
    [strDescription appendString:[NSString stringWithFormat:@"%@", propPrint]];
    return strDescription;
}

@end
