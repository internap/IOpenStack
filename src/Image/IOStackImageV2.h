//
//  IOStackImage.h
//  IOpenStack
//
//  Created by Bruno Morel on 2016-01-24.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "IOStackAuth.h"
#import "IOStackImageObjectV2.h"


@interface IOStackImageV2 : IOStackService


// local property accessors
@property (strong, nonatomic) NSString * _Nonnull                       currentTokenID;


+ ( nonnull instancetype ) initWithImageURL:( nonnull NSString * ) strImageRoot
                                 andTokenID:( nonnull NSString * ) strTokenID;
+ ( nonnull instancetype ) initWithIdentity:( nonnull id<IOStackIdentityInfos> ) idUserIdentity;

- ( nonnull instancetype ) initWithImageURL:( nonnull NSString * ) strImageRoot
                                 andTokenID:( nonnull NSString * ) strTokenID;
- ( nonnull instancetype ) initWithIdentity:( nonnull id<IOStackIdentityInfos> ) idUserIdentity;
- ( void ) listImagesThenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicImages ) ) doAfterList;
- ( void ) listImagesWithVisibility:( nullable NSString * ) strVisibilityToFilterBy
                          andStatus:( nullable NSString * ) statusToFilterBy
                             andTag:( nullable NSString * ) strTagToFilterBy
                    andMemberStatus:( nullable NSString * ) statusMemberToFilterBy
                           andOwner:( nullable NSString * ) uidOwnerToFilterBy
                            andName:( nullable NSString * ) nameToFilterBy
                         andSizeMin:( nullable NSNumber * ) numSizeMin
                         andSizeMax:( nullable NSNumber * ) numSizeMax
                    andCreationDate:( nullable NSDate * ) dateCreated
                     andUpdatedDate:( nullable NSDate * ) dateUpdated
                         sortByKeys:( nullable NSArray * ) arrSortingKey
                sortByKeysDirection:( nullable NSArray * ) arrSortingKeyAscOrDesc
                               From:( nullable NSString * ) strStartingFromID
                          withLimit:( nullable NSNumber * ) nLimit
                             thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicImages ) ) doAfterList;
- ( void ) getdetailForImageWithID:( nonnull NSString * ) uidImage
                            thenDo:( nullable void ( ^ ) ( IOStackImageObjectV2 * _Nullable image ) ) doAfterGetDetail;
- ( void ) deleteImageWithID:( nonnull NSString * ) uidImage
                      thenDo:( nullable void ( ^ ) ( bool isDeleted, id _Nullable idFullResponse ) ) doAfterDelete;
- ( void ) reactivateImageWithID:( nonnull NSString * ) uidImage
                          thenDo:( nullable void ( ^ ) ( BOOL isAdded, id _Nullable dicFullResponse ) ) doAfterChange;
- ( void ) deactivateImageWithID:( nonnull NSString * ) uidImage
                          thenDo:( nullable void ( ^ ) ( BOOL isAdded, id _Nullable dicFullResponse ) ) doAfterChange;


@end
