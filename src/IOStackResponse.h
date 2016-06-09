//
//  IOStackResponse.h
//  IOpenStack
//
//  Created by Bruno MOREL on 2016-06-08.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IOStackResponse : NSObject


@property (strong, nonatomic, readonly) NSError * _Nullable                     state;

@property (strong, nonatomic, readonly) NSDictionary * _Nullable                responseHeaders;
@property (strong, nonatomic, readonly) id _Nullable                            responseContent;

+ ( nonnull instancetype ) initWithNonHTTPError:( nonnull NSError * ) errorNonHTTP
                                     andHeaders:( nullable NSDictionary * ) dicResponseHeaders
                                     andContent:( nullable id ) ptrContent;
+ ( nonnull instancetype ) initWithStatus:( NSUInteger ) nHTTPStatus
                               andMessage:( nonnull NSString * ) strSuccessOrErrorMessage
                               andHeaders:( nullable NSDictionary * ) dicResponseHeaders
                               andContent:( nullable id ) ptrContent;
+ ( nonnull instancetype ) initWithStatus:( NSUInteger ) nHTTPStatus
                               andHeaders:( nullable NSDictionary * ) dicResponseHeaders
                               andContent:( nullable id ) ptrContent;

- ( nonnull instancetype ) initWithNonHTTPError:( nonnull NSError * ) errorNonHTTP
                                     andHeaders:( nullable NSDictionary * ) dicResponseHeaders
                                     andContent:( nullable id ) ptrContent;
- ( nonnull instancetype ) initWithStatus:( NSUInteger ) nHTTPStatus
                               andHeaders:( nullable NSDictionary * ) dicResponseHeaders
                               andContent:( nullable id ) ptrContent;
- ( nonnull instancetype ) initWithStatus:( NSUInteger ) nHTTPStatus
                               andMessage:( nonnull NSString * ) strSuccessOrErrorMessage
                               andHeaders:( nullable NSDictionary * ) dicResponseHeaders
                               andContent:( nullable id ) ptrContent;
- ( BOOL ) failed;
- ( BOOL ) success;


@end
