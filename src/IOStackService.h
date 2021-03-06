//
//  IOStackService.h
//  IOpenStack
//
//  Created by Bruno Morel on 2016-01-14.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "IOStackResponse.h"


#define IDENTITY_SERVICE        @"identity"
#define IMAGESTORAGE_SERVICE    @"image"
#define COMPUTE_SERVICE         @"compute"
#define OBJECTSTORAGE_SERVICE   @"object-store"
#define BLOCKSTORAGE_SERVICE    @"volume"
#define BLOCKSTORAGEV2_SERVICE  @"volumev2"
#define NETWORK_SERVICE         @"network"
#define ORCHESTRATION_SERVICE   @"orchestration"
#define EC2_SERVICE             @"ec2"

#define GENERIC_SERVICENAME     @"generic"

#define DEFAULT_APIREFRESH_FREQUENCY        1.0
#define DEFAULT_APIREFRESH_TIMEOUT          30.0


@class IOStackService;


@protocol IOStackServiceDelegate
@required
- ( void ) onServiceAnswers:( nonnull NSString * ) uidServiceTask
               withResponse:( nonnull IOStackResponse * ) response;

@end


@protocol IOStackServiceInfos
@required
@property (readonly, strong, nonatomic) NSString * _Nullable                serviceID;
@property (readonly, strong, nonatomic) NSString * _Nullable                serviceType;
@property (readonly, strong, nonatomic) NSNumber * _Nullable                versionMajor;
@property (readonly, strong, nonatomic) NSNumber * _Nullable                versionMinor;
@property (strong, nonatomic) NSString * _Nullable                nameProvider;
@end



@interface IOStackService : NSObject<NSURLSessionDelegate, IOStackServiceInfos, IOStackServiceDelegate>

@property (strong, nonatomic) NSURL * _Nonnull                    urlPublic;
@property (strong, nonatomic) NSURL * _Nullable                   urlAdmin;
@property (strong, nonatomic) NSURL * _Nullable                   urlInternal;



/**
 Initiate service with infos
 
 In its base implementation, this method checks for an acceptable status code and content type. Subclasses may wish to add other domain-specific checks.
 
 @param urlServicePublic    The public URL of the service.
 @param strServiceType      The type of the service as defined in the service catalog.
 @param nMajorVersion       The major version of the service.
 @param nMinorVersion       The minor version of the service.
 @param strProviderName     The name of the provider, "generic" by default.
 
 @return instance id.
 */
- ( nonnull instancetype ) initWithPublicURL:( nonnull NSURL * ) urlServicePublic
                                     andType:( nonnull NSString * ) strServiceType
                             andMajorVersion:( nonnull NSNumber * ) nMajorVersion
                             andMinorVersion:( nonnull NSNumber * ) nMinorVersion
                             andProviderName:( nullable NSString * ) strProviderName;
- ( nonnull instancetype ) initWithPublicURL:( nonnull NSURL * ) urlServicePublic
                                       andID:( nonnull NSString * ) uidService
                                     andType:( nonnull NSString * ) strServiceType
                             andMajorVersion:( nonnull NSNumber * ) nMajorVersion
                             andMinorVersion:( nonnull NSNumber * ) nMinorVersion
                             andProviderName:( nullable NSString * ) strProviderName;
- ( nonnull instancetype ) initWithPublicURL:( nonnull NSURL * ) urlServicePublic
                                       andID:( nonnull NSString * ) uidService
                                     andType:( nonnull NSString * ) strServiceType
                             andMajorVersion:( nonnull NSNumber * ) nMajorVersion
                             andMinorVersion:( nonnull NSNumber * ) nMinorVersion
                              andInternalURL:( nonnull NSURL * ) urlServiceInternal
                                 andAdminURL:( nonnull NSURL * ) urlServiceAdmin
                             andProviderName:( nullable NSString * ) strProviderName;
- ( void ) activateDebug:( BOOL ) isActivated;
- ( void ) setHTTPHeader:( nonnull NSString * ) strHeaderString
               withValue:( nonnull NSString * ) strHeaderValue;
- ( void ) setHTTPHeaderWithValues:( nullable NSDictionary * ) dicHeaderValues;
-( NSUInteger ) serviceGET:( nonnull NSString * ) urnResource
                withParams:( nullable NSDictionary * ) dicParams
          onServiceAnswers:( nullable void ( ^ ) ( NSString * _Nonnull uidTaskService, IOStackResponse * _Nonnull response ) ) doOnAnswer;
-( NSUInteger ) serviceGET:( nonnull NSString * ) urnResource
                withParams:( nullable NSDictionary * ) dicParams
               andDelegate:( nullable id<IOStackServiceDelegate> ) idDelegate;
-( NSUInteger ) serviceHEAD:( nonnull NSString * ) urnResource
                 withParams:( nullable NSDictionary * ) dicParams
           onServiceAnswers:( nullable void ( ^ ) ( NSString * _Nonnull uidTaskService, IOStackResponse * _Nonnull response ) ) doOnAnswer;
-( NSUInteger ) serviceHEAD:( nonnull NSString * ) urnResource
                 withParams:( nullable NSDictionary * ) dicParams
                andDelegate:( nullable id<IOStackServiceDelegate> ) idDelegate;
-( NSUInteger ) servicePOST:( nonnull NSString * ) urnResource
                withRawData:( nullable NSData * ) datRaw
           onServiceAnswers:( nullable void ( ^ ) ( NSString * _Nonnull uidTaskService, IOStackResponse * _Nonnull response ) ) doOnAnswer;
-( NSUInteger ) servicePOST:( nonnull NSString * ) urnResource
                withRawData:( nullable NSData * ) datRaw
                andDelegate:( nonnull id<IOStackServiceDelegate> ) idDelegate;
-( NSUInteger ) servicePOST:( nonnull NSString * ) urnResource
                 withParams:( nullable NSDictionary * ) dicParams
           onServiceAnswers:( nullable void ( ^ ) ( NSString * _Nonnull uidTaskService, IOStackResponse * _Nonnull response ) ) doOnAnswer;
-( NSUInteger ) servicePOST:( nonnull NSString * ) urnResource
                 withParams:( nullable NSDictionary * ) dicParams
                andDelegate:( nonnull id<IOStackServiceDelegate> ) idDelegate;
-( NSUInteger ) servicePUT:( nonnull NSString * ) urnResource
               withRawData:( nonnull NSData * ) datRaw
               andDelegate:( nullable id<IOStackServiceDelegate> ) idDelegate;
-( NSUInteger ) servicePUT:( nonnull NSString * ) urnResource
               withRawData:( nonnull NSData * ) datRaw
          onServiceAnswers:( nullable void ( ^ ) ( NSString * _Nonnull uidTaskService, IOStackResponse * _Nonnull response ) ) doOnAnswer;
-( NSUInteger ) servicePUT:( nonnull NSString * ) urnResource
                withParams:( nullable NSDictionary * ) dicParams
               andDelegate:( nonnull id<IOStackServiceDelegate> ) idDelegate;
-( NSUInteger ) servicePUT:( nonnull NSString * ) urnResource
                withParams:( nullable NSDictionary * ) dicParams
          onServiceAnswers:( nullable void ( ^ ) ( NSString * _Nonnull uidTaskService, IOStackResponse * _Nonnull response ) ) doOnAnswer;
-( NSUInteger ) servicePATCH:( nonnull NSString * ) urnResource
                 withRawData:( nonnull NSData * ) datRaw
                 andDelegate:( nullable id<IOStackServiceDelegate> ) idDelegate;
-( NSUInteger ) servicePATCH:( nonnull NSString * ) urnResource
                 withRawData:( nonnull NSData * ) datRaw
            onServiceAnswers:( nullable void ( ^ ) ( NSString * _Nonnull uidTaskService, IOStackResponse * _Nonnull response ) ) doOnAnswer;
-( NSUInteger ) servicePATCH:( nonnull NSString * ) urnResource
                  withParams:( nullable NSDictionary * ) dicParams
                 andDelegate:( nonnull id<IOStackServiceDelegate> ) idDelegate;
-( NSUInteger ) servicePATCH:( nonnull NSString * ) urnResource
                  withParams:( nullable NSDictionary * ) dicParams
            onServiceAnswers:( nullable void ( ^ ) ( NSString * _Nonnull uidTaskService, IOStackResponse * _Nonnull response ) ) doOnAnswer;
-( NSUInteger ) serviceDELETE:( nonnull NSString * ) urnResource
                  andDelegate:( nonnull id<IOStackServiceDelegate> ) idDelegate;
-( NSUInteger ) serviceDELETE:( nonnull NSString * ) urnResource
             onServiceAnswers:( nullable void ( ^ ) ( NSString * _Nonnull uidTaskService, IOStackResponse * _Nonnull response ) ) doOnAnswer;
- ( void ) readRawResource:( nonnull NSString * ) urlResource
                withHeader:( nullable NSDictionary * ) dicHeaderFieldValue
              andUrlParams:( nullable NSDictionary * ) paramsURL
                 insideKey:( nullable NSString * ) nameObjectKey
                    thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicObjectFound, id _Nullable dataResponse ) ) doWithReadResults;
- ( void ) readResource:( nonnull NSString * ) urlResource
             withHeader:( nullable NSDictionary * ) dicHeaderFieldValue
           andUrlParams:( nullable NSDictionary * ) paramsURL
              insideKey:( nullable NSString * ) nameObjectKey
                 thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicObjectFound, id _Nullable dataResponse ) ) doWithReadResults;
- ( void ) readResource:( nonnull NSString * ) urlResource
             withHeader:( nullable NSDictionary * ) dicHeaderFieldValue
           andUrlParams:( nullable NSDictionary * ) paramsURL
                 thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicObjectFound, id _Nullable dataResponse ) ) doWithReadResults;
- ( void ) metadataResource:( nonnull NSString * ) urlResource
                 withHeader:( nullable NSDictionary * ) dicHeaderFieldValue
               andUrlParams:( nullable NSDictionary * ) paramsURL
                     thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable headerValues, id _Nullable dataResponse ) ) doWithMetadata;
- ( void ) listResource:( nonnull NSString * ) urlResource
             withHeader:( nullable NSDictionary * ) dicHeaderFieldValue
           andUrlParams:( nullable NSDictionary * ) paramsURL
                 thenDo:( nullable void ( ^ ) ( NSArray * _Nullable arrFound, id _Nullable dataResponse ) ) doWithListResults;
- ( void ) listResource:( nonnull NSString * ) urlResource
             withHeader:( nullable NSDictionary * ) dicHeaderFieldValue
           andUrlParams:( nullable NSDictionary * ) paramsURL
              insideKey:( nullable NSString * ) keyJSONObject
                 thenDo:( nullable void ( ^ ) ( NSArray * _Nullable arrFound, id _Nullable dataResponse ) ) doWithListResults;
- ( void ) createResource:( nonnull NSString * ) urlResource
               withHeader:( nullable NSDictionary * ) dicHeaderFieldValue
               andRawData:( nullable NSData * ) datRaw
                   thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicResponseHeaders, id _Nullable idFullResponse ) ) doWithCreateResults;
- ( void ) createResource:( nonnull NSString * ) urlResource
               withHeader:( nullable NSDictionary * ) dicHeaderFieldValue
             andUrlParams:( nullable NSDictionary * ) paramsURL
                   thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicResponseHeaders, id _Nullable idFullResponse ) ) doWithCreateResults;
- ( void ) replaceResource:( nonnull NSString * ) urlResource
                withHeader:( nullable NSDictionary * ) dicHeaderFieldValue
                andRawData:( nullable NSData * ) datRaw
                    thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicResponseHeader, id _Nullable idFullResponse ) ) doWithCreateResults;
- ( void ) replaceResource:( nonnull NSString * ) urlResource
                withHeader:( nullable NSDictionary * ) dicHeaderFieldValue
              andUrlParams:( nullable NSDictionary * ) paramsURL
                    thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicResponseHeader, id _Nullable idFullResponse ) ) doWithCreateResults;
- ( void ) updateResource:( nonnull NSString * ) urlResource
               withHeader:( nullable NSDictionary * ) dicHeaderFieldValue
               andRawData:( nullable NSData * ) datRaw
                   thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicResponseHeader, id _Nullable idFullResponse ) ) doWithCreateResults;
- ( void ) updateResource:( nonnull NSString * ) urlResource
               withHeader:( nullable NSDictionary * ) dicHeaderFieldValue
             andUrlParams:( nullable NSDictionary * ) paramsURL
                   thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicResponseHeader, id _Nullable idFullResponse ) ) doWithCreateResults;
- ( void ) deleteResource:( nonnull NSString * ) urlResource
               withHeader:( nullable NSDictionary * ) dicHeaderFieldValue
                   thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicResults, id _Nullable idFullResponse ) ) doWithDeleteResults;
- ( void ) waitResource:( nonnull NSString * ) urlResource
          withUrlParams:( nullable NSDictionary * ) urlParams
              insideKey:( nullable NSString * ) nameObjectKey
               forField:( nullable NSString * ) strFieldName
           toEqualValue:( nullable id ) valToEqual
          orErrorValues:( nullable NSArray * ) arrErrorValues
          withFrequency:( NSTimeInterval ) tiFrequency
             andTimeout:( NSTimeInterval ) tiTimeout
                 thenDo:( nullable void ( ^ ) ( bool isWithStatus, id _Nullable dicObjectValues ) ) doAfterWait;
- ( void ) waitResource:( nonnull NSString * ) urlResource
          withUrlParams:( nullable NSDictionary * ) urlParams
              insideKey:( nullable NSString * ) nameObjectKey
               forField:( nullable NSString * ) strFieldName
           toEqualValue:( nullable id ) valToEqual
          orErrorValues:( nullable NSArray * ) arrErrorValues
                 thenDo:( nullable void ( ^ ) ( bool isWithStatus, id _Nullable dicObjectValues ) ) doAfterWait;


@end




