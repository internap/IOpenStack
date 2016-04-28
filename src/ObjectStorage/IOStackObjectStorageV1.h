//
//  IOStackObjectStorageV1.h
//  IOpenStack
//
//  Created by Bruno Morel on 2016-02-26.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "IOStackAuth.h"

#import "IOStackOStorageContainerV1.h"
#import "IOStackOStorageObjectV1.h"


@interface IOStackObjectStorageV1 : IOStackService


// local property accessors
@property (strong, strong, nonatomic) NSString * _Nonnull                       currentTokenID;
@property (strong, strong, nonatomic) NSString * _Nullable                      currentAccountID;


+ ( nonnull instancetype ) initWithObjectStorageURL:( nonnull NSString * ) strObjectStorageRoot
                                         andTokenID:( nonnull NSString * ) strTokenID
                                         forAccount:( nonnull NSString * ) strAccountID;
+ ( nonnull instancetype ) initWithIdentity:( nonnull id<IOStackIdentityInfos> ) idUserIdentity;
- ( nonnull instancetype ) initWithObjectStorageURL:( nonnull NSString * ) strObjectStorageRoot
                                         andTokenID:( nonnull NSString * ) strTokenID
                                         forAccount:( nonnull NSString * ) strAccountID;
- ( nonnull instancetype ) initWithIdentity:( nonnull id<IOStackIdentityInfos> ) idUserIdentity;
- ( void ) listContainersThenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicContainers ) ) doAfterList;
- ( void ) createContainerWithName:( nonnull NSString * ) strContainerName
                       andMetaData:( nullable NSDictionary * ) dicMetadata
                            thenDo:( nullable void ( ^ ) ( BOOL isCreated, id _Nullable idFullResponse ) ) doAfterCreate;
- ( void ) deleteContainerWithName:( nonnull NSString * ) strContainerName
                            thenDo:( nullable void ( ^ ) ( BOOL isDeleted, id _Nullable idFullResponse ) ) doAfterDelete;
- ( void ) listObjectsInContainer:( nonnull NSString * ) strNameContainer
                           thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicStoredObjects ) ) doAfterList;
- ( void ) createEmptyObjectWithName:( nonnull NSString * ) strNameObject
                         andMetaData:( nullable NSDictionary * ) dicMetadata
                         inContainer:( nonnull NSString * ) strNameContainer
                           keepItFor:( NSTimeInterval ) tiForDelete
                              thenDo:( nullable void ( ^ ) ( BOOL isCreated, id _Nullable idFullResponse ) ) doAfterCreate;
- ( void ) uploadObjectWithName:( nonnull NSString * ) strNameObject
                    andMetaData:( nullable NSDictionary * ) dicMetadata
                    inContainer:( nonnull NSString * ) strNameContainer
                      keepItFor:( NSTimeInterval ) tiForDelete
                       withData:( nonnull NSData * ) dataRaw
                         thenDo:( nullable void ( ^ ) ( BOOL isCreated, id _Nullable idFullResponse ) ) doAfterUpload;
- ( void ) deleteObjectWithName:( nonnull NSString * ) strNameObject
                    inContainer:( nonnull NSString * ) strNameContainer
                         thenDo:( nullable void ( ^ ) ( BOOL isDeleted, id _Nullable idFullResponse ) ) doAfterDelete;


@end
