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
    NSString * urlImage = [NSString stringWithFormat:@"%@%@",
                           IMAGEV2_SERVICE_URI,
                           IMAGEV2_IMAGE_URN];
    [self listResource:urlImage
            withHeader:nil
          andUrlParams:nil
             insideKey:@"images"
                thenDo:^(NSArray * _Nullable arrFound, id  _Nullable dataResponse)
     {
         if( doAfterList != nil )
             doAfterList( [IOStackImageObjectV2 parseFromAPIResponse:arrFound] );
     }];
}


@end
