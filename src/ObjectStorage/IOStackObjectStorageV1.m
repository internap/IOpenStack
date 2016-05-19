//
//  IOStackObjectStorageV1.m
//  IOpenStack
//
//  Created by Bruno Morel on 2016-02-26.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import "IOStackObjectStorageV1.h"


#define OBJECTSTORAGEV1_SERVICE_URI     @"v1"
#define OBJECTSTORAGEV1_ACCOUNTPREFIX   @"AUTH"


@implementation IOStackObjectStorageV1

@synthesize currentTokenID;
@synthesize currentAccountID;


+ ( instancetype ) initWithObjectStorageURL:( NSString * ) strObjectStorageRoot
                                 andTokenID:( NSString * ) strTokenID
                                 forAccount:( NSString * ) strAccountID
{
    return [ [ self alloc ] initWithObjectStorageURL:strObjectStorageRoot
                                          andTokenID:strTokenID
                                          forAccount:strAccountID];
}

+ ( instancetype ) initWithIdentity:( id<IOStackIdentityInfos> ) idUserIdentity
{
    return [ [ self alloc ] initWithIdentity:idUserIdentity ];
}


#pragma mark - Object init
- ( instancetype ) initWithObjectStorageURL:( NSString * ) strObjectStorageRoot
                                 andTokenID:( NSString * ) strTokenID
                                 forAccount:( NSString * ) strAccountID
{
    NSURL * urlFinalService = [NSURL URLWithString:strObjectStorageRoot];
    
    if( [strObjectStorageRoot hasSuffix:strAccountID] )
    {
        NSURLComponents * urlComponents = [NSURLComponents componentsWithString:strObjectStorageRoot];
        
        NSMutableArray * arrPathComponentsWithoutAccountID = [NSMutableArray arrayWithArray:[urlComponents.path componentsSeparatedByString:@"/"]];
        
        currentAccountID = [arrPathComponentsWithoutAccountID lastObject];
        [arrPathComponentsWithoutAccountID removeLastObject];
        
        urlComponents.path = [arrPathComponentsWithoutAccountID componentsJoinedByString:@"/"];
        
        urlFinalService = [urlComponents URL];
    }
    else
        currentAccountID = strAccountID;
    
    if( ![urlFinalService.pathComponents containsObject:OBJECTSTORAGEV1_SERVICE_URI ] )
    {
        NSURLComponents * urlComponents = [NSURLComponents componentsWithString:strObjectStorageRoot];
        urlComponents.path = [NSString stringWithFormat:@"%@/%@", OBJECTSTORAGEV1_SERVICE_URI, urlFinalService.path];
        
        urlFinalService = [urlComponents URL];
    }
    
    if( self = [super initWithPublicURL:urlFinalService
                                andType:OBJECTSTORAGE_SERVICE
                        andMajorVersion:@1
                        andMinorVersion:@0
                        andProviderName:GENERIC_SERVICENAME] )
    {
        currentTokenID = strTokenID;
        
        if( currentTokenID != nil )
            [self setHTTPHeaderWithValues:@{@"X-Auth-Token" : currentTokenID, @"Accept" : @"application/json,text/html"}];
        
        else
            [self setHTTPHeader:@"Accept" withValue:@"application/json,text/html"];
    }
    return self;
}

- ( instancetype ) initWithIdentity:( id<IOStackIdentityInfos> ) idUserIdentity
{
    IOStackService * currentService = [idUserIdentity.currentServices valueForKey:OBJECTSTORAGE_SERVICE];
    
    if( idUserIdentity.currentProjectOrTenantID == nil )
        return nil;
    
    NSString * strAccountID = [NSString stringWithFormat:@"%@_%@", OBJECTSTORAGEV1_ACCOUNTPREFIX, idUserIdentity.currentProjectOrTenantID];
    
    return [self initWithObjectStorageURL:[[currentService urlPublic] absoluteString]
                               andTokenID:idUserIdentity.currentTokenID
                               forAccount:strAccountID];
}


#pragma mark - Containers management
- ( void ) listContainersThenDo:( void ( ^ ) ( NSDictionary * dicContainers ) ) doAfterList
{
    [self listResource:currentAccountID
            withHeader:nil
          andUrlParams:nil
                thenDo:^(NSArray * arrFound, id dataResponse)
    {
        if( doAfterList != nil )
            doAfterList( [IOStackOStorageContainerV1 parseFromAPIResponse:arrFound] );
    }];
}

- ( void ) createContainerWithName:( NSString * ) strNameContainer
                       andMetaData:( NSDictionary * ) dicMetadata
                          thenDo:( void ( ^ ) ( BOOL isCreated, id idFullResponse ) ) doAfterCreate
{
    if( [strNameContainer length] > 256 )
        [NSException exceptionWithName:[NSString stringWithFormat:@"Method %@ bad parameter", @"/"]
                                reason:@"Container name is longer than 256 characters"
                              userInfo:@{@"account_id": currentAccountID}];
    
    NSMutableDictionary * dicHeader = [NSMutableDictionary dictionaryWithCapacity:[dicMetadata count]];
    for( NSString * currentMetadataName in dicMetadata )
        [dicHeader setObject:dicMetadata[ currentMetadataName ]
                      forKey:[NSString stringWithFormat:@"X-Container-Meta-%@", currentMetadataName]];
    
    NSString * urlContainer = [NSString stringWithFormat:@"%@/%@", currentAccountID, strNameContainer];
    
    [self replaceResource:urlContainer
               withHeader:dicHeader
             andUrlParams:nil
                   thenDo:^(NSDictionary * dicResults, id idFullResponse)
    {
        if( doAfterCreate )
            doAfterCreate( ( dicResults != nil ), idFullResponse );
    }];
}

- ( void ) metadataContainerWithName:( NSString * ) strNameContainer
                              thenDo:( void ( ^ ) ( NSDictionary * dicMetadata ) ) doAfterMetadata
{
    NSString * urlContainer = [NSString stringWithFormat:@"%@/%@", currentAccountID, strNameContainer];
    
    [self metadataResource:urlContainer
              withHeader:nil
              andUrlParams:nil
     thenDo:^(NSDictionary * _Nullable headerValues, id  _Nullable dataResponse) {
         if( doAfterMetadata != nil )
             doAfterMetadata( headerValues );
     }];
}

- ( void ) deleteContainerWithName:( NSString * ) strNameContainer
                            thenDo:( void ( ^ ) ( BOOL isDeleted, id idFullResponse ) ) doAfterDelete
{
    NSString * urlContainer = [NSString stringWithFormat:@"%@/%@", currentAccountID, strNameContainer];
    
    [self deleteResource:urlContainer
              withHeader:nil
                  thenDo:^(NSDictionary * dicResults, id idFullResponse) {
                       if( doAfterDelete )
                           doAfterDelete( ( dicResults != nil ), idFullResponse );
                   }];
}


#pragma mark - Objects management
- ( void ) listObjectsInContainer:( NSString * ) strNameContainer
                           thenDo:( void ( ^ ) ( NSDictionary * dicStoredObjects ) ) doAfterList
{
    NSString * urlContainer = [NSString stringWithFormat:@"%@/%@", currentAccountID, strNameContainer];

    [self listResource:urlContainer
            withHeader:nil
          andUrlParams:nil
                thenDo:^(NSArray * arrFound, id dataResponse)
    {
        if( doAfterList != nil )
            doAfterList( [IOStackOStorageObjectV1 parseFromAPIResponse:arrFound] );
    }];
}

- ( void ) createEmptyObjectWithName:( NSString * ) strNameObject
                         andMetaData:( NSDictionary * ) dicMetadata
                         inContainer:( NSString * ) strNameContainer
                           keepItFor:( NSTimeInterval ) tiForDelete
                              thenDo:( void ( ^ ) ( BOOL isCreated, id idFullResponse ) ) doAfterCreate
{
    if( [strNameObject length] > 256 )
        [NSException exceptionWithName:[NSString stringWithFormat:@"Method %@ bad parameter", @"/"]
                                reason:@"Container name is longer than 256 characters"
                              userInfo:@{@"account_id": currentAccountID}];
    
    if( [strNameContainer length] > 256 )
        [NSException exceptionWithName:[NSString stringWithFormat:@"Method %@ bad parameter", @"/"]
                                reason:@"Object name is longer than 256 characters"
                              userInfo:@{@"account_id": currentAccountID}];
    
    NSMutableDictionary * dicHeader = [NSMutableDictionary dictionaryWithCapacity:[dicMetadata count]];
    for( NSString * currentMetadataName in dicMetadata )
        [dicHeader setObject:dicMetadata[ currentMetadataName ]
                      forKey:[NSString stringWithFormat:@"X-Container-Meta-%@", currentMetadataName]];
    
    if( tiForDelete != 0.0 )
        [dicHeader setObject:[NSNumber numberWithInt:( int )tiForDelete]
                      forKey:@"X-Delete-After" ];
    
    NSString * urlObject = [NSString stringWithFormat:@"%@/%@/%@", currentAccountID, strNameContainer, strNameObject];
    
    [self replaceResource:urlObject
               withHeader:dicHeader
             andUrlParams:nil
                   thenDo:^(NSDictionary * dicResults, id idFullResponse)
    {
        if( doAfterCreate )
            doAfterCreate( ( dicResults != nil ), idFullResponse );
    }];
}

- ( void ) uploadObjectWithName:( NSString * ) nameObject
                       fromData:( NSData * ) dataRaw
                    addMetaData:( NSDictionary * ) dicMetadata
                    inContainer:( NSString * ) nameContainer
                      keepItFor:( NSTimeInterval ) tiForDelete
                         thenDo:( void ( ^ ) ( BOOL isCreated, id idFullResponse ) ) doAfterCreate
{
    if( [nameObject length] > 256 )
        [NSException exceptionWithName:[NSString stringWithFormat:@"Method %@ bad parameter", @"/"]
                                reason:@"Container name is longer than 256 characters"
                              userInfo:@{@"account_id": currentAccountID}];
    
    if( [nameContainer length] > 256 )
        [NSException exceptionWithName:[NSString stringWithFormat:@"Method %@ bad parameter", @"/"]
                                reason:@"Object name is longer than 256 characters"
                              userInfo:@{@"account_id": currentAccountID}];
    
    NSMutableDictionary * dicHeader = [NSMutableDictionary dictionaryWithCapacity:[dicMetadata count]];
    for( NSString * currentMetadataName in dicMetadata )
        [dicHeader setObject:dicMetadata[ currentMetadataName ]
                      forKey:[NSString stringWithFormat:@"X-Container-Meta-%@", currentMetadataName]];
    
    if( tiForDelete != 0.0 )
        [dicHeader setObject:[NSNumber numberWithInt:( int )tiForDelete]
                      forKey:@"X-Delete-After" ];
    
    NSString * urlObject = [NSString stringWithFormat:@"%@/%@/%@", currentAccountID, nameContainer, nameObject];
    
    [self replaceResource:urlObject
               withHeader:dicHeader
               andRawData:dataRaw//[dataRaw base64EncodedStringWithOptions:0
                   thenDo:^(NSDictionary * dicResults, id idFullResponse)
    {
        if( doAfterCreate )
            doAfterCreate( ( dicResults != nil ), idFullResponse );
    }];
}

- ( void ) uploadObjectWithName:( NSString * ) nameObject
               fromFileWithPath:( NSString * ) pathFileToUpload
                    addMetaData:( NSDictionary * ) dicMetadata
                    inContainer:( NSString * ) nameContainer
                      keepItFor:( NSTimeInterval ) tiForDelete
                         thenDo:( void ( ^ ) ( BOOL isCreated, id idFullResponse ) ) doAfterCreate
{
    NSError * errRead;
    NSData * datRawFile                 = [NSData dataWithContentsOfFile:pathFileToUpload
                                                                 options:NSUTF8StringEncoding
                                                                   error:&errRead];
    
    [self uploadObjectWithName:nameObject
                      fromData:datRawFile
                   addMetaData:dicMetadata
                   inContainer:nameContainer
                     keepItFor:tiForDelete
                        thenDo:doAfterCreate];
}

- ( void ) getdetailObjectWithName:( NSString * ) nameObject
                       inContainer:( NSString * ) nameContainer
                            thenDo:( void ( ^ ) ( NSData * dataResponse ) ) doAfterGetDetail
{
    NSString * urlObject = [NSString stringWithFormat:@"%@/%@/%@", currentAccountID, nameContainer, nameObject];

    [self readRawResource:urlObject
               withHeader:nil
             andUrlParams:nil
                insideKey:nil
                   thenDo:^(NSDictionary * dicObjectFound, id dataResponse)
     {
         if( doAfterGetDetail != nil )
             doAfterGetDetail( dataResponse );
     }];
}

- ( void ) metadataObjectWithName:( NSString * ) nameObject
                      inContainer:( NSString * ) nameContainer
                              thenDo:( void ( ^ ) ( NSDictionary * dicMetadata ) ) doAfterMetadata
{
    NSString * urlObject = [NSString stringWithFormat:@"%@/%@/%@", currentAccountID, nameContainer, nameObject];

    [self metadataResource:urlObject
                withHeader:nil
              andUrlParams:nil
                    thenDo:^(NSDictionary * _Nullable headerValues, id  _Nullable dataResponse) {
                        if( doAfterMetadata != nil )
                            doAfterMetadata( headerValues );
                    }];
}

- ( void ) deleteObjectWithName:( NSString * ) strNameObject
                    inContainer:( NSString * ) strNameContainer
                            thenDo:( void ( ^ ) ( BOOL isDeleted, id idFullResponse ) ) doAfterDelete
{
    NSString * urlObject = [NSString stringWithFormat:@"%@/%@/%@", currentAccountID, strNameContainer, strNameObject];
    
    [self deleteResource:urlObject
              withHeader:nil
                  thenDo:^(NSDictionary * dicResults, id idFullResponse) {
                       if( doAfterDelete )
                           doAfterDelete( ( dicResults != nil ), idFullResponse );
                   }];
}


@end
