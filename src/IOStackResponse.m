//
//  IOStackResponse.m
//  IOpenStack
//
//  Created by Bruno MOREL on 2016-06-08.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import "IOStackResponse.h"

@implementation IOStackResponse
{
    BOOL        isFailed;
}

@synthesize state;

@synthesize responseHeaders;
@synthesize responseContent;


+ ( instancetype ) initWithNonHTTPError:( NSError * ) errorNonHTTP
                             andHeaders:( NSDictionary * ) dicResponseHeaders
                             andContent:( id ) ptrContent
{
    return [ [self alloc] initWithNonHTTPError:errorNonHTTP
                                    andHeaders:dicResponseHeaders
                                    andContent:ptrContent];
}

+ ( instancetype ) initWithStatus:( NSUInteger ) nHTTPStatus
                       andHeaders:( NSDictionary * ) dicResponseHeaders
                       andContent:( id ) ptrContent
{
    return [ [self alloc] initWithStatus:nHTTPStatus
                              andHeaders:dicResponseHeaders
                              andContent:ptrContent];
}

+ ( instancetype ) initWithStatus:( NSUInteger ) nHTTPStatus
                       andMessage:( NSString * ) strSuccessOrErrorMessage
                       andHeaders:( NSDictionary * ) dicResponseHeaders
                       andContent:( id ) ptrContent
{
    return [ [self alloc] initWithStatus:nHTTPStatus
                              andMessage:strSuccessOrErrorMessage
                              andHeaders:dicResponseHeaders
                              andContent:ptrContent];
}

- ( instancetype ) initWithNonHTTPError:( NSError * ) errorNonHTTP
                             andHeaders:( NSDictionary * ) dicResponseHeaders
                             andContent:( id ) ptrContent
{
    return [self initWithStatus:0
                     andMessage:[errorNonHTTP localizedDescription]
                     andHeaders:dicResponseHeaders
                     andContent:ptrContent];
}

- ( instancetype ) initWithStatus:( NSUInteger ) nHTTPStatus
                       andHeaders:( NSDictionary * ) dicResponseHeaders
                       andContent:( id ) ptrContent
{
    return [self initWithStatus:nHTTPStatus
                     andMessage:[NSHTTPURLResponse localizedStringForStatusCode:nHTTPStatus]
                     andHeaders:dicResponseHeaders
                     andContent:ptrContent];
}

- ( instancetype ) initWithStatus:( NSUInteger ) nHTTPStatus
                       andMessage:( NSString * ) strSuccessOrErrorMessage
                       andHeaders:( NSDictionary * ) dicResponseHeaders
                       andContent:( id ) ptrContent
{
    if( self = [super init] )
    {
        state = [NSError errorWithDomain:@"IOStack-SERVICE"
                                    code:nHTTPStatus
                                userInfo:@{ NSLocalizedDescriptionKey : strSuccessOrErrorMessage}];
        
        isFailed = ( [state code] < 200 || [state code] >= 300 );
        
        responseHeaders = dicResponseHeaders;
        responseContent = ptrContent;
    }
    
    return self;
}

- ( BOOL ) failed
{
    return isFailed;
}

- ( BOOL ) success
{
    return !isFailed;
}

- ( NSString * ) description
{
    if( [self failed] )
        return [NSString stringWithFormat:@"ERROR : %ld - %@", [state code], [state localizedDescription]];
    
    return [NSString stringWithFormat:@"SUCCESS : %ld - %@", [state code], [state localizedDescription]];
}


@end
