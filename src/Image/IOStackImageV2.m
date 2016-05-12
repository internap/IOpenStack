//
//  IOStackImage.m
//  IOpenStack
//
//  Created by Bruno Morel on 2016-01-24.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import "IOStackImageV2.h"


#define IMAGEV2_SERVICE_URI             @"v2/"
#define IMAGEV2_IMAGE_URN               @"images"
#define IMAGEV2_IMAGEREACTIVATE_URN     @"reactivate"
#define IMAGEV2_IMAGEDEACTIVATE_URN     @"deactivate"


@implementation IOStackImageV2


@synthesize currentTokenID;


+ ( instancetype ) initWithImageURL:( NSString * ) strImageRoot
                         andTokenID:( NSString * ) strTokenID
{
    return [ [ self alloc ] initWithImageURL:strImageRoot
                                  andTokenID:strTokenID ];
}

+ ( instancetype ) initWithIdentity:( id<IOStackIdentityInfos> ) idUserIdentity
{
    return [ [ self alloc ] initWithIdentity:idUserIdentity ];
}


#pragma mark - Object init
- ( instancetype ) initWithImageURL:( NSString * ) strImageRoot
                         andTokenID:( NSString * ) strTokenID
{
    if( self = [super initWithPublicURL:[NSURL URLWithString:strImageRoot]
                                andType:IMAGESTORAGE_SERVICE
                        andMajorVersion:@2
                        andMinorVersion:@0
                        andProviderName:GENERIC_SERVICENAME] )
    {
        currentTokenID = strTokenID;
        
        [self setHTTPHeader:@"X-Auth-Token"
                  withValue:currentTokenID];
    }
    return self;
}

- ( instancetype ) initWithIdentity:( id<IOStackIdentityInfos> ) idUserIdentity
{
    IOStackService * currentService = [idUserIdentity.currentServices valueForKey:IMAGESTORAGE_SERVICE];
    
    return [self initWithImageURL:[[currentService urlPublic] absoluteString]
                       andTokenID:idUserIdentity.currentTokenID];
}


#pragma mark - Image management
- ( void ) listImagesThenDo:( void ( ^ ) ( NSDictionary * dicImages ) ) doAfterList
{
    /*
    [self listResource:urlImage
            withHeader:nil
          andUrlParams:nil
             insideKey:@"images"
                thenDo:^(NSArray * _Nullable arrFound, id  _Nullable dataResponse)
     {
         if( doAfterList != nil )
             doAfterList( [IOStackImageObjectV2 parseFromAPIResponse:arrFound] );
     }];*/
    [self listImagesWithVisibility:nil
                         andStatus:nil
                            andTag:nil
                   andMemberStatus:nil
                          andOwner:nil
                           andName:nil
                        andSizeMin:nil
                        andSizeMax:nil
                   andCreationDate:nil
                    andUpdatedDate:nil
                        sortByKeys:nil
               sortByKeysDirection:nil
                              From:nil
                         withLimit:nil
                            thenDo:doAfterList];
}

- ( void ) listImagesWithVisibility:( NSString * ) strVisibilityToFilterBy
                          andStatus:( NSString * ) statusToFilterBy
                             andTag:( NSString * ) strTagToFilterBy
                    andMemberStatus:( NSString * ) statusMemberToFilterBy
                           andOwner:( NSString * ) uidOwnerToFilterBy
                            andName:( NSString * ) nameToFilterBy
                         andSizeMin:( NSNumber * ) numSizeMin
                         andSizeMax:( NSNumber * ) numSizeMax
                    andCreationDate:( NSDate * ) dateCreated
                     andUpdatedDate:( NSDate * ) dateUpdated
                         sortByKeys:( NSArray * ) arrSortingKey
                sortByKeysDirection:( NSArray * ) arrSortingKeyAscOrDesc
                               From:( NSString * ) strStartingFromID
                          withLimit:( NSNumber * ) nLimit
                             thenDo:( void ( ^ ) ( NSDictionary * dicImages ) ) doAfterList
{
    NSString * urlImage = [NSString stringWithFormat:@"%@%@",
                           IMAGEV2_SERVICE_URI,
                           IMAGEV2_IMAGE_URN];
    NSMutableDictionary * dicQueryParams = [NSMutableDictionary dictionary];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale * enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    
    
    if( strVisibilityToFilterBy != nil )
        dicQueryParams[@"visibility"] = strVisibilityToFilterBy;
    
    if( statusToFilterBy != nil )
        dicQueryParams[@"status"] = statusToFilterBy;
    
    if( strTagToFilterBy != nil )
        dicQueryParams[@"tag"] = strTagToFilterBy;
    
    if( statusMemberToFilterBy != nil )
        dicQueryParams[@"member_status"] = statusMemberToFilterBy;
    
    if( uidOwnerToFilterBy != nil )
        dicQueryParams[@"owner"] = uidOwnerToFilterBy;
    
    if( nameToFilterBy != nil )
        dicQueryParams[@"name"] = nameToFilterBy;
    
    if( numSizeMin != nil )
        dicQueryParams[@"size_min"] = [numSizeMin stringValue];
    
    if( numSizeMax != nil )
        dicQueryParams[@"size_max"] = [numSizeMax stringValue];
    
    if( dateCreated != nil )
        dicQueryParams[@"created_at"] = [dateFormatter stringFromDate:dateCreated];
    
    if( dateUpdated != nil )
        dicQueryParams[@"updated_at"] = [dateFormatter stringFromDate:dateUpdated];
    
    if( arrSortingKey != nil &&
       [arrSortingKey count] > 0 )
    {
        NSString * strSortingParam = [NSString string];
        uint currentArrayIndex = 0;
        
        for( NSString * currentKeyName in arrSortingKey )
        {
            if( currentArrayIndex != 0 )
                strSortingParam = [NSString stringWithFormat:@"%@,", strSortingParam];
            
            strSortingParam = [NSString stringWithFormat:@"%@%@", strSortingParam, currentKeyName];
            
            if( arrSortingKeyAscOrDesc != nil &&
               [arrSortingKeyAscOrDesc count] > currentArrayIndex &&
               [[arrSortingKeyAscOrDesc objectAtIndex:currentArrayIndex] isEqualToString:@"asc"] )
                strSortingParam = [NSString stringWithFormat:@"%@:%@", strSortingParam, @"asc"];
            
            else
                strSortingParam = [NSString stringWithFormat:@"%@:%@", strSortingParam, @"desc"];
            
            currentArrayIndex++;
        }
        
        if( [strSortingParam length] > 0 )
            dicQueryParams[@"sort"] = strSortingParam;
    }
    
    if( strStartingFromID != nil )
        dicQueryParams[@"marker"] = strStartingFromID;
    
    if( nLimit != nil )
        dicQueryParams[@"limit"] = [nLimit stringValue];
    
    
    [self listResource:urlImage
            withHeader:nil
          andUrlParams:dicQueryParams
             insideKey:@"endpoints"
                thenDo:^(NSArray * _Nullable arrFound, id _Nullable dataResponse)
     {
         if( doAfterList != nil )
             doAfterList( [IOStackImageObjectV2 parseFromAPIResponse:arrFound] );
     }];
}

- ( void ) createImageWithName:( NSString * ) nameImage
                   andForcedID:( NSString * ) uidForced
                 andVisibility:( NSString * ) strVisibility
                        andTag:( NSArray * ) arrTags
            andContainerFormat:( NSString * ) strContainerFormat
                 andDiskFormat:( NSString * ) strDiskFormat
                    andDiskMin:( NSNumber * ) numDiskMin
                     andRAMMin:( NSNumber * ) numRAMMin
                 andProperties:( NSDictionary * ) dicProperties
                   isProtected:( BOOL ) isProtected
                       thenDo:( void ( ^ ) ( IOStackImageObjectV2 * createdImage ) ) doAfterCreate
{
    NSString * urlImage = [NSString stringWithFormat:@"%@%@",
                           IMAGEV2_SERVICE_URI,
                           IMAGEV2_IMAGE_URN];
    NSMutableDictionary * mdicImageParam = [NSMutableDictionary dictionaryWithObject:nameImage
                                                                             forKey:@"name"];
    if( uidForced != nil )
        mdicImageParam[ @"id" ] = uidForced;
    
    if( strVisibility != nil )
        mdicImageParam[ @"visibility" ] = strVisibility;
    
    if( arrTags != nil )
        mdicImageParam[ @"tags" ] = arrTags;
    
    if( strContainerFormat != nil )
        mdicImageParam[ @"container_format" ] = strContainerFormat;
    
    if( strDiskFormat != nil )
        mdicImageParam[ @"disk_format" ] = strDiskFormat;
    
    if( numDiskMin != nil )
        mdicImageParam[ @"min_disk" ] = [numDiskMin stringValue];
    
    if( numRAMMin != nil )
        mdicImageParam[ @"min_ram" ] = [numRAMMin stringValue];
    
    if( dicProperties != nil )
        mdicImageParam[ @"properties" ] = dicProperties;
    
    mdicImageParam[ @"protected" ] = [NSNumber numberWithBool:NO];
    if( isProtected )
        mdicImageParam[ @"protected" ] = [NSNumber numberWithBool:YES];
    
    [self createResource:urlImage
              withHeader:nil
            andUrlParams:mdicImageParam
                  thenDo:^(NSDictionary * _Nullable dicResponseHeaders, id  _Nullable idFullResponse)
     {
         if( doAfterCreate != nil )
             doAfterCreate( [IOStackImageObjectV2 initFromAPIResponse:idFullResponse] );
     }];
}

- ( void ) getdetailForImageWithID:( NSString * ) uidImage
                            thenDo:( void ( ^ ) ( IOStackImageObjectV2 * image ) ) doAfterGetDetail
{
    NSString * urlImage = [NSString stringWithFormat:@"%@%@/%@",
                           IMAGEV2_SERVICE_URI,
                           IMAGEV2_IMAGE_URN,
                           uidImage];
    [self readResource:urlImage
            withHeader:nil
          andUrlParams:nil
             insideKey:@"image"
                thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable dataResponse)
     {
         if( doAfterGetDetail != nil )
             doAfterGetDetail( [IOStackImageObjectV2 initFromAPIResponse:dicObjectFound] );
     }];
}

/*TODO : address PATCH problem with glance guys
- ( void ) updateImageWithID:( NSString * ) uidImage
                     newName:( NSString * ) nameImage
                 newForcedID:( NSString * ) uidForced
               newVisibility:( NSString * ) strVisibility
                      newTag:( NSArray * ) arrTags
          newContainerFormat:( NSString * ) strContainerFormat
               newDiskFormat:( NSString * ) strDiskFormat
                  newDiskMin:( NSNumber * ) numDiskMin
                   newRAMMin:( NSNumber * ) numRAMMin
               newProperties:( NSDictionary * ) dicProperties
                 isProtected:( BOOL ) isProtected
                     thenDo:( void ( ^ ) ( NSDictionary * updatedImage, id dicFullResponse ) ) doAfterUpdate
{
    NSString * urlImage = [NSString stringWithFormat:@"%@%@/%@",
                           IMAGEV2_SERVICE_URI,
                           IMAGEV2_IMAGE_URN,
                           uidImage];
    NSMutableArray * marrImageParam = [NSMutableArray array];
    
    if( nameImage != nil )
        [marrImageParam addObject:@{@"op": @"replace", @"path": [NSString stringWithFormat:@"/%@", @"name"], @"value": nameImage}];

    if( uidForced != nil )
        [marrImageParam addObject:@{@"op": @"replace", @"path": [NSString stringWithFormat:@"/%@", @"id"], @"value": uidForced}];
    
    if( strVisibility != nil )
        [marrImageParam addObject:@{@"op": @"replace", @"path": [NSString stringWithFormat:@"/%@", @"visibility"], @"value": strVisibility}];
    
    if( arrTags != nil )
        [marrImageParam addObject:@{@"op": @"replace", @"path": [NSString stringWithFormat:@"/%@", @"tags"], @"value": arrTags}];
    
    if( strContainerFormat != nil )
        [marrImageParam addObject:@{@"op": @"replace", @"path": [NSString stringWithFormat:@"/%@", @"container_format"], @"value": strContainerFormat}];
    
    if( strDiskFormat != nil )
        [marrImageParam addObject:@{@"op": @"replace", @"path": [NSString stringWithFormat:@"/%@", @"disk_format"], @"value": strDiskFormat}];
    
    if( numDiskMin != nil )
        [marrImageParam addObject:@{@"op": @"replace", @"path": [NSString stringWithFormat:@"/%@", @"min_disk"], @"value": [numDiskMin stringValue]}];
    
    if( numRAMMin != nil )
        [marrImageParam addObject:@{@"op": @"replace", @"path": [NSString stringWithFormat:@"/%@", @"min_ram"], @"value": [numRAMMin stringValue]}];
    
    if( dicProperties != nil )
        [marrImageParam addObject:@{@"op": @"replace", @"path": [NSString stringWithFormat:@"/%@", @"properties"], @"value": dicProperties}];
    
    [marrImageParam addObject:@{@"op": @"replace", @"path": [NSString stringWithFormat:@"/%@", @"protected"], @"value": [NSNumber numberWithBool:NO]}];
    if( isProtected )
        [marrImageParam addObject:@{@"op": @"replace", @"path": [NSString stringWithFormat:@"/%@", @"protected"], @"value": [NSNumber numberWithBool:YES]}];
    
    [self updateResource:urlImage
              withHeader:nil
            andUrlParams:marrImageParam
                  thenDo:^(NSDictionary * _Nullable dicResponseHeader, id  _Nullable idFullResponse)
     {
         NSDictionary * finalImage = idFullResponse;
         if( idFullResponse != nil )
             finalImage = idFullResponse[ @"image" ];
         
         if( doAfterUpdate != nil )
             doAfterUpdate( finalImage, idFullResponse );
     }];
}
 */

- ( void ) deleteImageWithID:( NSString * ) uidImage
                     thenDo:( void ( ^ ) ( bool isDeleted, id idFullResponse ) ) doAfterDelete
{
    NSString * urlImage = [NSString stringWithFormat:@"%@%@/%@",
                           IMAGEV2_SERVICE_URI,
                           IMAGEV2_IMAGE_URN,
                           uidImage];
    [self deleteResource:urlImage
              withHeader:nil
                  thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable idFullResponse)
     {
         if( doAfterDelete != nil )
             doAfterDelete( ( idFullResponse == nil ) ||
                           ( idFullResponse[ @"response" ] == nil ) ||
                           ( [idFullResponse[ @"response" ] isEqualToString:@""] ), idFullResponse );
     }];
}


- ( void ) reactivateImageWithID:( NSString * ) uidImage
                          thenDo:( void ( ^ ) ( BOOL isAdded, id dicFullResponse ) ) doAfterChange
{
    NSString * urlReactivateImage = [NSString stringWithFormat:@"%@%@/%@/%@",
                                     IMAGEV2_SERVICE_URI,
                                     IMAGEV2_IMAGE_URN,
                                     uidImage,
                                     IMAGEV2_IMAGEREACTIVATE_URN];
    
    [self replaceResource:urlReactivateImage
               withHeader:nil
             andUrlParams:nil
                   thenDo:^(NSDictionary * _Nullable dicResponseHeaders, id  _Nullable idFullResponse)
     {
         if( doAfterChange != nil )
             doAfterChange( ( idFullResponse == nil ) ||
                           ( idFullResponse[ @"response" ] == nil ) ||
                           ( [idFullResponse[ @"response" ] isEqualToString:@""] ), idFullResponse );
     }];
}

- ( void ) deactivateImageWithID:( NSString * ) uidImage
                          thenDo:( void ( ^ ) ( BOOL isAdded, id dicFullResponse ) ) doAfterChange
{
    NSString * urlReactivateImage = [NSString stringWithFormat:@"%@%@/%@/%@",
                                     IMAGEV2_SERVICE_URI,
                                     IMAGEV2_IMAGE_URN,
                                     uidImage,
                                     IMAGEV2_IMAGEDEACTIVATE_URN];
    
    [self replaceResource:urlReactivateImage
               withHeader:nil
             andUrlParams:nil
                   thenDo:^(NSDictionary * _Nullable dicResponseHeaders, id  _Nullable idFullResponse)
     {
         if( doAfterChange != nil )
             doAfterChange( ( idFullResponse == nil ) ||
                           ( idFullResponse[ @"response" ] == nil ) ||
                           ( [idFullResponse[ @"response" ] isEqualToString:@""] ), idFullResponse );
     }];
}


@end
