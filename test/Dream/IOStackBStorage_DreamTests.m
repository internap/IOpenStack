//
//  IOStackBStorage_DreamTests.m
//  IOpenStack
//
//  Created by Bruno Morel on 2016-05-02.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import <XCTest/XCTest.h>


#import     "IOStackAuth_Dream.h"
#import     "IOStackBlockStorageV2.h"


@interface IOStackBStorage_DreamTests : XCTestCase

@end

@implementation IOStackBStorage_DreamTests
{
    IOStackAuth_Dream *         authDream;
    IOStackBlockStorageV2 *     bstorageV2Test;
    NSDictionary *              dicSettingsTests;
}


- ( void ) setUp
{
    [super setUp];
    NSString * currentTestFilePath  = @__FILE__;
    NSString * currentSettingTests  = [NSString stringWithFormat:@"%@/../SettingsTests.plist", [currentTestFilePath stringByDeletingLastPathComponent]];
    
    dicSettingsTests = [NSDictionary dictionaryWithContentsOfFile:currentSettingTests];
    
    XCTAssertNotNil( dicSettingsTests );
    XCTAssertNotNil( dicSettingsTests[ @"DREAM_IDENTITY_ROOT" ] );
    XCTAssertNotNil( dicSettingsTests[ @"DREAM_ACCOUNT_LOGIN" ] );
    XCTAssertNotNil( dicSettingsTests[ @"DREAM_ACCOUNT_PASSWORD" ] );
    XCTAssertNotNil( dicSettingsTests[ @"DREAM_BLOCKSTORAGE_ROOT" ] );
    XCTAssertNotNil( dicSettingsTests[ @"DREAM_ACCOUNT_DOMAIN" ] );
    XCTAssertNotNil( dicSettingsTests[ @"DREAM_ACCOUNT_PROJECTORTENANT" ] );
    
    __weak XCTestExpectation *exp = [self expectationWithDescription:@"Setuping Auth"];
    
    authDream = [IOStackAuth_Dream initWithIdentityURL:dicSettingsTests[ @"DREAM_IDENTITY_ROOT" ]
                                              andLogin:dicSettingsTests[ @"DREAM_ACCOUNT_LOGIN" ]
                                           andPassword:dicSettingsTests[ @"DREAM_ACCOUNT_PASSWORD" ]
                                      forDefaultDomain:dicSettingsTests[ @"DREAM_ACCOUNT_DOMAIN" ]
                                    andProjectOrTenant:dicSettingsTests[ @"DREAM_ACCOUNT_PROJECTORTENANT" ]
                                                thenDo:^(NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse)
    {
        XCTAssertNotNil(strTokenIDResponse);
        
        bstorageV2Test = [IOStackBlockStorageV2 initWithIdentity:authDream];
        
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
    
}

- ( void ) tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- ( void ) testDreamBStorageNotASingleton
{
    XCTAssertNotNil( bstorageV2Test.currentTokenID );
    
    IOStackBlockStorageV2 *    bstorageV2Test2 = [IOStackBlockStorageV2 initWithBlockStorageURL:dicSettingsTests[ @"DREAM_BLOCKSTORAGE_ROOT" ]
                                                                                     andTokenID:bstorageV2Test.currentTokenID
                                                                           forProjectOrTenantID:bstorageV2Test.currentProjectOrTenantID];
    XCTAssertNotEqualObjects( bstorageV2Test, bstorageV2Test2 );
}

- ( void ) testDreamBStorageCreateListAndDeleteVolume
{
    __weak XCTestExpectation * expectation     = [self expectationWithDescription:@"Block Storage - volume exist"];
    
    [bstorageV2Test createVolumeWithSize:@1
                    waitUntilIsAvailable:YES
                                  thenDo:^(IOStackBStorageVolumeV2 * _Nullable volumeCreated, NSDictionary * _Nullable dicFullResponse )
     {
         XCTAssertNotNil( volumeCreated );
         XCTAssertTrue( [volumeCreated.status isEqualToString:IOStackVolumeStatusAvailable] );
         
         [bstorageV2Test listVolumesThenDo:^(NSDictionary * _Nullable dicVolumes, id  _Nullable idFullResponse) {
             XCTAssertNotNil( dicVolumes );
             XCTAssertTrue( [dicVolumes count] >= 1 );
             XCTAssertNotNil( [dicVolumes valueForKey:volumeCreated.uniqueID] );
             
             [bstorageV2Test deleteVolumeWithID:volumeCreated.uniqueID
                             waitUntilIsDeleted:YES
                                         thenDo:^(bool isDeleted, id  _Nullable idFullResponse)
              {
                  XCTAssertTrue( isDeleted );
                  
                  [expectation fulfill];
              }];
         }];
         
     }];
    
    [self waitForExpectationsWithTimeout:30.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testDreamBStorageCreateListAndDeleteVolumeWithDetails
{
    __weak XCTestExpectation * expectation     = [self expectationWithDescription:@"Block Storage - volume exist"];
    NSString * nameVolume       = [NSString stringWithFormat:@"%@-%@", @"testvolume - ", [[NSUUID UUID] UUIDString]];
    NSString * descVolume       = @"this is an automated test volume description";
    NSDictionary * dicMetadata  = @{ @"metadata1" : @"test metadata value", @"metadata2" : @"another test metadata value"};
    
    [bstorageV2Test createVolumeWithSize:@1
                                 andName:nameVolume
                           andVolumetype:nil
                          andDescription:descVolume
                             andMetadata:dicMetadata
                       andSchedulerHints:nil
                   andConsistencyGroupID:nil
                        allowMultiAttach:NO//Internap doesn't allow multiattach volumes
                      inAvailabilityZone:nil
                      fromSourceVolumeID:nil
                        orSnapshotWithID:nil
                      orBootableImageRef:nil
                         orSourceReplica:nil
                    waitUntilIsAvailable:YES
                                  thenDo:^(IOStackBStorageVolumeV2 * _Nullable volumeCreated, NSDictionary * _Nullable dicFullResponse )
     {
         XCTAssertNotNil( volumeCreated );
         XCTAssertTrue( [volumeCreated.status isEqualToString:IOStackVolumeStatusAvailable] );
         XCTAssertTrue( [volumeCreated.nameVolume isEqualToString:nameVolume] );
         XCTAssertTrue( [volumeCreated.descriptionVolume isEqualToString:descVolume] );
         XCTAssertNotNil( volumeCreated.metadatas );
         XCTAssertTrue( [volumeCreated.metadatas count] >= 1);
         XCTAssertNotNil( volumeCreated.metadatas[ @"metadata1" ] );
         XCTAssertTrue( [volumeCreated.metadatas[ @"metadata2" ] isEqualToString:@"another test metadata value"] );
         
         [bstorageV2Test listVolumesThenDo:^(NSDictionary * _Nullable dicVolumes, id  _Nullable idFullResponse)
         {
             XCTAssertNotNil( dicVolumes );
             XCTAssertTrue( [dicVolumes count] >= 1 );
             XCTAssertNotNil( [dicVolumes valueForKey:volumeCreated.uniqueID] );
             
             IOStackBStorageVolumeV2 * volTests = [dicVolumes valueForKey:volumeCreated.uniqueID];
             
             XCTAssertNotNil( volTests );
             XCTAssertTrue( [volTests.status isEqualToString:IOStackVolumeStatusAvailable] );
             XCTAssertTrue( [volTests.nameVolume isEqualToString:nameVolume] );
             XCTAssertTrue( [volTests.descriptionVolume isEqualToString:descVolume] );
             XCTAssertNotNil( volTests.metadatas );
             XCTAssertTrue( [volTests.metadatas count] >= 1);
             XCTAssertNotNil( volTests.metadatas[ @"metadata1" ] );
             XCTAssertTrue( [volTests.metadatas[ @"metadata2" ] isEqualToString:@"another test metadata value"] );
             
             [bstorageV2Test deleteVolumeWithID:volumeCreated.uniqueID
                             waitUntilIsDeleted:YES
                                         thenDo:^(bool isDeleted, id  _Nullable idFullResponse)
              {
                  XCTAssertTrue( isDeleted );
                  
                  [expectation fulfill];
              }];
         }];
     }];
    
    [self waitForExpectationsWithTimeout:30.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testDreamBStorageCreateUpdateMetadataThenDestroyVolume
{
    __weak XCTestExpectation * expectation     = [self expectationWithDescription:@"Block Storage - volume metadata exist"];
    NSDictionary * dicMetadata  = @{ @"metadata1" : @"test metadata value", @"metadata2" : @"another test metadata value"};
    
    [bstorageV2Test createVolumeWithSize:@1
                    waitUntilIsAvailable:YES
                                  thenDo:^(IOStackBStorageVolumeV2 * _Nullable volumeCreated, NSDictionary * _Nullable dicFullResponse )
     {
         XCTAssertNotNil( volumeCreated );
         XCTAssertTrue( [volumeCreated.status isEqualToString:IOStackVolumeStatusAvailable] );
         
         [bstorageV2Test createMetadataForVolumeWithID:volumeCreated.uniqueID
                                           andMetadata:dicMetadata
                                                thenDo:^(BOOL isCreated, id _Nullable dicFullResponse)
          {
              XCTAssertTrue( isCreated );
              [bstorageV2Test listMetadataForVolumeWithID:volumeCreated.uniqueID
                                                   thenDo:^(NSDictionary * _Nullable dicMetadata, id  _Nullable idFullResponse)
               {
                   XCTAssertNotNil( dicMetadata );
                   XCTAssertTrue( [dicMetadata count] == 2 );
                   XCTAssertNotNil( dicMetadata[ @"metadata1" ] );
                   XCTAssertTrue( [dicMetadata[ @"metadata2" ] isEqualToString:@"another test metadata value"] );
                   
                   [bstorageV2Test updateMetadataForVolumeWithID:volumeCreated.uniqueID
                                                     andMetadata:@{ @"final_metadata" : @"test value"}
                                                          thenDo:^(BOOL isUpdated, id  _Nullable dicFullResponse)
                    {
                        XCTAssertTrue( isUpdated );
                        [bstorageV2Test listMetadataForVolumeWithID:volumeCreated.uniqueID
                                                             thenDo:^(NSDictionary * _Nullable dicMetadata, id  _Nullable idFullResponse)
                         {
                             XCTAssertNotNil( dicMetadata );
                             XCTAssertTrue( [dicMetadata count] >= 1);
                             XCTAssertNotNil( dicMetadata[ @"final_metadata" ] );
                             XCTAssertTrue( [dicMetadata[ @"final_metadata" ] isEqualToString:@"test value"] );
                             
                             [bstorageV2Test deleteVolumeWithID:volumeCreated.uniqueID
                                             waitUntilIsDeleted:YES
                                                         thenDo:^(bool isDeleted, id  _Nullable idFullResponse)
                              {
                                  XCTAssertTrue( isDeleted );
                                  
                                  [expectation fulfill];
                              }];
                         }];
                    }];
               }];
          }];
         
     }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testDreamBStorageCreateExtendThenDestroyVolume
{
    __weak XCTestExpectation * expectation     = [self expectationWithDescription:@"Block Storage - volume exist"];
    
    [bstorageV2Test createVolumeWithSize:@1
                    waitUntilIsAvailable:YES
                                  thenDo:^(IOStackBStorageVolumeV2 * _Nullable volumeCreated, NSDictionary * _Nullable dicFullResponse )
     {
         XCTAssertNotNil( volumeCreated );
         XCTAssertTrue( [volumeCreated.status isEqualToString:IOStackVolumeStatusAvailable] );
         
         [bstorageV2Test extendVolumeWithID:volumeCreated.uniqueID
                                     toSize:@2
                       waitUntilIsAvailable:YES
                                     thenDo:^(BOOL bExtended, id  _Nullable idFullResponse)
          {
              XCTAssertTrue( bExtended );
              [bstorageV2Test listVolumesThenDo:^(NSDictionary * _Nullable dicVolumes, id  _Nullable idFullResponse) {
                  XCTAssertNotNil( dicVolumes );
                  XCTAssertTrue( [dicVolumes count] >= 1 );
                  XCTAssertNotNil( [dicVolumes valueForKey:volumeCreated.uniqueID] );
                  
                  IOStackBStorageVolumeV2 * volTests = [dicVolumes valueForKey:volumeCreated.uniqueID];
                  
                  XCTAssertNotNil( volTests );
                  XCTAssertTrue( [volTests.status isEqualToString:IOStackVolumeStatusAvailable] );
                  XCTAssertTrue( [volTests.size unsignedIntegerValue] == 2 );
                  
                  [bstorageV2Test deleteVolumeWithID:volumeCreated.uniqueID
                                  waitUntilIsDeleted:YES
                                              thenDo:^(bool isDeleted, id  _Nullable idFullResponse)
                   {
                       XCTAssertTrue( isDeleted );
                       
                       [expectation fulfill];
                   }];
              }];
          }];
     }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

//Dreamcompute don't allow editing metadata as action and do not support Backup for now
/*
- ( void ) testBStorageCreateSetAndUnsetMetadataThenDestroyVolume
{
    __weak IOStackBlockStorageV2 * weakBStorageForTest = bstorageV2Test;
    __weak XCTestExpectation * expectation     = [self expectationWithDescription:@"Block Storage - metadata set unset"];
    NSDictionary * dicMetadata  = @{ @"metadata1" : @"test metadata value", @"metadata2" : @"another test metadata value"};
    
    [bstorageV2Test createVolumeWithSize:@1
                    waitUntilIsAvailable:YES
                                  thenDo:^(IOStackBStorageVolumeV2 * _Nullable volumeCreated, NSDictionary * _Nullable dicFullResponse )
     {
         XCTAssertNotNil( volumeCreated );
         XCTAssertTrue( [volumeCreated.status isEqualToString:IOStackVolumeStatusAvailable] );
         
         XCTAssertNil( volumeCreated.volume_image_metadata );
         
         [weakBStorageForTest setImageMetadataForVolumeWithID:volumeCreated.uniqueID
                                                   toMetadata:dicMetadata
                                                       thenDo:^(BOOL bSet, id  _Nullable idFullResponse)
          {
              XCTAssertTrue( bSet );
              [bstorageV2Test listVolumesThenDo:^(NSDictionary * _Nullable dicVolumes, id  _Nullable idFullResponse) {
                  XCTAssertNotNil( dicVolumes );
                  XCTAssertTrue( [dicVolumes count] >= 1 );
                  XCTAssertNotNil( [dicVolumes valueForKey:volumeCreated.uniqueID] );
                  
                  IOStackBStorageVolumeV2 * volTests = [dicVolumes valueForKey:volumeCreated.uniqueID];
                  
                  XCTAssertNotNil( volTests );
                  XCTAssertNotNil( [volTests.volume_image_metadata valueForKey:@"metadata1"] );
                  XCTAssertTrue( [[volTests.volume_image_metadata valueForKey:@"metadata1"] isEqualToString:dicMetadata[ @"metadata1"]] );
                  XCTAssertNotNil( [volTests.volume_image_metadata valueForKey:@"metadata2"] );
                  XCTAssertTrue( [[volTests.volume_image_metadata valueForKey:@"metadata2"] isEqualToString:dicMetadata[ @"metadata2"]] );
                  
                  [bstorageV2Test unsetImageMetadataForVolumeWithID:volumeCreated.uniqueID
                                                     forMetadataKey:@"metadata1"
                                                             thenDo:^(BOOL bUnset, id  _Nullable idFullResponse)
                   {
                       XCTAssertNotNil( [volTests.volume_image_metadata valueForKey:@"metadata2"] );
                       XCTAssertTrue( [[volTests.volume_image_metadata valueForKey:@"metadata2"] isEqualToString:dicMetadata[ @"metadata2"]] );
                       [bstorageV2Test deleteVolumeWithID:volumeCreated.uniqueID
                                       waitUntilIsDeleted:YES
                                                   thenDo:^(bool isDeleted, id  _Nullable idFullResponse)
                        {
                            XCTAssertTrue( isDeleted );
                            
                            [expectation fulfill];
                        }];
                   }];
              }];
          }];
     }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testDreamBStorageCreateListAndDeleteBackup
{
    __weak XCTestExpectation * expectation     = [self expectationWithDescription:@"Block Storage - backup exist"];
    
    [bstorageV2Test createVolumeWithSize:@1
                    waitUntilIsAvailable:YES
                                  thenDo:^(IOStackBStorageVolumeV2 * _Nullable volumeCreated, NSDictionary * _Nullable dicFullResponse )
     {
         XCTAssertNotNil( volumeCreated );
         XCTAssertTrue( [volumeCreated.status isEqualToString:IOStackVolumeStatusAvailable] );
         
         XCTAssertNil( volumeCreated.volume_image_metadata );
         
         [bstorageV2Test createBackupFromVolumeWithID:volumeCreated.uniqueID
                                             withName:@"test backup"
                                       andDescription:@"this is a backup test"
                                     andContainerName:nil
                                        incrementally:NO
                                                force:NO
                                 waitUntilIsAvailable:YES
                                               thenDo:^(IOStackBStorageBackupV2 * _Nullable backupCreated, id  _Nullable dicFullResponse)
          {
              XCTAssertNotNil( backupCreated );
              XCTAssertTrue( [backupCreated.status isEqualToString:IOStackVolumeStatusAvailable] );
              
              [bstorageV2Test listBackupsThenDo:^(NSDictionary * _Nullable dicBackups, id  _Nullable idFullResponse) {
                  
                  XCTAssertNotNil( dicBackups );
                  XCTAssertTrue( [dicBackups count] >= 1 );
                  XCTAssertNotNil( [dicBackups valueForKey:backupCreated.uniqueID] );
                  
                  [bstorageV2Test deleteBackupWithID:backupCreated.uniqueID
                                  waitUntilIsDeleted:YES
                                              thenDo:^(bool isDeleted, id  _Nullable idFullResponse)
                   {
                       XCTAssertTrue( isDeleted );
                       
                       [bstorageV2Test deleteVolumeWithID:volumeCreated.uniqueID
                                       waitUntilIsDeleted:YES
                                                   thenDo:^(bool isDeleted, id  _Nullable idFullResponse)
                        {
                            XCTAssertTrue( isDeleted );
                            
                            [expectation fulfill];
                        }];
                   }];
              }];
          }];
     }];
    
    [self waitForExpectationsWithTimeout:90.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}
*/
- ( void ) testDreamBStorageCreateListAndDeleteSnapshot
{
    __weak XCTestExpectation * expectation     = [self expectationWithDescription:@"Block Storage - snapshot exist"];
    
    [bstorageV2Test createVolumeWithSize:@1
                    waitUntilIsAvailable:YES
                                  thenDo:^(IOStackBStorageVolumeV2 * _Nullable volumeCreated, NSDictionary * _Nullable dicFullResponse )
     {
         XCTAssertNotNil( volumeCreated );
         XCTAssertTrue( [volumeCreated.status isEqualToString:IOStackVolumeStatusAvailable] );
         
         XCTAssertNil( volumeCreated.volume_image_metadata );
         
         [bstorageV2Test createSnapshotFromVolumeWithID:volumeCreated.uniqueID
                                               withName:@"test snapshot"
                                         andDescription:@"this is a snapshot test"
                                                  force:NO
                                   waitUntilIsAvailable:YES
                                                 thenDo:^(IOStackBStorageSnapshotV2 * _Nullable snapshotCreated, id  _Nullable dicFullResponse)
          {
              XCTAssertNotNil( snapshotCreated );
              XCTAssertTrue( [snapshotCreated.status isEqualToString:IOStackSnapshotStatusAvailable] );
              
              [bstorageV2Test listSnapshotsThenDo:^(NSDictionary * _Nullable dicSnapshots, id  _Nullable idFullResponse)
               {
                   XCTAssertNotNil( dicSnapshots );
                   XCTAssertTrue( [dicSnapshots count] >= 1 );
                   XCTAssertNotNil( [dicSnapshots valueForKey:snapshotCreated.uniqueID] );
                   
                   [bstorageV2Test deleteSnapshotWithID:snapshotCreated.uniqueID
                                     waitUntilIsDeleted:YES
                                                 thenDo:^(bool isDeleted, id  _Nullable idFullResponse)
                    {
                        XCTAssertTrue( isDeleted );
                        
                        [bstorageV2Test deleteVolumeWithID:volumeCreated.uniqueID
                                        waitUntilIsDeleted:YES
                                                    thenDo:^(bool isDeleted, id  _Nullable idFullResponse)
                         {
                             XCTAssertTrue( isDeleted );
                             
                             [expectation fulfill];
                         }];
                    }];
               }];
          }];
     }];
    
    [self waitForExpectationsWithTimeout:50.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}


@end
