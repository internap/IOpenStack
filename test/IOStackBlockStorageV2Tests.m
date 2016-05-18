//
//  IOStackBlockStorageV2Tests.m
//  IOpenStack
//
//  Created by Bruno Morel on 2016-03-29.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import <XCTest/XCTest.h>


#import     "IOStackAuthV3.h"
#import     "IOStackBlockStorageV2.h"


@interface IOStackBlockStorageV2Tests : XCTestCase

@end


@implementation IOStackBlockStorageV2Tests
{
    IOStackAuthV3 *             authV3Session;
    IOStackAuthV3 *             adminAuthV3Session;
    IOStackBlockStorageV2 *     bstorageV2Test;
    IOStackBlockStorageV2 *     adminBstorageV2Test;
    NSDictionary *              dicSettingsTests;
}


- ( void ) setUp
{
    [super setUp];
    [self setContinueAfterFailure:NO];
    
    NSString * currentTestFilePath  = @__FILE__;
    NSString * currentSettingTests  = [NSString stringWithFormat:@"%@/SettingsTests.plist", [currentTestFilePath stringByDeletingLastPathComponent]];
    
    dicSettingsTests = [NSDictionary dictionaryWithContentsOfFile:currentSettingTests];
    
    XCTAssertNotNil( dicSettingsTests );
    XCTAssertNotNil( dicSettingsTests[ @"DEVSTACK_IDENTITY_ROOT" ] );
    XCTAssertNotNil( dicSettingsTests[ @"DEVSTACK_ACCOUNT_LOGINDEMO" ] );
    XCTAssertNotNil( dicSettingsTests[ @"DEVSTACK_ACCOUNT_PASSWORDDEMO" ] );
    XCTAssertNotNil( dicSettingsTests[ @"DEVSTACK_ACCOUNT_LOGINADMIN" ] );
    XCTAssertNotNil( dicSettingsTests[ @"DEVSTACK_ACCOUNT_PASSWORDADMIN" ] );
    XCTAssertNotNil( dicSettingsTests[ @"DEVSTACK_ACCOUNT_DOMAIN" ] );
    XCTAssertNotNil( dicSettingsTests[ @"DEVSTACK_ACCOUNT_PROJECTORTENANT" ] );
    XCTAssertNotNil( dicSettingsTests[ @"DEVSTACK_BLOCKSTORAGE_ROOT" ] );
    
    __weak XCTestExpectation *exp = [self expectationWithDescription:@"Setuping Auth"];
    
    authV3Session = [IOStackAuthV3 initWithIdentityURL:dicSettingsTests[ @"DEVSTACK_IDENTITY_ROOT" ]
                                              andLogin:dicSettingsTests[ @"DEVSTACK_ACCOUNT_LOGINDEMO" ]
                                           andPassword:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PASSWORDDEMO" ]
                                      forDefaultDomain:dicSettingsTests[ @"DEVSTACK_ACCOUNT_DOMAIN" ]
                                    andProjectOrTenant:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PROJECTORTENANT" ]
                                                thenDo:^(NSString * strTokenIDResponse, NSDictionary * dicFullResponse)
    {
        XCTAssertNotNil(strTokenIDResponse);
        
        bstorageV2Test = [IOStackBlockStorageV2 initWithIdentity:authV3Session];
        
        adminAuthV3Session = [IOStackAuthV3 initWithIdentityURL:dicSettingsTests[ @"DEVSTACK_IDENTITY_ROOT" ]
                                                       andLogin:dicSettingsTests[ @"DEVSTACK_ACCOUNT_LOGINADMIN" ]
                                                    andPassword:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PASSWORDADMIN" ]
                                               forDefaultDomain:dicSettingsTests[ @"DEVSTACK_ACCOUNT_DOMAIN" ]
                                             andProjectOrTenant:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PROJECTORTENANT" ]
                                                         thenDo:^(NSString * strTokenIDResponse, NSDictionary * dicFullResponse)
        {
            XCTAssertNotNil(strTokenIDResponse);
            
            adminBstorageV2Test = [IOStackBlockStorageV2 initWithIdentity:adminAuthV3Session];
            
            [exp fulfill];
        }];
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


- ( void ) testBStorageNotASingleton
{
    XCTAssertNotNil( bstorageV2Test.currentTokenID );
    
    IOStackBlockStorageV2 *    bstorageV2Test2 = [IOStackBlockStorageV2 initWithBlockStorageURL:dicSettingsTests[ @"DEVSTACK_BLOCKSTORAGE_ROOT" ]
                                                                                     andTokenID:bstorageV2Test.currentTokenID
                                                                           forProjectOrTenantID:bstorageV2Test.currentProjectOrTenantID];
    XCTAssertNotEqualObjects( bstorageV2Test, bstorageV2Test2 );
}

- ( void ) testBStorageCreateListAndDeleteVolume
{
    __weak XCTestExpectation * expectation     = [self expectationWithDescription:@"Block Storage - volume exist"];
    
    [bstorageV2Test createVolumeWithSize:@1
                    waitUntilIsAvailable:YES
                                  thenDo:^(IOStackBStorageVolumeV2 * volumeCreated, NSDictionary * dicFullResponse )
    {
        XCTAssertNotNil( volumeCreated );
        XCTAssertTrue( [volumeCreated.status isEqualToString:IOStackVolumeStatusAvailable] );
        
        [bstorageV2Test listVolumesThenDo:^(NSDictionary * dicVolumes, id  idFullResponse) {
            XCTAssertNotNil( dicVolumes );
            XCTAssertTrue( [dicVolumes count] >= 1 );
            XCTAssertNotNil( [dicVolumes valueForKey:volumeCreated.uniqueID] );
            
            [bstorageV2Test deleteVolumeWithID:volumeCreated.uniqueID
                            waitUntilIsDeleted:YES
                                        thenDo:^(bool isDeleted, id  idFullResponse)
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

- ( void ) testBStorageCreateListAndDeleteVolumeWithDetails
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
                        allowMultiAttach:YES
                      inAvailabilityZone:nil
                      fromSourceVolumeID:nil
                        orSnapshotWithID:nil
                      orBootableImageRef:nil
                         orSourceReplica:nil
                    waitUntilIsAvailable:YES
                                  thenDo:^(IOStackBStorageVolumeV2 * volumeCreated, NSDictionary * dicFullResponse )
     {
         XCTAssertNotNil( volumeCreated );
         XCTAssertTrue( [volumeCreated.status isEqualToString:IOStackVolumeStatusAvailable] );
         XCTAssertTrue( [volumeCreated.nameVolume isEqualToString:nameVolume] );
         XCTAssertTrue( [volumeCreated.descriptionVolume isEqualToString:descVolume] );
         XCTAssertNotNil( volumeCreated.metadatas );
         XCTAssertTrue( [volumeCreated.metadatas count] >= 1);
         XCTAssertNotNil( volumeCreated.metadatas[ @"metadata1" ] );
         XCTAssertTrue( [volumeCreated.metadatas[ @"metadata2" ] isEqualToString:@"another test metadata value"] );
         
         [bstorageV2Test listVolumesThenDo:^(NSDictionary * dicVolumes, id  idFullResponse) {
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
                                         thenDo:^(bool isDeleted, id  idFullResponse)
              {
                  XCTAssertTrue( isDeleted );
                  
                  [expectation fulfill];
              }];
         }];
     }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testBStorageCreateUpdateMetadataThenDestroyVolume
{
    __weak XCTestExpectation * expectation     = [self expectationWithDescription:@"Block Storage - volume metadata exist"];
    NSDictionary * dicMetadata  = @{ @"metadata1" : @"test metadata value", @"metadata2" : @"another test metadata value"};
    
    [bstorageV2Test createVolumeWithSize:@1
                    waitUntilIsAvailable:YES
                                  thenDo:^(IOStackBStorageVolumeV2 * volumeCreated, NSDictionary * dicFullResponse )
     {
         XCTAssertNotNil( volumeCreated );
         XCTAssertTrue( [volumeCreated.status isEqualToString:IOStackVolumeStatusAvailable] );
         
         [bstorageV2Test createMetadataForVolumeWithID:volumeCreated.uniqueID
                                           andMetadata:dicMetadata
                                                thenDo:^(BOOL isCreated, id dicFullResponse)
         {
             XCTAssertTrue( isCreated );
             [bstorageV2Test listMetadataForVolumeWithID:volumeCreated.uniqueID
                                                  thenDo:^(NSDictionary * dicMetadata, id  idFullResponse)
             {
                 XCTAssertNotNil( dicMetadata );
                 XCTAssertTrue( [dicMetadata count] == 2 );
                 XCTAssertNotNil( dicMetadata[ @"metadata1" ] );
                 XCTAssertTrue( [dicMetadata[ @"metadata2" ] isEqualToString:@"another test metadata value"] );
                 
                 [bstorageV2Test updateMetadataForVolumeWithID:volumeCreated.uniqueID
                                                   andMetadata:@{ @"final_metadata" : @"test value"}
                                                        thenDo:^(BOOL isUpdated, id  dicFullResponse)
                 {
                     XCTAssertTrue( isUpdated );
                     [bstorageV2Test listMetadataForVolumeWithID:volumeCreated.uniqueID
                                                          thenDo:^(NSDictionary * dicMetadata, id  idFullResponse)
                      {
                          XCTAssertNotNil( dicMetadata );
                          XCTAssertTrue( [dicMetadata count] >= 1);
                          XCTAssertNotNil( dicMetadata[ @"final_metadata" ] );
                          XCTAssertTrue( [dicMetadata[ @"final_metadata" ] isEqualToString:@"test value"] );
                          
                          [bstorageV2Test deleteVolumeWithID:volumeCreated.uniqueID
                                          waitUntilIsDeleted:YES
                                                      thenDo:^(bool isDeleted, id  idFullResponse)
                           {
                               XCTAssertTrue( isDeleted );
                               
                               [expectation fulfill];
                           }];
                      }];
                 }];
             }];
         }];
         
     }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testBStorageCreateExtendThenDestroyVolume
{
    __weak XCTestExpectation * expectation     = [self expectationWithDescription:@"Block Storage - volume exist"];
    
    [bstorageV2Test createVolumeWithSize:@1
                    waitUntilIsAvailable:YES
                                  thenDo:^(IOStackBStorageVolumeV2 * volumeCreated, NSDictionary * dicFullResponse )
     {
         XCTAssertNotNil( volumeCreated );
         XCTAssertTrue( [volumeCreated.status isEqualToString:IOStackVolumeStatusAvailable] );
         
         [bstorageV2Test extendVolumeWithID:volumeCreated.uniqueID
                                     toSize:@2
                       waitUntilIsAvailable:YES
                                     thenDo:^(BOOL bExtended, id  idFullResponse)
         {
             XCTAssertTrue( bExtended );
             [bstorageV2Test listVolumesThenDo:^(NSDictionary * dicVolumes, id  idFullResponse) {
                 XCTAssertNotNil( dicVolumes );
                 XCTAssertTrue( [dicVolumes count] >= 1 );
                 XCTAssertNotNil( [dicVolumes valueForKey:volumeCreated.uniqueID] );
                 
                 IOStackBStorageVolumeV2 * volTests = [dicVolumes valueForKey:volumeCreated.uniqueID];
                 
                 XCTAssertNotNil( volTests );
                 XCTAssertTrue( [volTests.status isEqualToString:IOStackVolumeStatusAvailable] );
                 XCTAssertTrue( [volTests.size unsignedIntegerValue] == 2 );
                 
                 [bstorageV2Test deleteVolumeWithID:volumeCreated.uniqueID
                                 waitUntilIsDeleted:YES
                                             thenDo:^(bool isDeleted, id  idFullResponse)
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

/*
- ( void ) testBStorageCreateResetStatusesThenDestroyVolume
{
    __weak XCTestExpectation * expectation     = [self expectationWithDescription:@"Block Storage - status work"];
    
    [bstorageV2Test createVolumeWithSize:@1
                    waitUntilIsAvailable:YES
                                  thenDo:^(IOStackBStorageVolumeV1 * volumeCreated, NSDictionary * dicFullResponse )
     {
         XCTAssertNotNil( volumeCreated );
         XCTAssertTrue( [volumeCreated.status isEqualToString:IOStackVolumeStatusAvailable] );
         
         [bstorageV2Test resetStatusforVolumeWithID:volumeCreated.uniqueID
                                   withVolumeStatus:IOStackVolumeStatusInUse
                                    andAttachStatus:nil
                                 andMigrationStatus:@"migrating"
                                             thenDo:^(BOOL bReset, id  idFullResponse)
         {
             XCTAssertTrue( bReset );
             [bstorageV2Test listVolumesThenDo:^(NSDictionary * dicVolumes, id  idFullResponse) {
                 XCTAssertNotNil( dicVolumes );
                 XCTAssertTrue( [dicVolumes count] >= 1 );
                 XCTAssertNotNil( [dicVolumes valueForKey:volumeCreated.uniqueID] );
                 
                 IOStackBStorageVolumeV1 * volTests = [dicVolumes valueForKey:volumeCreated.uniqueID];
                 
                 XCTAssertNotNil( volTests );
                 XCTAssertTrue( [volTests.status isEqualToString:IOStackVolumeStatusInUse] );
                 XCTAssertTrue( [volTests.migration_status isEqualToString:@"migrating"] );
                 
                 [bstorageV2Test deleteVolumeWithID:volumeCreated.uniqueID
                                 waitUntilIsDeleted:YES
                                             thenDo:^(bool isDeleted, id  idFullResponse)
                  {
                      XCTAssertTrue( isDeleted );
                      
                      [expectation fulfill];
                  }];
             }];
         }];
     }];
    
    [self waitForExpectationsWithTimeout:50.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}
 */
- ( void ) testBStorageCreateSetAndUnsetMetadataThenDestroyVolume
{
    __weak IOStackBlockStorageV2 * weakBStorageForTest = bstorageV2Test;
    __weak XCTestExpectation * expectation     = [self expectationWithDescription:@"Block Storage - metadata set unset"];
    NSDictionary * dicMetadata  = @{ @"metadata1" : @"test metadata value", @"metadata2" : @"another test metadata value"};
    
    [bstorageV2Test createVolumeWithSize:@1
                    waitUntilIsAvailable:YES
                                  thenDo:^(IOStackBStorageVolumeV2 * volumeCreated, NSDictionary * dicFullResponse )
     {
         XCTAssertNotNil( volumeCreated );
         XCTAssertTrue( [volumeCreated.status isEqualToString:IOStackVolumeStatusAvailable] );
         
         XCTAssertNil( volumeCreated.volume_image_metadata );
         
         [weakBStorageForTest setImageMetadataForVolumeWithID:volumeCreated.uniqueID
                                                   toMetadata:dicMetadata
                                                       thenDo:^(BOOL bSet, id  idFullResponse)
         {
             XCTAssertTrue( bSet );
             [bstorageV2Test listVolumesThenDo:^(NSDictionary * dicVolumes, id  idFullResponse) {
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
                                                            thenDo:^(BOOL bUnset, id  idFullResponse)
                 {
                     XCTAssertNotNil( [volTests.volume_image_metadata valueForKey:@"metadata2"] );
                     XCTAssertTrue( [[volTests.volume_image_metadata valueForKey:@"metadata2"] isEqualToString:dicMetadata[ @"metadata2"]] );
                     [bstorageV2Test deleteVolumeWithID:volumeCreated.uniqueID
                                     waitUntilIsDeleted:YES
                                                 thenDo:^(bool isDeleted, id  idFullResponse)
                      {
                          XCTAssertTrue( isDeleted );
                          
                          [expectation fulfill];
                      }];
                 }];
             }];
         }];
     }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testBStorageAsAdminCreateThenUnmanageVolume
{
    __weak XCTestExpectation * expectation     = [self expectationWithDescription:@"Block Storage - unmanage volume"];
    
    
    
    [adminBstorageV2Test createVolumeWithSize:@1
                         waitUntilIsAvailable:YES
                                       thenDo:^(IOStackBStorageVolumeV2 * volumeCreated, NSDictionary * dicFullResponse )
     {
         [adminBstorageV2Test listVolumesThenDo:^(NSDictionary * dicVolumes, id  idFullResponse)
          {
              XCTAssertNotNil( dicVolumes );
              XCTAssertTrue( [dicVolumes count] >= 1 );
              XCTAssertNotNil( [dicVolumes valueForKey:volumeCreated.uniqueID] );
              
              
              XCTAssertNotNil( volumeCreated );
              XCTAssertTrue( [volumeCreated.status isEqualToString:IOStackVolumeStatusAvailable] );
              
              [adminBstorageV2Test unmanageVolumeWithID:volumeCreated.uniqueID
                                                 thenDo:^(BOOL bUnset, id  idFullResponse)
               {
                   XCTAssertTrue( bUnset );
                   
                   [expectation fulfill];
               }];
          }];
     }];
    
    [self waitForExpectationsWithTimeout:50.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testBStorageCreateListAndDeleteBackup
{
    __weak XCTestExpectation * expectation     = [self expectationWithDescription:@"Block Storage - backup exist"];
    
    [bstorageV2Test createVolumeWithSize:@1
                    waitUntilIsAvailable:YES
                                  thenDo:^(IOStackBStorageVolumeV2 * volumeCreated, NSDictionary * dicFullResponse )
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
                                               thenDo:^(IOStackBStorageBackupV2 * backupCreated, id  dicFullResponse)
         {
             XCTAssertNotNil( backupCreated );
             XCTAssertTrue( [backupCreated.status isEqualToString:IOStackVolumeStatusAvailable] );
         
             [bstorageV2Test listBackupsThenDo:^(NSDictionary * dicBackups, id  idFullResponse) {
                 
                 XCTAssertNotNil( dicBackups );
                 XCTAssertTrue( [dicBackups count] >= 1 );
                 XCTAssertNotNil( [dicBackups valueForKey:backupCreated.uniqueID] );
                 
                 [bstorageV2Test deleteBackupWithID:backupCreated.uniqueID
                                 waitUntilIsDeleted:YES
                                         thenDo:^(bool isDeleted, id  idFullResponse)
                  {
                      XCTAssertTrue( isDeleted );
                      
                      [bstorageV2Test deleteVolumeWithID:volumeCreated.uniqueID
                                      waitUntilIsDeleted:YES
                                                  thenDo:^(bool isDeleted, id  idFullResponse)
                      {
                          XCTAssertTrue( isDeleted );
                                                      
                          [expectation fulfill];
                      }];
                  }];
             }];
         }];
     }];
    
    [self waitForExpectationsWithTimeout:95.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testBStorageCreateListAndDeleteSnapshot
{
    __weak XCTestExpectation * expectation     = [self expectationWithDescription:@"Block Storage - snapshot exist"];
    
    [bstorageV2Test createVolumeWithSize:@1
                    waitUntilIsAvailable:YES
                                  thenDo:^(IOStackBStorageVolumeV2 * volumeCreated, NSDictionary * dicFullResponse )
     {
         XCTAssertNotNil( volumeCreated );
         XCTAssertTrue( [volumeCreated.status isEqualToString:IOStackVolumeStatusAvailable] );
         
         XCTAssertNil( volumeCreated.volume_image_metadata );
         
         [bstorageV2Test createSnapshotFromVolumeWithID:volumeCreated.uniqueID
                                               withName:@"test snapshot"
                                         andDescription:@"this is a snapshot test"
                                                  force:NO
                                   waitUntilIsAvailable:YES
                                                 thenDo:^(IOStackBStorageSnapshotV2 * snapshotCreated, id  dicFullResponse)
          {
              XCTAssertNotNil( snapshotCreated );
              XCTAssertTrue( [snapshotCreated.status isEqualToString:IOStackSnapshotStatusAvailable] );
              
              [bstorageV2Test listSnapshotsThenDo:^(NSDictionary * dicSnapshots, id  idFullResponse)
              {
                  XCTAssertNotNil( dicSnapshots );
                  XCTAssertTrue( [dicSnapshots count] >= 1 );
                  XCTAssertNotNil( [dicSnapshots valueForKey:snapshotCreated.uniqueID] );
                  
                  [bstorageV2Test deleteSnapshotWithID:snapshotCreated.uniqueID
                                    waitUntilIsDeleted:YES
                                                thenDo:^(bool isDeleted, id  idFullResponse)
                   {
                       XCTAssertTrue( isDeleted );
                       
                       [bstorageV2Test deleteVolumeWithID:volumeCreated.uniqueID
                                       waitUntilIsDeleted:YES
                                                   thenDo:^(bool isDeleted, id  idFullResponse)
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

- ( void ) testBStorageCreateAcceptAndDeleteVolumeTransfer
{
    __weak XCTestExpectation * expectation     = [self expectationWithDescription:@"Block Storage - volume transfer exist"];
    
    [bstorageV2Test createVolumeWithSize:@1
                    waitUntilIsAvailable:YES
                                  thenDo:^(IOStackBStorageVolumeV2 * volumeCreated, NSDictionary * dicFullResponse )
     {
         XCTAssertNotNil( volumeCreated );
         XCTAssertTrue( [volumeCreated.status isEqualToString:IOStackVolumeStatusAvailable] );
         
         XCTAssertNil( volumeCreated.volume_image_metadata );
         
         [bstorageV2Test createVolumeTransferForVolumeWithID:volumeCreated.uniqueID
                                            withTransferName:@"this is a test transfer"
                                                      thenDo:^(IOStackBStorageVolumeTransferV2 * transferCreated, id  dicFullResponse)
          {
              XCTAssertNotNil( transferCreated );
              XCTAssertNotNil( transferCreated.keyAuthentication );
              
              [bstorageV2Test listVolumeTransfersThenDo:^(NSDictionary * dicVolumeTransfers, id  idFullResponse)
               {
                   XCTAssertNotNil( dicVolumeTransfers );
                   XCTAssertTrue( [dicVolumeTransfers count] >= 1 );
                   XCTAssertNotNil( [dicVolumeTransfers valueForKey:transferCreated.uniqueID] );
                   
                   [adminBstorageV2Test acceptVolumeTransferForVolumeWithID:transferCreated.uniqueID
                                                                withAuthKey:transferCreated.keyAuthentication
                                                                     thenDo:^(BOOL isTransferAccepted, id  dicFullResponse)
                   {
                       XCTAssertTrue( isTransferAccepted );
                       [adminBstorageV2Test listVolumesThenDo:^(NSDictionary * dicVolumes, id  idFullResponse)
                       {
                           XCTAssertNotNil(dicVolumes);
                           XCTAssertTrue( [dicVolumes count] >= 1 );
                           XCTAssertNotNil( [dicVolumes valueForKey:volumeCreated.uniqueID] );

                           [adminBstorageV2Test deleteVolumeWithID:volumeCreated.uniqueID
                                                waitUntilIsDeleted:YES
                                                            thenDo:^(bool isDeleted, id  idFullResponse)
                           {
                               XCTAssertTrue(isDeleted);
                               
                               [expectation fulfill];
                           }];
                       }];
                   }];
               }];
          }];
     }];
    
    [self waitForExpectationsWithTimeout:70.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testBStorageListUpdateAndDeleteQuotas
{
    __weak XCTestExpectation * expectation     = [self expectationWithDescription:@"Block Storage - volume transfer exist"];
    NSString * uidProjectOrTenantNonAdmin = bstorageV2Test.currentProjectOrTenantID;

    XCTAssertNotNil( uidProjectOrTenantNonAdmin );
    
    [adminBstorageV2Test listQuotasForProjectOrTenantWithID:uidProjectOrTenantNonAdmin
                                                     thenDo:^(NSDictionary * dicQuotas)
    {
        XCTAssertNotNil( dicQuotas );
        XCTAssertNotNil( dicQuotas[ @"gigabytes" ] );
        NSNumber * numTotalSizeQuota = dicQuotas[ @"gigabytes" ];
        
        [adminBstorageV2Test getdetailDefaultQuotasThenDo:^(NSDictionary * dicQuotaTenantNonAdmin)
        {
            //XCTAssertTrue( [dicQuotaTenantNonAdmin isEqualToDictionary:dicQuotas] );
            [adminBstorageV2Test updateQuotaForProjectOrTenantWithID:uidProjectOrTenantNonAdmin
                                                   newTotalSizeQuota:[NSNumber numberWithLong:[numTotalSizeQuota longValue] - 1]
                                                     newVolumesQuota:@1
                                                   newPerVolumeQuota:@1
                                                      newBackupQuota:nil
                                             newBackupTotalSizeQuota:nil
                                                    newSnapshotQuota:nil
                                                              thenDo:^(NSDictionary * updatedQuota)
             {
                 [adminBstorageV2Test listQuotasForProjectOrTenantWithID:uidProjectOrTenantNonAdmin
                                                                  thenDo:^(NSDictionary * dicQuotas)
                  {
                      XCTAssertNotNil( dicQuotas );
                      XCTAssertTrue( [dicQuotas[ @"gigabytes" ] longValue] == ( [numTotalSizeQuota longValue] - 1 )  );
                      
                      [adminBstorageV2Test deleteQuotaForProjectOrTenantWithID:uidProjectOrTenantNonAdmin
                                                                        thenDo:^(bool isDeleted, id  _Nullable idFullResponse)
                       {
                           XCTAssertTrue( isDeleted );
                           [adminBstorageV2Test listQuotasForProjectOrTenantWithID:uidProjectOrTenantNonAdmin
                                                                            thenDo:^(NSDictionary * dicQuotas)
                            {
                                XCTAssertNotNil( dicQuotas );
                                XCTAssertTrue( [dicQuotas[ @"gigabytes" ] longValue] == [numTotalSizeQuota longValue]  );
                                
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

- ( void ) testBStorageListStoragePools
{
    __weak XCTestExpectation * expectation     = [self expectationWithDescription:@"Block Storage - volume transfer exist"];
    
    [adminBstorageV2Test listStoragePoolsThenDo:^(NSArray * _Nullable arrStoragePools)
     {
         XCTAssertNotNil( arrStoragePools);
         XCTAssertTrue( [arrStoragePools count] > 0 );
         
         [expectation fulfill];
     }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

/*Devstack is not setuped to allow testing of Quotas for users
- ( void ) testBStorageListUpdateAndDeleteQuotasForUser
{
    __weak XCTestExpectation * expectation     = [self expectationWithDescription:@"Block Storage - volume transfer exist"];
    NSString * uidProjectOrTenantNonAdmin   = authV3Session.currentProjectOrTenantID;
    NSString * uidUserNonAdmin              = authV3Session.currentUserID;
    
    XCTAssertNotNil( uidProjectOrTenantNonAdmin );
    
    [adminBstorageV2Test activateDebug:YES];
    [adminBstorageV2Test listQuotasForUserWithID:uidUserNonAdmin
                        andProjectOrTenantWithID:uidProjectOrTenantNonAdmin
                                          thenDo:^(NSDictionary * dicQuotas)
     {
         XCTAssertNotNil( dicQuotas );
         XCTAssertNotNil( dicQuotas[ @"gigabytes" ] );
         NSNumber * numTotalSizeQuota = dicQuotas[ @"gigabytes" ];
         
         [adminBstorageV2Test updateQuotaForUserWithID:uidUserNonAdmin
                              andProjectOrTenantWithID:uidProjectOrTenantNonAdmin
                                     newTotalSizeQuota:[NSNumber numberWithLong:[numTotalSizeQuota longValue] - 1]
                                       newVolumesQuota:@1
                                     newPerVolumeQuota:@1
                                        newBackupQuota:nil
                               newBackupTotalSizeQuota:nil
                                      newSnapshotQuota:nil
                                                thenDo:^(NSDictionary * updatedQuota)
          {
              [adminBstorageV2Test listQuotasForUserWithID:uidUserNonAdmin
                                  andProjectOrTenantWithID:uidProjectOrTenantNonAdmin
                                                    thenDo:^(NSDictionary * dicQuotas)
               {
                   XCTAssertNotNil( dicQuotas );
                   XCTAssertTrue( [dicQuotas[ @"gigabytes" ] longValue] == ( [numTotalSizeQuota longValue] - 1 )  );
                   
                   [adminBstorageV2Test deleteQuotaForUserWithID:uidUserNonAdmin
                                        andProjectOrTenantWithID:uidProjectOrTenantNonAdmin
                                                          thenDo:^(bool isDeleted, id  _Nullable idFullResponse)
                    {
                        XCTAssertTrue( isDeleted );
                        [adminBstorageV2Test listQuotasForUserWithID:uidUserNonAdmin
                                            andProjectOrTenantWithID:uidProjectOrTenantNonAdmin
                                                              thenDo:^(NSDictionary * dicQuotas)
                         {
                             XCTAssertNotNil( dicQuotas );
                             XCTAssertTrue( [dicQuotas[ @"gigabytes" ] longValue] == [numTotalSizeQuota longValue]  );
                             
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
 */

/*
- ( void ) testBStorageListUpdateAndDeleteConsistencyGroup
{
    __weak XCTestExpectation * expectation     = [self expectationWithDescription:@"Block Storage - volume transfer exist"];
    NSString * uidProjectOrTenantNonAdmin   = authV3Session.currentProjectOrTenantID;
    NSString * uidUserNonAdmin              = authV3Session.currentUserID;
    
    [adminBstorageV2Test activateDebug:YES];
    [adminBstorageV2Test listVolumeTypesThenDo:^(NSArray * _Nullable arrVolumeTypes, id  _Nullable idFullResponse)
    {
        XCTAssertNotNil( arrVolumeTypes );
        XCTAssertTrue( [arrVolumeTypes count] > 0 );
        NSDictionary * firstVolumeType =  arrVolumeTypes[ 0 ];
        
        NSString * uidFirstVolumeType = firstVolumeType[ @"id" ];
        NSLog( @"%@", firstVolumeType );
        XCTAssertNotNil( firstVolumeType[ @"id "]  );
        
        [adminBstorageV2Test createConsistencyGroupWithName:@"test consistency group for IOStack"
                                             andDescription:@"test description for consistency group"
                                             andVolumeTypes:@[ uidFirstVolumeType ]
                                                  forUserID:uidUserNonAdmin
                                               andProjectID:uidProjectOrTenantNonAdmin
                                                  andStatus:@"creating"
                                         inAvailabilityZone:nil
                                                     thenDo:^(NSDictionary * _Nullable createdConsistencyGroup, id  _Nullable dicFullResponse)
         {
             XCTAssertNotNil(createdConsistencyGroup);
             XCTAssertNotNil(createdConsistencyGroup[@"id"]);
             
             [adminBstorageV2Test updateConsistencyGroupWithID:createdConsistencyGroup[@"id"]
                                                       newName:nil
                                                newDescription:@"test update"
                                                    addVolumes:nil
                                                 removeVolumes:nil
                                                        thenDo:^(NSDictionary * _Nullable updatedConsistencyGroup, id  _Nullable dicFullResponse)
              {
                  XCTAssertNotNil( updatedConsistencyGroup );
                  XCTAssertTrue( [updatedConsistencyGroup[@"name"] isEqualToString:@"test consistency group for IOStack" ]);
                  XCTAssertTrue( [updatedConsistencyGroup[@"description"] isEqualToString:@"test update" ]);
                  
                  [adminBstorageV2Test listConsistencyGroupsThenDo:^(NSArray * _Nullable arrConsistencyGroups, id  _Nullable idFullResponse)
                   {
                       XCTAssertNotNil( arrConsistencyGroups );
                       XCTAssertTrue( [arrConsistencyGroups count] > 0  );
                       
                       [adminBstorageV2Test deleteConsistencyGroupWithID:createdConsistencyGroup[@"id"]
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
 */

@end
