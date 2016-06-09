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
    NSMutableDictionary *   _dicActiveAnswerBlocks;
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
        _dicActiveAnswerBlocks  = [NSMutableDictionary dictionary];
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
               onServiceAnswers:( void ( ^ ) ( NSString * uidTaskService, IOStackResponse * response ) ) doOnAnswer
{
    NSString * uidDataTask = [self taskUUIDForTask:taskSessionData inSession:nil];
    if( doOnAnswer != nil )
        [_dicActiveAnswerBlocks setValue:doOnAnswer
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
          onServiceAnswers:( void ( ^ ) ( NSString * uidTaskService, IOStackResponse * response ) ) doOnAnswer
{
    NSURLSessionDataTask * taskSessionData = [self serviceGET:urnResource
                                                   withParams:dicParams];
    
    [self setResponseBlocksFor:taskSessionData
              onServiceAnswers:doOnAnswer];
    
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
           onServiceAnswers:( void ( ^ ) ( NSString * uidTaskService, IOStackResponse * response ) ) doOnAnswer
{
    NSURLSessionDataTask * taskSessionData = [self serviceHEAD:urnResource
                                                    withParams:dicParams];
    
    [self setResponseBlocksFor:taskSessionData
              onServiceAnswers:doOnAnswer];
    
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
           onServiceAnswers:( void ( ^ ) ( NSString * uidTaskService, IOStackResponse * response ) ) doOnAnswer
{
    NSURLSessionDataTask * taskSessionData = [self servicePOST:urnResource
                                                      withData:datRaw];
    
    [self setResponseBlocksFor:taskSessionData
              onServiceAnswers:doOnAnswer];
    
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
           onServiceAnswers:( void ( ^ ) ( NSString * uidTaskService, IOStackResponse * response ) ) doOnAnswer
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
            onServiceAnswers:doOnAnswer];
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
          onServiceAnswers:( void ( ^ ) ( NSString * uidTaskService, IOStackResponse * response ) ) doOnAnswer
{
    NSURLSessionDataTask * taskSessionData = [self servicePUT:urnResource
                                                     withData:datRaw];
    
    [self setResponseBlocksFor:taskSessionData
              onServiceAnswers:doOnAnswer];
    
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
          onServiceAnswers:( void ( ^ ) ( NSString * uidTaskService, IOStackResponse * response ) ) doOnAnswer
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
           onServiceAnswers:doOnAnswer];
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
            onServiceAnswers:( void ( ^ ) ( NSString * uidTaskService, IOStackResponse * response ) ) doOnAnswer
{
    NSURLSessionDataTask * taskSessionData = [self servicePATCH:urnResource
                                                       withData:datRaw];
    
    [self setResponseBlocksFor:taskSessionData
              onServiceAnswers:doOnAnswer];
    
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
            onServiceAnswers:( void ( ^ ) ( NSString * uidTaskService, IOStackResponse * response ) ) doOnAnswer
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
             onServiceAnswers:doOnAnswer];
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
             onServiceAnswers:( void ( ^ ) ( NSString * uidTaskService, IOStackResponse * response ) ) doOnAnswer
{
    NSURLSessionDataTask * taskSessionData = [self serviceDELETE:urnResource];
    
    [self setResponseBlocksFor:taskSessionData
              onServiceAnswers:doOnAnswer];
    
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
    
    NSHTTPURLResponse * responseHTTP = ( NSHTTPURLResponse * )taskSession.response;
    
    NSMutableData * cachedResponseData = [_cacheResponseData valueForKey:uidTaskSession];
    if( !cachedResponseData )
        NSLog(@"No data in response");
    
    if( error != nil )
    {
        if( idDelegate != nil )
            [idDelegate onServiceAnswers:uidTaskSession
                            withResponse:[IOStackResponse initWithNonHTTPError:error
                                                                    andHeaders:[responseHTTP allHeaderFields]
                                                                    andContent:cachedResponseData]];
        //NSLog(@"%@ failed: %@", taskSession.originalRequest.URL, error);
        return;
    }
    
    
    NSDictionary * dicResponseSerialized = nil;
    if( cachedResponseData != nil )
        dicResponseSerialized = [NSJSONSerialization JSONObjectWithData:cachedResponseData
                                                                options:0
                                                                  error:nil];
    
    if( debugON ) NSLog( @"-[IOStackFramework DEBUG]- HTTP response for %@ - with data : %@", [responseHTTP URL], dicResponseSerialized );
    
    if( dicResponseSerialized == nil )
        dicResponseSerialized = @{ @"response" : [[NSString alloc] initWithData:cachedResponseData
                                                                       encoding:NSUTF8StringEncoding] };
    
    IOStackResponse * responseService = [IOStackResponse initWithStatus:[responseHTTP statusCode]
                                                             andHeaders:[responseHTTP allHeaderFields]
                                                             andContent:dicResponseSerialized];
    if( [responseHTTP statusCode] < 200 ||
        [responseHTTP statusCode] >= 300 )
    {
        if( idDelegate != nil )
            [idDelegate onServiceAnswers:uidTaskSession
                            withResponse:responseService];
        return;
    }
    
    if( idDelegate != nil )
        [idDelegate onServiceAnswers:uidTaskSession
                        withResponse:responseService];
    
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
     onServiceAnswers:^(NSString * uidTaskService, IOStackResponse * response ) {
         if( doWithReadResults == nil )
             return;
         
         if( [response failed] )
         {
             doWithReadResults( nil, nil );
             return;
         }
         
         if( response.responseContent == nil )
             doWithReadResults( nil, nil );
         
         else if( nameObjectKey == nil &&
                 [response.responseContent isKindOfClass:[NSDictionary class]] &&
                 [response.responseContent count] == 1)
             doWithReadResults( response.responseContent, response.responseContent );
         
         else if( [response.responseContent isKindOfClass:[NSDictionary class]] &&
                 [response.responseContent count] == 1 &&
                 [response.responseContent valueForKey:nameObjectKey] != nil )
             doWithReadResults( [response.responseContent valueForKey:nameObjectKey], response.responseContent );
         
         else
             doWithReadResults( nil, response.responseContent );
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
     onServiceAnswers:^(NSString * uidTaskService, IOStackResponse * response) {
         if( doWithMetadata == nil )
             return ;
         
         if( [response failed] )
         {
             doWithMetadata( nil, nil );
             return;
         }
         
         doWithMetadata( response.responseHeaders, response.responseContent );
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
     onServiceAnswers:^(NSString * uidTaskService, IOStackResponse * response) {
         if( doWithListResults == nil )
             return;
         
         if( [response failed] ||
                response.responseContent == nil )
         {
             doWithListResults( nil, nil );
             return;
         }
         
         NSArray * arrResponseConverted = nil;
             
         if( nameObjectKey == nil &&
            [response.responseContent isKindOfClass:[NSArray class]] )
             arrResponseConverted = response.responseContent;
         
         else if( [response.responseContent isKindOfClass:[NSDictionary class]] &&
                 [response.responseContent count] >= 1 &&
                 [response.responseContent valueForKey:nameObjectKey] != nil )
             arrResponseConverted = [response.responseContent valueForKey:nameObjectKey];
         
         else
             arrResponseConverted = nil;
         
         doWithListResults( arrResponseConverted, response.responseContent );
         
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
     onServiceAnswers:^(NSString * uidTaskService, IOStackResponse * response) {
         if( doWithCreateResults == nil )
             return;
         
         if( [response failed] )
         {
             doWithCreateResults( nil, nil );
             return;
         }
         
         doWithCreateResults( response.responseHeaders, response.responseContent );
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
     onServiceAnswers:^(NSString * uidTaskService, IOStackResponse * response) {
         if( doWithCreateResults == nil )
             return;
         
         if( [response failed] )
         {
             doWithCreateResults( nil, nil );
             return;
         }
         
         
         doWithCreateResults( response.responseHeaders, response.responseContent );
     }];
}

- ( void ) replaceResource:( NSString * ) urlResource
                withHeader:( NSDictionary * ) dicHeaderFieldValue
                andRawData:( NSData * ) datRaw
                    thenDo:( void ( ^ ) ( NSDictionary * dicResponseHeader, id idFullResponse ) ) doWithReplaceResults
{
    [self setHTTPHeaderWithValues:dicHeaderFieldValue];
    
    [self servicePUT:urlResource
         withRawData:datRaw
     onServiceAnswers:^(NSString * uidTaskService, IOStackResponse * response) {
         if( doWithReplaceResults == nil )
             return;
         
         if( [response failed] )
             doWithReplaceResults( nil, nil );
         
         doWithReplaceResults( response.responseHeaders, response.responseContent );
     }];
}

- ( void ) replaceResource:( NSString * ) urlResource
                withHeader:( NSDictionary * ) dicHeaderFieldValue
              andUrlParams:( NSDictionary * ) paramsURL
                    thenDo:( void ( ^ ) ( NSDictionary * dicResponseHeader, id idFullResponse ) ) doWithReplaceResults
{
    [self setHTTPHeaderWithValues:dicHeaderFieldValue];
    
    [self servicePUT:urlResource
          withParams:paramsURL
     onServiceAnswers:^(NSString * uidTaskService, IOStackResponse * response) {
         if( doWithReplaceResults == nil )
             return;
         
         if( [response failed ] )
         {
             doWithReplaceResults( nil, nil );
             return;
         }
         
         doWithReplaceResults( response.responseHeaders, response.responseContent );
     }];
}


- ( void ) updateResource:( NSString * ) urlResource
               withHeader:( NSDictionary * ) dicHeaderFieldValue
               andRawData:( NSData * ) datRaw
                   thenDo:( void ( ^ ) ( NSDictionary * dicResponseHeader, id idFullResponse ) ) doWithUpdateResults
{
    [self setHTTPHeaderWithValues:dicHeaderFieldValue];
    
    [self servicePATCH:urlResource
           withRawData:datRaw
     onServiceAnswers:^(NSString * uidTaskService, IOStackResponse * response) {
         if( doWithUpdateResults == nil )
             return;
         
         if( [response failed] )
         {
             doWithUpdateResults( nil, nil );
             return;
         }
         
         doWithUpdateResults( response.responseHeaders, response.responseContent );
     }];
}

- ( void ) updateResource:( NSString * ) urlResource
               withHeader:( NSDictionary * ) dicHeaderFieldValue
             andUrlParams:( NSDictionary * ) paramsURL
                   thenDo:( void ( ^ ) ( NSDictionary * dicResponseHeader, id idFullResponse ) ) doWithUpdateResults
{
    [self setHTTPHeaderWithValues:dicHeaderFieldValue];
    
    [self servicePATCH:urlResource
            withParams:paramsURL
     onServiceAnswers:^(NSString * uidTaskService, IOStackResponse * response) {
         if( doWithUpdateResults == nil )
             return;
         
         if( [response failed] )
         {
             doWithUpdateResults( nil, nil );
             return;
         }
         
         doWithUpdateResults( response.responseHeaders, response.responseContent );
     }];
}

- ( void ) deleteResource:( NSString * ) urlResource
               withHeader:( NSDictionary * ) dicHeaderFieldValue
                   thenDo:( void ( ^ ) ( NSDictionary * dicResults, id idFullResponse ) ) doWithDeleteResults
{
    [self setHTTPHeaderWithValues:dicHeaderFieldValue];
    
    [self serviceDELETE:urlResource
     onServiceAnswers:^(NSString * uidTaskService, IOStackResponse * response) {
         if( doWithDeleteResults == nil )
             return;
         
         if( [response failed] )
         {
             doWithDeleteResults( nil, nil );
             return;
         }
         
         doWithDeleteResults( response.responseHeaders, response.responseContent );
     }];
}


#pragma mark - IOStackServiceDelegate
- ( void ) onServiceAnswers:( NSString * ) uidServiceTask
               withResponse:( IOStackResponse * ) response
{
    void ( ^ doOnAnswer ) ( NSString * uidServiceTask, IOStackResponse * response ) = [_dicActiveAnswerBlocks valueForKey:uidServiceTask];
    
    if( doOnAnswer != nil )
        doOnAnswer( uidServiceTask, response );
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
                 thenDo:( void ( ^ ) ( bool isWithStatus, id dicObjectValues ) ) doAfterWait
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
                 thenDo:( void ( ^ ) ( bool isWithStatus, id dicObjectValues ) ) doAfterWait
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
    
    void ( ^doAfterWaitBlock )( bool isWithStatus, id dicObjectValues ) = dicUserInfo[ @"blockAfterWait" ];
    
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
            doAfterWaitBlock( YES, objResult );
            return;
        }
        
        if( objResult == nil ||
           ( strFieldName != nil &&
            ( ![objResult isKindOfClass:[NSDictionary class]] &&
             ![objResult isKindOfClass:[NSArray class]] ) ) )
        {
            doAfterWaitBlock( NO, objResult );
            return;
        }
        
        id valRetrievedToCheck = objResult;
        
        //we retrieve the first value if we get an array
        if( strFieldName != nil &&
           [objResult isKindOfClass:[NSArray class]] &&
           [objResult count] >= 1 )
            valRetrievedToCheck = [objResult objectAtIndex:0];
        
        //if we are supposed to retrieve a specific field
        //and we get a NSDictionary, we retrieve the value
        if( strFieldName != nil &&
           [valRetrievedToCheck isKindOfClass:[NSDictionary class]] )
            valRetrievedToCheck = [valRetrievedToCheck valueForKey:strFieldName];
        
        if( arrErrorValues != nil &&
           [arrErrorValues containsObject:valRetrievedToCheck] )
        {
            doAfterWaitBlock( NO, objResult );
            return;
        }
        
        BOOL bHasReachedEquality = NO;
        
        //paradoxaly, if we have a [NSNull null],
        //it means, we just want something not nil
        if( [valueToCheck isKindOfClass:[NSNull class]] &&
           valRetrievedToCheck != nil )
            bHasReachedEquality = YES;
        
        else
            bHasReachedEquality = [self object:valRetrievedToCheck
                                     isEqualTo:valueToCheck];
        
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
            doAfterWaitBlock( YES, objResult );
        
        else
            doAfterWaitBlock( NO, objResult );
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

#pragma mark - Equality functional helper
- ( BOOL ) object:( id ) firstObject
        isEqualTo:( id ) secondObject
{
    BOOL bHasReachedEquality = NO;
    
    if( [firstObject isKindOfClass:[NSString class]] &&
        [secondObject isKindOfClass:[NSString class]])
        bHasReachedEquality = [(( NSString * ) firstObject) isEqualToString:secondObject];
    
    else if( [firstObject isKindOfClass:[NSNumber class]] &&
            [secondObject isKindOfClass:[NSNumber class]] )
        bHasReachedEquality = [(( NSNumber * ) firstObject) isEqualToNumber:secondObject];
    
    else if( [firstObject isKindOfClass:[NSDate class]] &&
            [secondObject isKindOfClass:[NSDate class]] )
        bHasReachedEquality = [(( NSDate * ) firstObject) isEqualToDate:secondObject];
    
    else if( [firstObject isKindOfClass:[NSTimeZone class]] &&
            [secondObject isKindOfClass:[NSTimeZone class]] )
        bHasReachedEquality = [(( NSTimeZone * ) firstObject) isEqualToTimeZone:secondObject];
    
    else if( [firstObject isKindOfClass:[NSData class]] &&
            [secondObject isKindOfClass:[NSData class]] )
        bHasReachedEquality = [(( NSData * ) firstObject) isEqualToData:secondObject];
    
    else if( [firstObject isKindOfClass:[NSHashTable class]] &&
            [secondObject isKindOfClass:[NSHashTable class]] )
        bHasReachedEquality = [(( NSHashTable * ) firstObject) isEqualToHashTable:secondObject];
    
    else if( [firstObject isKindOfClass:[NSIndexSet class]] &&
            [secondObject isKindOfClass:[NSIndexSet class]] )
        bHasReachedEquality = [(( NSIndexSet * ) firstObject) isEqualToIndexSet:secondObject];
    
    else if( [firstObject isKindOfClass:[NSOrderedSet class]] &&
            [secondObject isKindOfClass:[NSOrderedSet class]] )
        bHasReachedEquality = [(( NSOrderedSet * ) firstObject) isEqualToOrderedSet:secondObject];
    
    else if( [firstObject isKindOfClass:[NSDictionary class]] &&
            [secondObject isKindOfClass:[NSDictionary class]] )
        bHasReachedEquality = [(( NSDictionary * ) firstObject) isEqualToDictionary:secondObject];
    
    else if( [firstObject isKindOfClass:[NSSet class]] &&
            [secondObject isKindOfClass:[NSSet class]] )
        bHasReachedEquality = [(( NSSet * ) firstObject) isEqualToSet:secondObject];
    
    else if( [firstObject isKindOfClass:[NSValue class]] &&
            [secondObject isKindOfClass:[NSValue class]] )
        bHasReachedEquality = [(( NSValue * ) firstObject) isEqualToValue:secondObject];
    
    return bHasReachedEquality;
}


@end
