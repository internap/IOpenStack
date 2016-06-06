//
//  IOStackObjectStorageV1.m
//  IOpenStack
//
//  Created by Bruno Morel on 2016-03-02.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import <XCTest/XCTest.h>


#import     "IOStackAuthV3.h"
#import     "IOStackObjectStorageV1.h"


@interface IOStackObjectStorageV1Tests : XCTestCase

@end


@implementation IOStackObjectStorageV1Tests
{
    IOStackAuthV3 *             authV3Session;
    IOStackObjectStorageV1 *    objectstorageV1Test;
    NSDictionary *              dicSettingsTests;
}

- ( void )setUp
{
    [super setUp];
    [self setContinueAfterFailure:NO];
    
    NSString * currentTestFilePath  = @__FILE__;
    NSString * currentSettingTests  = [NSString stringWithFormat:@"%@/SettingsTests.plist", [currentTestFilePath stringByDeletingLastPathComponent]];
    
    dicSettingsTests = [NSDictionary dictionaryWithContentsOfFile:currentSettingTests];
    
    XCTAssertNotNil( dicSettingsTests );
    XCTAssertNotNil( dicSettingsTests[ @"DEVSTACK_IDENTITY_ROOT" ] );
    XCTAssertNotNil( dicSettingsTests[ @"DEVSTACK_ACCOUNT_PROJECTORTENANT" ] );
    XCTAssertNotNil( dicSettingsTests[ @"DEVSTACK_ACCOUNT_DOMAIN" ] );
    XCTAssertNotNil( dicSettingsTests[ @"DEVSTACK_ACCOUNT_LOGINDEMO" ] );
    XCTAssertNotNil( dicSettingsTests[ @"DEVSTACK_ACCOUNT_PASSWORDDEMO" ] );
    XCTAssertNotNil( dicSettingsTests[ @"DEVSTACK_OBJECTSTORAGE_ROOT" ] );
    XCTAssertNotNil( dicSettingsTests[ @"DEVSTACK_OBJECTSTORAGE_ACCOUNT" ] );
    
    __weak XCTestExpectation *exp = [self expectationWithDescription:@"Setuping Auth"];
    
    authV3Session = [IOStackAuthV3 initWithIdentityURL:dicSettingsTests[ @"DEVSTACK_IDENTITY_ROOT" ]
                                              andLogin:dicSettingsTests[ @"DEVSTACK_ACCOUNT_LOGINDEMO" ]
                                           andPassword:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PASSWORDDEMO" ]
                                      forDefaultDomain:dicSettingsTests[ @"DEVSTACK_ACCOUNT_DOMAIN" ]
                                    andProjectOrTenant:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PROJECTORTENANT" ]
                                                thenDo:^(NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse){
                                                    XCTAssertNotNil(strTokenIDResponse);
                                                    
                                                    objectstorageV1Test = [IOStackObjectStorageV1 initWithIdentity:authV3Session];
                                                    
                                                    [exp fulfill];
                                                }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) tearDown
{
    [super tearDown];
}

- ( void ) testOStorageNotASingleton
{
    XCTAssertNotNil(objectstorageV1Test.currentTokenID);
    
    IOStackObjectStorageV1 *    objectstorageV1Test2 = [IOStackObjectStorageV1 initWithObjectStorageURL:dicSettingsTests[ @"DEVSTACK_OBJECTSTORAGE_ROOT" ]
                                                                                             andTokenID:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PROJECTORTENANT" ]
                                                                                             forAccount:dicSettingsTests[ @"DEVSTACK_OBJECTSTORAGE_ACCOUNT" ]];
    XCTAssertNotEqualObjects( objectstorageV1Test, objectstorageV1Test2 );
}

- ( void ) testOStorageCreateListAndDeleteContainer
{
    __weak XCTestExpectation * expectation     = [self expectationWithDescription:@"Image - images exist"];
    NSString * nameContainer            = [NSString stringWithFormat:@"%@-%@", @"testcontainer", [[NSUUID UUID] UUIDString]];
    NSDictionary * dicContainerMetadata = @{ @"testmeta" : @"testvalue" };
    
    [objectstorageV1Test createContainerWithName:nameContainer
                                     andMetaData:dicContainerMetadata
                                          thenDo:^(BOOL isCreated, id  _Nullable idFullResponse)
    {
        XCTAssertTrue( isCreated );
        [objectstorageV1Test listContainersThenDo:^(NSDictionary * _Nullable dicContainers) {
            XCTAssertNotNil( dicContainers );
            XCTAssertTrue( [dicContainers count] > 0 );
            XCTAssertNotNil( [dicContainers valueForKey:nameContainer] );
            
            [objectstorageV1Test deleteContainerWithName:nameContainer
                                                  thenDo:^(BOOL isDeleted, id  _Nullable idFullResponse)
            {
                XCTAssertTrue( isDeleted );
                
                [expectation fulfill];
            }];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:50.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testOStorageCreateListAndDeleteObjectInContainer
{
    __weak XCTestExpectation * expectation     = [self expectationWithDescription:@"Object Storage - upload file"];
    NSString * nameContainer            = [NSString stringWithFormat:@"%@-%@", @"testcontainer", [[NSUUID UUID] UUIDString]];
    NSString * nameObject               = [NSString stringWithFormat:@"%@-%@", @"testobject", [[NSUUID UUID] UUIDString]];
    NSDictionary * dicContainerMetadata = @{ @"testmeta" : @"testvalue" };
    
    [objectstorageV1Test createContainerWithName:nameContainer
                                     andMetaData:dicContainerMetadata
                                          thenDo:^(BOOL isCreated, id  _Nullable idFullResponse)
     {
         XCTAssertTrue( isCreated );
         [objectstorageV1Test listContainersThenDo:^(NSDictionary * _Nullable dicContainers) {
             XCTAssertNotNil( dicContainers );
             XCTAssertTrue( [dicContainers count] > 0 );
             XCTAssertNotNil( [dicContainers valueForKey:nameContainer] );
             [objectstorageV1Test createEmptyObjectWithName:nameObject
                                                andMetaData:nil
                                                inContainer:nameContainer
                                                  keepItFor:0
                                                     thenDo:^(BOOL isCreated, id  _Nullable idFullResponse)
             {
                 XCTAssertTrue( isCreated );
                 [objectstorageV1Test listObjectsInContainer:nameContainer
                                                      thenDo:^(NSDictionary * _Nullable dicStoredObjects)
                 {
                     XCTAssertNotNil( dicStoredObjects );
                     XCTAssertTrue( [dicStoredObjects count] > 0 );
                     XCTAssertNotNil( dicStoredObjects[ nameObject ] );
                     [objectstorageV1Test deleteObjectWithName:nameObject
                                                   inContainer:nameContainer
                                                        thenDo:^(BOOL isDeleted, id  _Nullable idFullResponse)
                     {
                         XCTAssertTrue( isDeleted );
                         [objectstorageV1Test deleteContainerWithName:nameContainer
                                                               thenDo:^(BOOL isDeleted, id  _Nullable idFullResponse)
                          {
                              XCTAssertTrue( isDeleted );
                              
                              [expectation fulfill];
                          }];
                     }];
                     
                 }];
             }];
         }];
     }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testOStorageUploadListAndDeleteObjectInContainer
{
    __weak XCTestExpectation * expectation     = [self expectationWithDescription:@"Object Storage - upload file"];
    NSString * nameContainer            = [NSString stringWithFormat:@"%@-%@", @"testcontainer", [[NSUUID UUID] UUIDString]];
    NSString * nameObject               = [NSString stringWithFormat:@"%@-%@", @"testobject", [[NSUUID UUID] UUIDString]];
    NSString * currentTestFilePath      = @__FILE__;
    NSString * currentKeyDataFilePath   = [NSString stringWithFormat:@"%@/testkey-id_rsa.pub", [currentTestFilePath stringByDeletingLastPathComponent]];
    NSDictionary * dicContainerMetadata = @{ @"testmeta" : @"testvalue" };
    
    
    [objectstorageV1Test createContainerWithName:nameContainer
                                     andMetaData:dicContainerMetadata
                                          thenDo:^(BOOL isCreated, id  _Nullable idFullResponse)
     {
         XCTAssertTrue( isCreated );
         [objectstorageV1Test listContainersThenDo:^(NSDictionary * _Nullable dicContainers) {
             XCTAssertNotNil( dicContainers );
             XCTAssertTrue( [dicContainers count] > 0 );
             XCTAssertNotNil( [dicContainers valueForKey:nameContainer] );
             [objectstorageV1Test uploadObjectWithName:nameObject
                                      fromFileWithPath:currentKeyDataFilePath
                                           addMetaData:nil
                                           inContainer:nameContainer
                                             keepItFor:0
                                                thenDo:^(BOOL isCreated, id  _Nullable idFullResponse)
              {
                  XCTAssertTrue( isCreated );
                  [objectstorageV1Test listObjectsInContainer:nameContainer
                                                       thenDo:^(NSDictionary * _Nullable dicStoredObjects)
                   {
                       XCTAssertNotNil( dicStoredObjects );
                       XCTAssertTrue( [dicStoredObjects count] > 0 );
                       XCTAssertNotNil( dicStoredObjects[ nameObject ] );
                       
                       [objectstorageV1Test deleteObjectWithName:nameObject
                                                     inContainer:nameContainer
                                                          thenDo:^(BOOL isDeleted, id  _Nullable idFullResponse)
                        {
                            XCTAssertTrue( isDeleted );
                            [objectstorageV1Test deleteContainerWithName:nameContainer
                                                                  thenDo:^(BOOL isDeleted, id  _Nullable idFullResponse)
                             {
                                 XCTAssertTrue( isDeleted );
                                 
                                 [expectation fulfill];
                             }];
                        }];
                   }];
              }];
         }];
     }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}


@end
