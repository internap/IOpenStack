//
//  IOStackService.m
//  IOpenStack
//
//  Created by Bruno Morel on 2016-01-22.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import "IOStackService.h"

//TODO : Make a factory to allow auto-discovery of service provider and type and trigger instanciation of a child automatically from init of the parent object IOStackService
@implementation IOStackService
{
    NSURLSession *          _httpSession;
    NSMutableDictionary *   _dicActiveTasks;
    NSMutableDictionary *   _dicActiveSuccessBlocks;
    NSMutableDictionary *   _dicActiveFailureBlocks;
    NSMutableDictionary *   _cacheResponseData;
    NSMutableDictionary *   _dicHeadersValues;
    NSOperationQueue *      serviceQueue;

    BOOL                    debugON;
}

@synthesize serviceID;
@synthesize serviceType;
@synthesize versionMajor;
@synthesize versionMinor;
@synthesize nameProvider;

@synthesize urlPublic;
@synthesize urlAdmin;
@synthesize urlInternal;



- ( instancetype ) initProperties
{
    if (self = [super init])
    {
        debugON = NO;
        
        _dicActiveTasks         = [NSMutableDictionary dictionary];
        _dicActiveSuccessBlocks = [NSMutableDictionary dictionary];
        _dicActiveFailureBlocks = [NSMutableDictionary dictionary];
        _cacheResponseData      = [NSMutableDictionary dictionary];
        _dicHeadersValues       = [NSMutableDictionary dictionary];
        serviceQueue            = [[NSOperationQueue alloc] init];
        
        [_dicHeadersValues setValue:@"application/json" forKey:@"Accept"];
        [_dicHeadersValues setValue:@"application/json" forKey:@"Content-Type"];
    }
    return self;
}

- ( instancetype ) initWithPublicURL:( NSURL * ) urlServicePublic
                             andType:( NSString * ) strServiceType
                     andMajorVersion:( NSNumber * ) nMajorVersion
                     andMinorVersion:( NSNumber * ) nMinorVersion
                     andProviderName:( NSString * ) strProviderName
{
    if( self = [self initProperties] )
    {
        urlPublic           = urlServicePublic;
        serviceType         = strServiceType;
        versionMajor        = nMajorVersion;
        versionMinor        = nMinorVersion;
        nameProvider        = strProviderName;
        
    }
    return self;
}

- ( instancetype ) initWithPublicURL:( NSURL * ) urlServicePublic
                               andID:( NSString * ) uidServiceRetrieved
                             andType:( NSString * ) strServiceType
                     andMajorVersion:( NSNumber * ) nMajorVersion
                     andMinorVersion:( NSNumber * ) nMinorVersion
                     andProviderName:( NSString * ) strProviderName
{
    if( self = [self initWithPublicURL:urlServicePublic
                               andType:strServiceType
                       andMajorVersion:nMajorVersion
                       andMinorVersion:nMinorVersion
                       andProviderName:strProviderName] )
        serviceID      = uidServiceRetrieved;

    return self;
}


- ( instancetype ) initWithPublicURL:( NSURL * ) urlServicePublic
                               andID:( NSString * ) uidService
                             andType:( NSString * ) strServiceType
                     andMajorVersion:( NSNumber * ) nMajorVersion
                     andMinorVersion:( NSNumber * ) nMinorVersion
                      andInternalURL:( NSURL * ) urlServiceInternal
                         andAdminURL:( NSURL * ) urlServiceAdmin
                     andProviderName:( NSString * ) strProviderName
{
    if( self = [self initWithPublicURL:urlServicePublic
                                 andID:uidService
                               andType:strServiceType
                       andMajorVersion:nMajorVersion
                       andMinorVersion:nMinorVersion
                       andProviderName:strProviderName] )
    {
        urlInternal    = urlServiceInternal;
        urlAdmin       = urlServiceInternal;
    }
    
    return self;
}

- ( void ) activateDebug:( BOOL ) isActivated
{
    debugON = isActivated;
}

- ( NSString * ) taskUUIDForTask:( NSURLSessionTask * ) taskToGetUUID
                       inSession:( NSURLSession * ) sessToGetTaskUID
{
    NSString * strHTTPSessionID = [sessToGetTaskUID description];
    if( strHTTPSessionID == nil )
        strHTTPSessionID = [_httpSession description];
    
    NSString * uidDataTask = [[NSNumber numberWithUnsignedInteger:taskToGetUUID.taskIdentifier] stringValue];
    
    return [NSString stringWithFormat:@"%@%@", strHTTPSessionID, uidDataTask];
}

- ( void ) prepareSession
{
    if( _httpSession != nil )
        [_httpSession finishTasksAndInvalidate];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    [sessionConfiguration setHTTPAdditionalHeaders:_dicHeadersValues];

    if( serviceQueue != nil )
        _httpSession = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                     delegate:self
                                                delegateQueue:serviceQueue];
    else
        _httpSession = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                     delegate:self
                                                delegateQueue:[NSOperationQueue mainQueue]];
}

- ( void ) setResponseBlocksFor:( NSURLSessionDataTask * ) taskSessionData
          onServiceSuccessBlock:( void ( ^ ) ( NSString * uidTaskService, id responseObject, NSDictionary * dicResponseHeaders ) ) doOnSuccess
          onServiceFailureBlock:( void ( ^ ) ( NSString * uidTaskService, NSError * error, NSUInteger nHTTPStatus ) ) doOnFailure
{
    NSString * uidDataTask = [self taskUUIDForTask:taskSessionData inSession:nil];
    if( doOnSuccess != nil )
        [_dicActiveSuccessBlocks setValue:doOnSuccess
                                   forKey:uidDataTask];
    
    if( doOnFailure != nil )
        [_dicActiveFailureBlocks setValue:doOnFailure
                                   forKey:uidDataTask];
    
    [_dicActiveTasks setValue:self forKey:uidDataTask];
}

- ( void ) setResponseDelegateFor:( NSURLSessionDataTask * ) taskSessionData
                      andDelegate:( id<IOStackServiceDelegate> ) idDelegate
{
    NSString * uidDataTask = [self taskUUIDForTask:taskSessionData inSession:nil];
    if( idDelegate != nil )
        [_dicActiveTasks setValue:idDelegate
                           forKey:uidDataTask];
}

- ( void ) setHTTPHeader:( NSString * ) strHeaderString
               withValue:( NSString * ) strHeaderValue
{
    [_dicHeadersValues setValue:strHeaderValue forKey:strHeaderString];
    [self prepareSession];
}

- ( void ) setHTTPHeaderWithValues:( NSDictionary * ) dicHeaderValues
{
    if( dicHeaderValues == nil )
        return;
    
    [_dicHeadersValues addEntriesFromDictionary:dicHeaderValues];
    [self prepareSession];
}

- ( void ) setURLHeaders:( NSMutableURLRequest * ) urlreqCurrentRequest
{
    for( NSString * currentHeaderName in _dicHeadersValues )
        [urlreqCurrentRequest addValue:_dicHeadersValues[ currentHeaderName ]
                    forHTTPHeaderField:currentHeaderName];
    
    if( debugON ) NSLog( @"-[IOStackFramework DEBUG]- Setting up Headers with values %@", _dicHeadersValues );
}


#pragma mark - HTTP REST manager
-( NSURLSessionDataTask * ) serviceGET:( NSString * ) urnResource
                            withParams:( NSDictionary * ) dicParams
{
    if( _httpSession == nil )
        [self prepareSession];
    
    NSURL * urlFullResource = [urlPublic URLByAppendingPathComponent:urnResource];
    NSURLComponents * compFinalURLQuery = [NSURLComponents componentsWithURL:urlFullResource
                                                     resolvingAgainstBaseURL:YES];
    
    if( dicParams != nil && [dicParams count] > 0 )
    {
        NSMutableArray *queryItems = [NSMutableArray array];
        for( NSString * paramName in dicParams )
            [queryItems addObject:[NSURLQueryItem queryItemWithName:paramName value:[dicParams valueForKey:paramName]]];
        
        [compFinalURLQuery setQueryItems:queryItems];
    }
    
    if( debugON ) NSLog( @"-[IOStackFramework DEBUG]- HTTP GET - %@", [compFinalURLQuery URL] );
    
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:[compFinalURLQuery URL]];
    
    [self setURLHeaders:urlRequest];
    
    return [_httpSession dataTaskWithRequest:urlRequest];
}

-( NSUInteger ) serviceGET:( NSString * ) urnResource
                withParams:( NSDictionary * ) dicParams
          onServiceSuccess:( void ( ^ ) ( NSString * uidTaskService, id responseObject, NSDictionary * dicResponseHeaders ) ) doOnSuccess
          onServiceFailure:( void ( ^ ) ( NSString * uidTaskService, NSError * error, NSUInteger nHTTPStatus ) ) doOnFailure
{
    NSURLSessionDataTask * taskSessionData = [self serviceGET:urnResource
                                                   withParams:dicParams];
    
    [self setResponseBlocksFor:taskSessionData
         onServiceSuccessBlock:doOnSuccess
         onServiceFailureBlock:doOnFailure];
    
    [taskSessionData resume];
    
    return taskSessionData.taskIdentifier;
}

-( NSUInteger ) serviceGET:( NSString * ) urnResource
                withParams:( NSDictionary * ) dicParams
               andDelegate:( id<IOStackServiceDelegate> ) idDelegate
{
    NSURLSessionDataTask * taskSessionData = [self serviceGET:urnResource
                                                   withParams:dicParams];
    [self setResponseDelegateFor:taskSessionData
                     andDelegate:idDelegate];
    
    [taskSessionData resume];
    
    return [taskSessionData taskIdentifier];
}

-( NSURLSessionDataTask * ) serviceHEAD:( NSString * ) urnResource
                             withParams:( NSDictionary * ) dicParams
{
    if( _httpSession == nil )
        [self prepareSession];
    
    NSURL * urlFullResource = [urlPublic URLByAppendingPathComponent:urnResource];
    NSURLComponents * compFinalURLQuery = [NSURLComponents componentsWithURL:urlFullResource
                                                     resolvingAgainstBaseURL:YES];
    
    if( dicParams != nil && [dicParams count] > 0 )
    {
        NSMutableArray *queryItems = [NSMutableArray array];
        for( NSString * paramName in dicParams )
            [queryItems addObject:[NSURLQueryItem queryItemWithName:paramName value:[dicParams valueForKey:paramName]]];
        
        [compFinalURLQuery setQueryItems:queryItems];
    }
    
    if( debugON ) NSLog( @"-[IOStackFramework DEBUG]- HTTP HEAD - %@", [compFinalURLQuery URL] );
    
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:[compFinalURLQuery URL]];
    
    [self setURLHeaders:urlRequest];
    [urlRequest setHTTPMethod:@"HEAD"];
    
    return [_httpSession dataTaskWithRequest:urlRequest];
}

-( NSUInteger ) serviceHEAD:( NSString * ) urnResource
                 withParams:( NSDictionary * ) dicParams
           onServiceSuccess:( void ( ^ ) ( NSString * uidTaskService, id responseObject, NSDictionary * dicResponseHeaders ) ) doOnSuccess
           onServiceFailure:( void ( ^ ) ( NSString * uidTaskService, NSError * error, NSUInteger nHTTPStatus ) ) doOnFailure
{
    NSURLSessionDataTask * taskSessionData = [self serviceHEAD:urnResource
                                                    withParams:dicParams];
    
    [self setResponseBlocksFor:taskSessionData
         onServiceSuccessBlock:doOnSuccess
         onServiceFailureBlock:doOnFailure];
    
    [taskSessionData resume];
    
    return taskSessionData.taskIdentifier;
}

-( NSUInteger ) serviceHEAD:( NSString * ) urnResource
                 withParams:( NSDictionary * ) dicParams
                andDelegate:( id<IOStackServiceDelegate> ) idDelegate
{
    NSURLSessionDataTask * taskSessionData = [self serviceHEAD:urnResource
                                                    withParams:dicParams];
    [self setResponseDelegateFor:taskSessionData
                     andDelegate:idDelegate];
    
    [taskSessionData resume];
    
    return [taskSessionData taskIdentifier];
}

-( NSURLSessionDataTask * ) servicePOST:( NSString * ) urnResource
                               withData:( NSData * ) dataForPOST
{
    if( _httpSession == nil )
        [self prepareSession];
    
    NSURL * urlFullResource = [urlPublic URLByAppendingPathComponent:urnResource];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:urlFullResource];
    
    [urlRequest setHTTPMethod:@"POST"];
    
    [self setURLHeaders:urlRequest];
    
    if( dataForPOST != nil )
        [urlRequest setHTTPBody:dataForPOST];
    
    if( debugON )
        NSLog( @"-[IOStackFramework DEBUG]- HTTP POST - %@ - with data : %@",
                        [urlRequest URL],
                        [NSJSONSerialization JSONObjectWithData:dataForPOST
                                                        options:0
                                                          error:nil] );
    
    return [_httpSession dataTaskWithRequest:urlRequest];
}

-( NSUInteger ) servicePOST:( NSString * ) urnResource
                withRawData:( NSData * ) datRaw
           onServiceSuccess:( void ( ^ ) ( NSString * uidTaskService, id responseObject, NSDictionary * dicResponseHeaders ) ) doOnSuccess
           onServiceFailure:( void ( ^ ) ( NSString * uidTaskService, NSError * error, NSUInteger nHTTPStatus ) ) doOnFailure
{
    NSURLSessionDataTask * taskSessionData = [self servicePOST:urnResource
                                                      withData:datRaw];
    
    [self setResponseBlocksFor:taskSessionData
         onServiceSuccessBlock:doOnSuccess
         onServiceFailureBlock:doOnFailure];
    
    [taskSessionData resume];
    
    return [taskSessionData taskIdentifier];
}

-( NSUInteger ) servicePOST:( NSString * ) urnResource
                withRawData:( NSData * ) datRaw
                andDelegate:( id<IOStackServiceDelegate> ) idDelegate
{
    NSURLSessionDataTask * taskSessionData = [self servicePOST:urnResource
                                                      withData:datRaw];
    [self setResponseDelegateFor:taskSessionData
                     andDelegate:idDelegate];
    
    [taskSessionData resume];
    
    return [taskSessionData taskIdentifier];
}

-( NSUInteger ) servicePOST:( NSString * ) urnResource
                 withParams:( NSDictionary * ) dicParams
           onServiceSuccess:( void ( ^ ) ( NSString * uidTaskService, id responseObject, NSDictionary * dicResponseHeaders ) ) doOnSuccess
           onServiceFailure:( void ( ^ ) ( NSString * uidTaskService, NSError * error, NSUInteger nHTTPStatus ) ) doOnFailure
{
    NSError * error;
    NSData * jsonData = nil;
    
    if( dicParams )
        jsonData = [NSJSONSerialization dataWithJSONObject:dicParams
                                                   options:0
                                                     error:&error];
    if( error != nil )
        NSLog(@"Got an error: %@", error);
    
    return [self servicePOST:urnResource
                 withRawData:jsonData
            onServiceSuccess:doOnSuccess
            onServiceFailure:doOnFailure];
}

-( NSUInteger ) servicePOST:( NSString * ) urnResource
                 withParams:( NSDictionary * ) dicParams
                andDelegate:( id<IOStackServiceDelegate> ) idDelegate
{
    NSError * error;
    NSData * jsonData = nil;
    
    if( dicParams )
        jsonData = [NSJSONSerialization dataWithJSONObject:dicParams
                                                   options:0
                                                     error:&error];
    if( error != nil )
        NSLog(@"Got an error: %@", error);
    
    return [self servicePOST:urnResource
                 withRawData:jsonData
                 andDelegate:idDelegate];
}

-( NSURLSessionDataTask * ) servicePUT:( NSString * ) urnResource
                              withData:( NSData * ) dataForPUT
{
    if( _httpSession == nil )
        [self prepareSession];
    
    NSURL * urlFullResource = [urlPublic URLByAppendingPathComponent:urnResource];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:urlFullResource];
    
    [urlRequest setHTTPMethod:@"PUT"];
    
    [self setURLHeaders:urlRequest];
    
    if( dataForPUT != nil )
        [urlRequest setHTTPBody:dataForPUT];
    
    if( debugON )
        NSLog( @"-[IOStackFramework DEBUG]- HTTP PUT - %@ - with data : %@",
                        [urlRequest URL],
                        [NSJSONSerialization JSONObjectWithData:dataForPUT
                                                        options:0
                                                          error:nil] );
    
    return [_httpSession dataTaskWithRequest:urlRequest];
}

-( NSUInteger ) servicePUT:( NSString * ) urnResource
               withRawData:( NSData * ) datRaw
               andDelegate:( id<IOStackServiceDelegate> ) idDelegate
{
    NSURLSessionDataTask * taskSessionData = [self servicePUT:urnResource
                                                     withData:datRaw];
    
    [self setResponseDelegateFor:taskSessionData
                     andDelegate:idDelegate];
    
    [taskSessionData resume];
    
    return [taskSessionData taskIdentifier];
}

-( NSUInteger ) servicePUT:( NSString * ) urnResource
               withRawData:( NSData * ) datRaw
          onServiceSuccess:( void ( ^ ) ( NSString * uidTaskService, id responseObject, NSDictionary * dicResponseHeaders ) ) doOnSuccess
          onServiceFailure:( void ( ^ ) ( NSString * uidTaskService, NSError * error, NSUInteger nHTTPStatus ) ) doOnFailure
{
    NSURLSessionDataTask * taskSessionData = [self servicePUT:urnResource
                                                     withData:datRaw];
    
    [self setResponseBlocksFor:taskSessionData
         onServiceSuccessBlock:doOnSuccess
         onServiceFailureBlock:doOnFailure];
    
    [taskSessionData resume];
    
    return [taskSessionData taskIdentifier];
}

-( NSUInteger ) servicePUT:( NSString * ) urnResource
                withParams:( NSDictionary * ) dicParams
               andDelegate:( id<IOStackServiceDelegate> ) idDelegate
{
    NSError * error;
    NSData * jsonData = nil;
    
    if( dicParams )
        jsonData = [NSJSONSerialization dataWithJSONObject:dicParams
                                                   options:0
                                                     error:&error];
    if( error != nil )
        NSLog(@"Got an error: %@", error);
    
    return [self servicePUT:urnResource
                withRawData:jsonData
                andDelegate:idDelegate];
}

-( NSUInteger ) servicePUT:( NSString * ) urnResource
                withParams:( NSDictionary * ) dicParams
          onServiceSuccess:( void ( ^ ) ( NSString * uidTaskService, id responseObject, NSDictionary * dicResponseHeaders ) ) doOnSuccess
          onServiceFailure:( void ( ^ ) ( NSString * uidTaskService, NSError * error, NSUInteger nHTTPStatus ) ) doOnFailure
{
    NSError * error;
    NSData * jsonData = nil;
    
    if( dicParams )
        jsonData = [NSJSONSerialization dataWithJSONObject:dicParams
                                                   options:0
                                                     error:&error];
    
    if( error != nil )
        NSLog(@"Got an error: %@", error);
    
    return [self servicePUT:urnResource
                withRawData:jsonData
           onServiceSuccess:doOnSuccess
           onServiceFailure:doOnFailure];
}

-( NSURLSessionDataTask * ) servicePATCH:( NSString * ) urnResource
                                withData:( NSData * ) dataForPATCH
{
    if( _httpSession == nil )
        [self prepareSession];
    
    NSURL * urlFullResource = [urlPublic URLByAppendingPathComponent:urnResource];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:urlFullResource];
    
    [urlRequest setHTTPMethod:@"PATCH"];
    
    [self setURLHeaders:urlRequest];
    
    if( dataForPATCH != nil )
        [urlRequest setHTTPBody:dataForPATCH];
    
    if( debugON )
        NSLog( @"-[IOStackFramework DEBUG]- HTTP PATCH - %@ - with data : %@",
              [urlRequest URL],
              [NSJSONSerialization JSONObjectWithData:dataForPATCH
                                              options:0
                                                error:nil] );
    
    return [_httpSession dataTaskWithRequest:urlRequest];
}

-( NSUInteger ) servicePATCH:( NSString * ) urnResource
                 withRawData:( NSData * ) datRaw
                 andDelegate:( id<IOStackServiceDelegate> ) idDelegate
{
    NSURLSessionDataTask * taskSessionData = [self servicePATCH:urnResource
                                                       withData:datRaw];
    
    [self setResponseDelegateFor:taskSessionData
                     andDelegate:idDelegate];
    
    [taskSessionData resume];
    
    return [taskSessionData taskIdentifier];
}

-( NSUInteger ) servicePATCH:( NSString * ) urnResource
                 withRawData:( NSData * ) datRaw
            onServiceSuccess:( void ( ^ ) ( NSString * uidTaskService, id responseObject, NSDictionary * dicResponseHeaders ) ) doOnSuccess
            onServiceFailure:( void ( ^ ) ( NSString * uidTaskService, NSError * error, NSUInteger nHTTPStatus ) ) doOnFailure
{
    NSURLSessionDataTask * taskSessionData = [self servicePATCH:urnResource
                                                       withData:datRaw];
    
    [self setResponseBlocksFor:taskSessionData
         onServiceSuccessBlock:doOnSuccess
         onServiceFailureBlock:doOnFailure];
    
    [taskSessionData resume];
    
    return [taskSessionData taskIdentifier];
}

-( NSUInteger ) servicePATCH:( NSString * ) urnResource
                  withParams:( NSDictionary * ) dicParams
                 andDelegate:( id<IOStackServiceDelegate> ) idDelegate
{
    NSError * error;
    NSData * jsonData = nil;
    
    if( dicParams )
        jsonData = [NSJSONSerialization dataWithJSONObject:dicParams
                                                   options:0
                                                     error:&error];
    if( error != nil )
        NSLog(@"Got an error: %@", error);
    
    return [self servicePATCH:urnResource
                  withRawData:jsonData
                  andDelegate:idDelegate];
}

-( NSUInteger ) servicePATCH:( NSString * ) urnResource
                  withParams:( NSDictionary * ) dicParams
            onServiceSuccess:( void ( ^ ) ( NSString * uidTaskService, id responseObject, NSDictionary * dicResponseHeaders ) ) doOnSuccess
            onServiceFailure:( void ( ^ ) ( NSString * uidTaskService, NSError * error, NSUInteger nHTTPStatus ) ) doOnFailure
{
    NSError * error;
    NSData * jsonData = nil;
    
    if( dicParams )
        jsonData = [NSJSONSerialization dataWithJSONObject:dicParams
                                                   options:0
                                                     error:&error];
    
    if( error != nil )
        NSLog(@"Got an error: %@", error);
    
    return [self servicePATCH:urnResource
                  withRawData:jsonData
             onServiceSuccess:doOnSuccess
             onServiceFailure:doOnFailure];
}

-( NSURLSessionDataTask * ) serviceDELETE:( NSString * ) urnResource
{
    if( _httpSession == nil )
        [self prepareSession];
    
    NSURL * urlFullResource = [urlPublic URLByAppendingPathComponent:urnResource];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:urlFullResource];
    
    [urlRequest setHTTPMethod:@"DELETE"];
    
    if( debugON ) NSLog( @"-[IOStackFramework DEBUG]- HTTP DELETE - %@", [urlRequest URL] );
    
    return [_httpSession dataTaskWithRequest:urlRequest];
}

-( NSUInteger ) serviceDELETE:( NSString * ) urnResource
                  andDelegate:( id<IOStackServiceDelegate> ) idDelegate
{
    NSURLSessionDataTask * taskSessionData = [self serviceDELETE:urnResource];
    
    [self setResponseDelegateFor:taskSessionData
                     andDelegate:idDelegate];
    
    [taskSessionData resume];
    
    return [taskSessionData taskIdentifier];
}

-( NSUInteger ) serviceDELETE:( NSString * ) urnResource
             onServiceSuccess:( void ( ^ ) ( NSString * uidTaskService, id responseObject, NSDictionary * dicResponseHeaders ) ) doOnSuccess
             onServiceFailure:( void ( ^ ) ( NSString * uidTaskService, NSError * error, NSUInteger nHTTPStatus ) ) doOnFailure
{
    NSURLSessionDataTask * taskSessionData = [self serviceDELETE:urnResource];
    
    [self setResponseBlocksFor:taskSessionData
         onServiceSuccessBlock:doOnSuccess
         onServiceFailureBlock:doOnFailure];
    
    [taskSessionData resume];
    
    return [taskSessionData taskIdentifier];
}


#pragma mark - NSURLSessionDelegate
- ( void ) URLSession:( NSURLSession * ) session
             dataTask:( NSURLSessionDataTask * ) taskData
       didReceiveData:( NSData * ) data
{
    NSString * uidTaskSession = [self taskUUIDForTask:taskData inSession:session];
    NSMutableData * cachedResponseDataForSession = [_cacheResponseData valueForKey:uidTaskSession];
    
    //NSLog(@"%@", [[NSString alloc] initWithData:cachedResponseDataForSession encoding:NSUTF8StringEncoding]);
    if( !cachedResponseDataForSession )
    {
        cachedResponseDataForSession = [NSMutableData dataWithData:data];
        [_cacheResponseData setValue:cachedResponseDataForSession
                              forKey:uidTaskSession];
    }
    else
        [cachedResponseDataForSession appendData:data];
}

- ( void ) URLSession:( NSURLSession * ) session
                 task:( NSURLSessionTask * ) taskSession
 didCompleteWithError:( NSError * ) error
{
    NSString * uidTaskSession = [self taskUUIDForTask:taskSession inSession:session];
    id<IOStackServiceDelegate> idDelegate = [_dicActiveTasks valueForKey:uidTaskSession];
    
    NSHTTPURLResponse * response = ( NSHTTPURLResponse * )taskSession.response;
    if( error != nil )
    {
        if( idDelegate != nil )
            [idDelegate onServiceFailure:uidTaskSession
                               withError:error
                       andResponseStatus:[response statusCode]];
        //NSLog(@"%@ failed: %@", taskSession.originalRequest.URL, error);
        return;
    }
    
    NSMutableData * cachedResponseData = [_cacheResponseData valueForKey:uidTaskSession];
    if( !cachedResponseData )
        NSLog(@"No data in response");
    
    NSDictionary * dicResponseSerialized = nil;
    if( cachedResponseData != nil )
        dicResponseSerialized = [NSJSONSerialization JSONObjectWithData:cachedResponseData
                                                                options:0
                                                                  error:nil];
    
    if( debugON ) NSLog( @"-[IOStackFramework DEBUG]- HTTP response for %@ - with data : %@", [response URL], dicResponseSerialized );
    
    if( [response statusCode] < 200 ||
       [response statusCode] >= 300 )
    {
        if( idDelegate != nil )
            [idDelegate onServiceFailure:uidTaskSession
                               withError:error
                       andResponseStatus:[response statusCode]];
        return;
    }
    
    if( dicResponseSerialized == nil )
        dicResponseSerialized = @{ @"response" : [[NSString alloc] initWithData:cachedResponseData
                                                    encoding:NSUTF8StringEncoding] };
    
    if( idDelegate != nil )
        [idDelegate onServiceSuccess:uidTaskSession
                        withResponse:dicResponseSerialized
                  andResponseHeaders:[response allHeaderFields]];
    
    [_dicActiveTasks removeObjectForKey:uidTaskSession];
}


#pragma mark - RESTful calls management
- ( void ) readRawResource:( NSString * ) urlResource
                withHeader:( NSDictionary * ) dicHeaderFieldValue
              andUrlParams:( NSDictionary * ) paramsURL
                 insideKey:( NSString * ) nameObjectKey
                    thenDo:( void ( ^ ) ( NSDictionary * dicObjectFound, id dataResponse ) ) doWithReadResults
{
    [self setHTTPHeaderWithValues:dicHeaderFieldValue];
    
    [self serviceGET:urlResource
          withParams:paramsURL
    onServiceSuccess:^( NSString * uidServiceTask, id responseObject, NSDictionary * dicHeaderResponse ) {
        if( doWithReadResults != nil )
        {
            if( responseObject == nil )
                doWithReadResults( nil, nil );
            
            else if( nameObjectKey == nil &&
                    [responseObject isKindOfClass:[NSDictionary class]] &&
                    [responseObject count] == 1)
                doWithReadResults( responseObject, responseObject );
            
            else if( [responseObject isKindOfClass:[NSDictionary class]] &&
                    [responseObject count] == 1 &&
                    [responseObject valueForKey:nameObjectKey] != nil )
                doWithReadResults( [responseObject valueForKey:nameObjectKey], responseObject );
            
            else
                doWithReadResults( nil, responseObject );
        }
    }
    onServiceFailure:^( NSString * uidServiceTask, NSError * error, NSUInteger nHTTPStatus ) {
        //NSLog( @"task %@ failed with error : %@", uidServiceTask, error );
        if( doWithReadResults != nil )
            doWithReadResults( nil, nil );
    }];
}

- ( void ) readResource:( NSString * ) urlResource
             withHeader:( NSDictionary * ) dicHeaderFieldValue
           andUrlParams:( NSDictionary * ) paramsURL
              insideKey:( NSString * ) nameObjectKey
                 thenDo:( void ( ^ ) ( NSDictionary * dicObjectFound, id dataResponse ) ) doWithReadResults
{
    [self readRawResource:urlResource
               withHeader:dicHeaderFieldValue
             andUrlParams:paramsURL
                insideKey:nameObjectKey
                   thenDo:doWithReadResults];
}

- ( void ) readResource:( NSString * ) urlResource
             withHeader:( NSDictionary * ) dicHeaderFieldValue
           andUrlParams:( NSDictionary * ) paramsURL
                 thenDo:( void ( ^ ) ( NSDictionary * dicObjectFound, id dataResponse ) ) doWithReadResults
{
    [self readResource:urlResource
            withHeader:dicHeaderFieldValue
          andUrlParams:paramsURL
             insideKey:nil
                thenDo:doWithReadResults];
}

- ( void ) metadataResource:( NSString * ) urlResource
                 withHeader:( NSDictionary * ) dicHeaderFieldValue
               andUrlParams:( NSDictionary * ) paramsURL
                     thenDo:( void ( ^ ) ( NSDictionary * headerValues, id dataResponse ) ) doWithMetadata
{
    [self setHTTPHeaderWithValues:dicHeaderFieldValue];
    
    [self serviceHEAD:urlResource
     withParams:paramsURL
     onServiceSuccess:^(NSString * _Nonnull uidTaskService, id  _Nullable responseObject, NSDictionary * _Nullable dicResponseHeaders)
    {
        if( doWithMetadata != nil )
        {
            if( responseObject == nil )
                doWithMetadata( nil, nil );
            
            else
                doWithMetadata( dicResponseHeaders, responseObject );
        }

     }
     onServiceFailure:^(NSString * _Nonnull uidTaskService, NSError * _Nullable error, NSUInteger nHTTPStatus)
    {
        //NSLog( @"task %@ failed with error : %@", uidServiceTask, error );
        if( doWithMetadata != nil )
            doWithMetadata( nil, nil );
     }];
}

- ( void ) listResource:( NSString * ) urlResource
             withHeader:( NSDictionary * ) dicHeaderFieldValue
           andUrlParams:( NSDictionary * ) paramsURL
              insideKey:( NSString * ) nameObjectKey
                 thenDo:( void ( ^ ) ( NSArray * arrFound, id dataResponse ) ) doWithListResults
{
    [self setHTTPHeaderWithValues:dicHeaderFieldValue];
    
    [self serviceGET:urlResource
          withParams:paramsURL
    onServiceSuccess:^( NSString * uidServiceTask, id responseObject, NSDictionary * dicHeaderResponse ) {
        if( doWithListResults != nil &&
           responseObject != nil )
        {
            NSArray * arrResponseConverted = nil;
            
            if( nameObjectKey == nil &&
                [responseObject isKindOfClass:[NSArray class]] )
                arrResponseConverted = responseObject;
            
            else if( [responseObject isKindOfClass:[NSDictionary class]] &&
                    [responseObject count] >= 1 &&
                    [responseObject valueForKey:nameObjectKey] != nil )
                    arrResponseConverted = [responseObject valueForKey:nameObjectKey];
                
            else
                arrResponseConverted = nil;
            
            doWithListResults( arrResponseConverted, responseObject );
        }
        else if( doWithListResults != nil )
            doWithListResults( nil, nil );
    }
    onServiceFailure:^( NSString * uidServiceTask, NSError * error, NSUInteger nHTTPStatus ) {
        //NSLog( @"task %@ failed with error : %@", uidServiceTask, error );
        if( doWithListResults != nil )
            doWithListResults( nil, nil );
    }];

}

- ( void ) listResource:( NSString * ) urlResource
             withHeader:( NSDictionary * ) dicHeaderFieldValue
           andUrlParams:( NSDictionary * ) paramsURL
                 thenDo:( void ( ^ ) ( NSArray * arrFound, id dataResponse ) ) doWithListResults
{
    [self listResource:urlResource
            withHeader:dicHeaderFieldValue
          andUrlParams:paramsURL
             insideKey:nil
                thenDo:doWithListResults];
}

- ( void ) createResource:( NSString * ) urlResource
               withHeader:( NSDictionary * ) dicHeaderFieldValue
               andRawData:( NSData * ) datRaw
                   thenDo:( void ( ^ ) ( NSDictionary * dicResponseHeaders, id idFullResponse ) ) doWithCreateResults
{
    [self setHTTPHeaderWithValues:dicHeaderFieldValue];
    
    [self servicePOST:urlResource
          withRawData:datRaw
     onServiceSuccess:^( NSString * uidServiceTask, id responseObject, NSDictionary * dicResponseHeader ) {
         if( doWithCreateResults )
             doWithCreateResults( dicResponseHeader, responseObject );
     }
     onServiceFailure:^( NSString * uidServiceTask, NSError * error, NSUInteger nHTTPStatus ) {
         //NSLog( @"task %@ failed with error : %@", uidServiceTask, error );
         if( doWithCreateResults != nil )
             doWithCreateResults( nil, nil );
     }];
}

- ( void ) createResource:( NSString * ) urlResource
               withHeader:( NSDictionary * ) dicHeaderFieldValue
             andUrlParams:( NSDictionary * ) paramsURL
                   thenDo:( void ( ^ ) ( NSDictionary * dicResponseHeaders, id idFullResponse ) ) doWithCreateResults
{
    [self setHTTPHeaderWithValues:dicHeaderFieldValue];
    
    [self servicePOST:urlResource
           withParams:paramsURL
     onServiceSuccess:^( NSString * uidServiceTask, id responseObject, NSDictionary * dicResponseHeader ) {
         if( doWithCreateResults )
             doWithCreateResults( dicResponseHeader, responseObject );
     }
     onServiceFailure:^( NSString * uidServiceTask, NSError * error, NSUInteger nHTTPStatus ) {
         //NSLog( @"task %@ failed with error : %@", uidServiceTask, error );
         if( doWithCreateResults != nil )
             doWithCreateResults( nil, nil );
     }];
}

- ( void ) replaceResource:( NSString * ) urlResource
                withHeader:( NSDictionary * ) dicHeaderFieldValue
                andRawData:( NSData * ) datRaw
                    thenDo:( void ( ^ ) ( NSDictionary * dicResponseHeader, id idFullResponse ) ) doWithCreateResults
{
    [self setHTTPHeaderWithValues:dicHeaderFieldValue];
    
    [self servicePUT:urlResource
         withRawData:datRaw
    onServiceSuccess:^( NSString * uidServiceTask, id responseObject, NSDictionary * dicResponseHeader ) {
        if( doWithCreateResults )
            doWithCreateResults( dicResponseHeader, responseObject );
    }
    onServiceFailure:^( NSString * uidServiceTask, NSError * error, NSUInteger nHTTPStatus ) {
        //NSLog( @"task not valid : %@", error );
        if( doWithCreateResults != nil )
            doWithCreateResults( nil, nil );
    }];
}

- ( void ) replaceResource:( NSString * ) urlResource
                withHeader:( NSDictionary * ) dicHeaderFieldValue
              andUrlParams:( NSDictionary * ) paramsURL
                    thenDo:( void ( ^ ) ( NSDictionary * dicResponseHeader, id idFullResponse ) ) doWithCreateResults
{
    [self setHTTPHeaderWithValues:dicHeaderFieldValue];
    
    [self servicePUT:urlResource
          withParams:paramsURL
    onServiceSuccess:^( NSString * uidServiceTask, id responseObject, NSDictionary * dicResponseHeader ) {
        if( doWithCreateResults )
            doWithCreateResults( dicResponseHeader, responseObject );
    }
    onServiceFailure:^( NSString * uidServiceTask, NSError * error, NSUInteger nHTTPStatus ) {
        //NSLog( @"task not valid : %@", error );
        if( doWithCreateResults != nil )
            doWithCreateResults( nil, nil );
    }];
}


- ( void ) updateResource:( NSString * ) urlResource
               withHeader:( NSDictionary * ) dicHeaderFieldValue
               andRawData:( NSData * ) datRaw
                   thenDo:( void ( ^ ) ( NSDictionary * dicResponseHeader, id idFullResponse ) ) doWithCreateResults
{
    [self setHTTPHeaderWithValues:dicHeaderFieldValue];
    
    [self servicePATCH:urlResource
           withRawData:datRaw
      onServiceSuccess:^( NSString * uidServiceTask, id responseObject, NSDictionary * dicResponseHeader ) {
        if( doWithCreateResults )
            doWithCreateResults( dicResponseHeader, responseObject );
    }
    onServiceFailure:^( NSString * uidServiceTask, NSError * error, NSUInteger nHTTPStatus ) {
        //NSLog( @"task not valid : %@", error );
        if( doWithCreateResults != nil )
            doWithCreateResults( nil, nil );
    }];
}

- ( void ) updateResource:( NSString * ) urlResource
               withHeader:( NSDictionary * ) dicHeaderFieldValue
             andUrlParams:( NSDictionary * ) paramsURL
                   thenDo:( void ( ^ ) ( NSDictionary * dicResponseHeader, id idFullResponse ) ) doWithCreateResults
{
    [self setHTTPHeaderWithValues:dicHeaderFieldValue];
    
    [self servicePATCH:urlResource
            withParams:paramsURL
      onServiceSuccess:^( NSString * uidServiceTask, id responseObject, NSDictionary * dicResponseHeader ) {
        if( doWithCreateResults )
            doWithCreateResults( dicResponseHeader, responseObject );
    }
      onServiceFailure:^( NSString * uidServiceTask, NSError * error, NSUInteger nHTTPStatus ) {
        //NSLog( @"task not valid : %@", error );
        if( doWithCreateResults != nil )
            doWithCreateResults( nil, nil );
    }];
}

- ( void ) deleteResource:( NSString * ) urlResource
               withHeader:( NSDictionary * ) dicHeaderFieldValue
                   thenDo:( void ( ^ ) ( NSDictionary * dicResults, id idFullResponse ) ) doWithDeleteResults
{
    [self setHTTPHeaderWithValues:dicHeaderFieldValue];
    
    [self serviceDELETE:urlResource
       onServiceSuccess:^( NSString * uidServiceTask, id responseObject, NSDictionary * dicResponseHeaders ) {
           if( doWithDeleteResults )
               doWithDeleteResults( dicResponseHeaders, responseObject );
       }
       onServiceFailure:^( NSString * uidServiceTask, NSError * error, NSUInteger nHTTPStatus ) {
           //NSLog( @"task not valid : %@", error );
           if( doWithDeleteResults != nil )
               doWithDeleteResults( nil, nil );
       }];
}


#pragma mark - IOStackServiceDelegate
- ( void ) onServiceSuccess:( nonnull NSString * ) uidServiceTask
               withResponse:( nonnull id ) idResponse
         andResponseHeaders:( NSDictionary * ) dicReponseHeaders
{
    void ( ^ doOnSuccess ) ( NSString * uidServiceTask, id responseObject, NSDictionary * dicResponseHeaders ) = [_dicActiveSuccessBlocks valueForKey:uidServiceTask];
    
    if( doOnSuccess != nil )
        doOnSuccess( uidServiceTask, idResponse, dicReponseHeaders );
}

- ( void ) onServiceFailure:( nonnull NSString * ) uidServiceTask
                  withError:( nonnull NSError * ) error
          andResponseStatus:( NSUInteger ) nHTTPStatus
{
    void ( ^ doOnFailure ) ( NSString * uidServiceTask, NSError * error, NSUInteger nHTTPStatus ) = [_dicActiveFailureBlocks valueForKey:uidServiceTask];
    
    if( doOnFailure != nil )
        doOnFailure( uidServiceTask, error, nHTTPStatus );
}


#pragma mark - Thread safe refresh status / value loop mechanism
- ( void ) waitResource:( NSString * ) urlResource
          withUrlParams:( NSDictionary * ) paramsURL
              insideKey:( NSString * ) nameObjectKey
               forField:( NSString * ) strFieldName
           toEqualValue:( id ) valToEqual
          orErrorValues:( NSArray * ) arrErrorValues
          withFrequency:( NSTimeInterval ) tiFrequency
             andTimeout:( NSTimeInterval ) tiTimeout
                 thenDo:( void ( ^ ) ( bool isWithStatus ) ) doAfterWait
{
    NSMutableDictionary * dicUserInfo = [NSMutableDictionary dictionaryWithObject:urlResource forKey:@"urlResource"];
    
    if( paramsURL != nil )
        dicUserInfo[  @"urlParams" ] = paramsURL;
    
    if( nameObjectKey != nil )
        dicUserInfo[  @"nameObjectKey" ] = nameObjectKey;

    if( strFieldName != nil )
        dicUserInfo[  @"fieldToCheck" ] = strFieldName;
    
    if( valToEqual != nil )
        dicUserInfo[  @"valueToWaitFor" ] = valToEqual;
    
    if( arrErrorValues != nil )
        dicUserInfo[ @"arrErrorValues" ] = arrErrorValues;
    

    dicUserInfo[  @"dateStartedLooping" ]   = [NSDate date];
    dicUserInfo[  @"tiFrequency" ]          = [NSNumber numberWithDouble:tiFrequency];
    dicUserInfo[  @"tiTimeout" ]            = [NSNumber numberWithDouble:tiTimeout];
    dicUserInfo[  @"blockAfterWait" ]       = doAfterWait;
    
    NSTimer * timerLoopServerRefresh = [NSTimer scheduledTimerWithTimeInterval:tiFrequency
                                                                        target:self
                                                                      selector:@selector(loopRefreshResource:)
                                                                      userInfo:dicUserInfo
                                                                       repeats:NO];
    NSRunLoop * localRunLoop = [NSRunLoop currentRunLoop];
    [localRunLoop addTimer:timerLoopServerRefresh
                   forMode:NSRunLoopCommonModes];
    [localRunLoop run];
}

- ( void ) waitResource:( NSString * ) urlResource
          withUrlParams:( NSDictionary * ) paramsURL
              insideKey:( NSString * ) nameObjectKey
               forField:( NSString * ) strFieldName
           toEqualValue:( id ) valToEqual
          orErrorValues:( NSArray * ) arrErrorValues
                 thenDo:( void ( ^ ) ( bool isWithStatus ) ) doAfterWait
{
    [self waitResource:urlResource
         withUrlParams:paramsURL
             insideKey:nameObjectKey
              forField:strFieldName
          toEqualValue:valToEqual
         orErrorValues:arrErrorValues
         withFrequency:DEFAULT_APIREFRESH_FREQUENCY
            andTimeout:DEFAULT_APIREFRESH_TIMEOUT
                thenDo:doAfterWait];
}

- ( void ) loopRefreshResource:( NSTimer * ) timerLoopServerRefresh
{
    
    NSDictionary * dicUserInfo = [timerLoopServerRefresh userInfo];
    if( dicUserInfo == nil ||
       dicUserInfo[ @"urlResource" ] == nil ||
       dicUserInfo[ @"dateStartedLooping" ] == nil ||
       dicUserInfo[ @"tiTimeout" ] == nil  )
        return;
    
    NSString * urlResource                          = dicUserInfo[ @"urlResource" ];
    NSDictionary * urlParams                        = dicUserInfo[ @"urlParams" ];
    NSString * nameObjectKey                        = dicUserInfo[ @"nameObjectKey" ];
    NSString * strFieldName                         = dicUserInfo[ @"fieldToCheck" ];
    id valueToCheck                                 = dicUserInfo[ @"valueToWaitFor" ];
    NSArray * arrErrorValues                        = dicUserInfo[ @"arrErrorValues" ];
    NSDate * dateStarted                            = dicUserInfo[ @"dateStartedLooping" ];
    NSTimeInterval tiFrequency                      = [( NSNumber * )dicUserInfo[ @"tiFrequency" ] doubleValue];
    NSTimeInterval tiTimeout                        = [( NSNumber * )dicUserInfo[ @"tiTimeout" ] doubleValue];
    void ( ^doAfterWaitBlock )( bool isWithStatus ) = dicUserInfo[ @"blockAfterWait" ];
    
    [timerLoopServerRefresh invalidate];

    [self refreshResource:urlResource
            withUrlParams:urlParams
                insideKey:nameObjectKey
                   thenDo:^(id objResult, id idFullResponse)
    {
        //special case of delete of a resource that returns nothing in the body...
        //  ...if that's what we expect, then we're good
        if( strFieldName == nil && objResult == nil )
        {
            doAfterWaitBlock( YES );
            return;
        }
        
        if( objResult == nil ||
            ![objResult isKindOfClass:[NSDictionary class]] )
        {
            doAfterWaitBlock( NO );
            return;
        }
        
        id valRetrieved = [objResult valueForKey:strFieldName];
        if( arrErrorValues != nil &&
           [arrErrorValues containsObject:valRetrieved] )
        {
            doAfterWaitBlock( NO );
            return;
        }
        
        BOOL bHasReachedEquality = NO;
        
        if( [valRetrieved isKindOfClass:[NSString class]] )
            bHasReachedEquality = [(( NSString * ) valRetrieved) isEqualToString:valueToCheck];
        
        else if( [valRetrieved isKindOfClass:[NSNumber class]] )
            bHasReachedEquality = [(( NSNumber * ) valRetrieved) isEqualToNumber:valueToCheck];
        
        else if( [valRetrieved isKindOfClass:[NSDate class]] )
            bHasReachedEquality = [(( NSDate * ) valRetrieved) isEqualToDate:valueToCheck];
        
        else if( [valRetrieved isKindOfClass:[NSTimeZone class]] )
            bHasReachedEquality = [(( NSTimeZone * ) valRetrieved) isEqualToTimeZone:valueToCheck];
        
        else if( [valRetrieved isKindOfClass:[NSData class]] )
            bHasReachedEquality = [(( NSData * ) valRetrieved) isEqualToData:valueToCheck];
        
        else if( [valRetrieved isKindOfClass:[NSHashTable class]] )
            bHasReachedEquality = [(( NSHashTable * ) valRetrieved) isEqualToHashTable:valueToCheck];
        
        else if( [valRetrieved isKindOfClass:[NSIndexSet class]] )
            bHasReachedEquality = [(( NSIndexSet * ) valRetrieved) isEqualToIndexSet:valueToCheck];
        
        else if( [valRetrieved isKindOfClass:[NSOrderedSet class]] )
            bHasReachedEquality = [(( NSOrderedSet * ) valRetrieved) isEqualToOrderedSet:valueToCheck];
        
        else if( [valRetrieved isKindOfClass:[NSDictionary class]] )
            bHasReachedEquality = [(( NSDictionary * ) valRetrieved) isEqualToDictionary:valueToCheck];
        
        else if( [valRetrieved isKindOfClass:[NSSet class]] )
            bHasReachedEquality = [(( NSSet * ) valRetrieved) isEqualToSet:valueToCheck];
        
        else if( [valRetrieved isKindOfClass:[NSValue class]] )
            bHasReachedEquality = [(( NSValue * ) valRetrieved) isEqualToValue:valueToCheck];
        
        
        if( [dateStarted timeIntervalSinceNow] < tiTimeout &&
            !bHasReachedEquality )
        {
            NSTimer * timerLoopServerRefresh = [NSTimer scheduledTimerWithTimeInterval:tiFrequency
                                                                                target:self
                                                                              selector:@selector(loopRefreshResource:)
                                                                              userInfo:dicUserInfo
                                                                               repeats:NO];
            NSRunLoop * localRunLoop = [NSRunLoop currentRunLoop];
            [localRunLoop addTimer:timerLoopServerRefresh
                           forMode:NSRunLoopCommonModes];
            [localRunLoop run];
            return;
        }
        
        if( bHasReachedEquality )
            doAfterWaitBlock( YES );
        
        else
            doAfterWaitBlock( NO );
    }];
}


- ( void ) refreshResource:( NSString * ) urlServiceResource
             withUrlParams:( NSDictionary * ) paramsURL
                 insideKey:( NSString * ) nameObjectKey
                    thenDo:( void ( ^ ) ( id objResult, id idFullResponse ) ) doAfterRefresh
{
    [self readResource:urlServiceResource
            withHeader:nil
          andUrlParams:paramsURL
             insideKey:nameObjectKey
                thenDo:^( id objResult, id dataResponse)
     {
         if( doAfterRefresh != nil )
             doAfterRefresh( objResult, dataResponse );
     }];
}


@end
