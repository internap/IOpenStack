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
- ( void ) createImageWithName:( nonnull NSString * ) nameImage
            andContainerFormat:( nonnull NSString * ) strContainerFormat
                 andDiskFormat:( nonnull NSString * ) strDiskFormat
                 andVisibility:( nullable NSString * ) strVisibility
                        andTag:( nullable NSArray * ) arrTags
                    andDiskMin:( nullable NSNumber * ) numDiskMin
                     andRAMMin:( nullable NSNumber * ) numRAMMin
                 andProperties:( nullable NSDictionary * ) dicProperties
                   isProtected:( BOOL ) isProtected
                   andForcedID:( nullable NSString * ) uidForced
                        thenDo:( nullable void ( ^ ) ( IOStackImageObjectV2 * _Nullable createdImage ) ) doAfterCreate;
- ( void ) getdetailForImageWithID:( nonnull NSString * ) uidImage
                            thenDo:( nullable void ( ^ ) ( IOStackImageObjectV2 * _Nullable image ) ) doAfterGetDetail;
- ( void ) deleteImageWithID:( nonnull NSString * ) uidImage
                      thenDo:( nullable void ( ^ ) ( bool isDeleted, id _Nullable idFullResponse ) ) doAfterDelete;
- ( void ) reactivateImageWithID:( nonnull NSString * ) uidImage
                          thenDo:( nullable void ( ^ ) ( BOOL isReactivated, id _Nullable dicFullResponse ) ) doAfterChange;
- ( void ) deactivateImageWithID:( nonnull NSString * ) uidImage
                          thenDo:( nullable void ( ^ ) ( BOOL isDeactivated, id _Nullable dicFullResponse ) ) doAfterChange;
- ( void ) uploadImageWithID:( nonnull NSString * ) uidImage
                    fromData:( nonnull NSData * ) datRaw
                      thenDo:( nullable void ( ^ ) ( BOOL isUploaded ) ) doAfterUpload;
- ( void ) uploadImageWithID:( nonnull NSString * ) uidImage
            fromFileWithPath:( nonnull NSString * ) pathFileToUpload
                      thenDo:( nullable void ( ^ ) ( BOOL isUploaded ) ) doAfterUpload;
- ( void ) getrawdataForImageWithID:( nonnull NSString * ) uidImage
                             thenDo:( nullable void ( ^ ) ( NSData * _Nullable datRaw ) ) doAfterGetRawData;
- ( void ) listTasksthenDo:( nullable void ( ^ ) ( NSArray * _Nullable arrTasks, id _Nullable idFullResponse ) ) doAfterList;
- ( void ) createTaskWithType:( nonnull NSString * ) strType
                 fromLocation:( nonnull NSString * ) urlLocation
                andDiskFormat:( nonnull NSString * ) strFromDiskFormat
                 toDiskFormat:( nonnull NSString * ) strToDiskFormat
           andContainerFormat:( nonnull NSString * ) strContainerFormat
                       thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable createdTask, id _Nullable dicFullResponse ) ) doAfterCreate;
- ( void ) getdetailForTaskWithID:( nonnull NSString * ) uidTask
                           thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicMember ) ) doAfterGetDetail;


@end
