//
//  IOStackImageV2Tests.m
//  IOpenStack
//
//  Created by Bruno Morel on 2016-01-24.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import <XCTest/XCTest.h>

#import     "IOStackAuthV3.h"
#import     "IOStackImageV2.h"


@interface IOStackImageV2Tests : XCTestCase

@end


@implementation IOStackImageV2Tests
{
    IOStackAuthV3 *         authV3Session;
    IOStackImageV2 *        imageV2_1Test;
    NSDictionary *          dicSettingsTests;
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
    XCTAssertNotNil( dicSettingsTests[ @"DEVSTACK_IMAGE_ROOT" ] );
    
    __weak XCTestExpectation *exp = [self expectationWithDescription:@"Setuping Auth"];
    
    authV3Session = [IOStackAuthV3 initWithIdentityURL:dicSettingsTests[ @"DEVSTACK_IDENTITY_ROOT" ]
                                              andLogin:dicSettingsTests[ @"DEVSTACK_ACCOUNT_LOGINDEMO" ]
                                           andPassword:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PASSWORDDEMO" ]
                                      forDefaultDomain:dicSettingsTests[ @"DEVSTACK_ACCOUNT_DOMAIN" ]
                                    andProjectOrTenant:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PROJECTORTENANT" ]
                                                thenDo:^(NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse){
        XCTAssertNotNil(strTokenIDResponse);
        
        imageV2_1Test = [IOStackImageV2 initWithIdentity:authV3Session];
        
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


- ( void ) testImageNotASingleton
{
    XCTAssertNotNil(imageV2_1Test.currentTokenID);
    
    IOStackImageV2 *    imageV2_1Test2 = [IOStackImageV2 initWithImageURL:dicSettingsTests[ @"DEVSTACK_IMAGE_ROOT" ]
                                                               andTokenID:authV3Session.currentTokenID];
    XCTAssertNotEqualObjects( imageV2_1Test, imageV2_1Test2 );
}

- ( void ) testImageListImages
{
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"Image - images exist"];
    
    [imageV2_1Test listImagesThenDo:^( NSDictionary * _Nullable dicImages ){
        XCTAssertNotNil( dicImages );
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testImageListDetailImages
{
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"Image - images exist"];
    
    [imageV2_1Test listImagesWithVisibility:@"public"
                                  andStatus:@"active"
                                     andTag:nil
                            andMemberStatus:nil
                                   andOwner:nil
                                    andName:@"cirros-0.3.4-x86_64-uec"
                                 andSizeMin:nil
                                 andSizeMax:nil
                            andCreationDate:nil
                             andUpdatedDate:nil
                                 sortByKeys:nil
                        sortByKeysDirection:nil
                                       From:nil
                                  withLimit:nil
                                     thenDo:^( NSDictionary * _Nullable dicImages )
    {
        XCTAssertNotNil( dicImages );
        XCTAssertTrue( [dicImages count] == 1 );
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testImageCreateDeactivateReactivateAndDeleteImage
{
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"Image - images exist"];
    
    NSString * currentTestFilePath      = @__FILE__;
    NSString * currentFakeFilePath      = [NSString stringWithFormat:@"%@/testkey-id_rsa.pub", [currentTestFilePath stringByDeletingLastPathComponent]];
    
    [imageV2_1Test createImageWithName:@"test image for IOStack"
                    andContainerFormat:IOStackImageContainerFormatBARE
                         andDiskFormat:IOStackImageDiskFormatRAW
                         andVisibility:@"private"
                                andTag:nil
                            andDiskMin:nil
                             andRAMMin:nil
                         andProperties:nil
                           isProtected:NO
                           andForcedID:nil
                                thenDo:^(IOStackImageObjectV2 * _Nullable createdImage)
    {
        XCTAssertNotNil( createdImage );
        XCTAssertNotNil( createdImage.uniqueID );
        XCTAssertTrue( [createdImage.name isEqualToString:@"test image for IOStack"] );
        
        [imageV2_1Test uploadImageWithID:createdImage.uniqueID
                        fromFileWithPath:currentFakeFilePath
                                  thenDo:^(BOOL isUploaded)
         {
             [imageV2_1Test deactivateImageWithID:createdImage.uniqueID
                                           thenDo:^(BOOL isDeactivated, id  _Nullable dicFullResponse)
              {
                  XCTAssertTrue( isDeactivated );
                  
                  [imageV2_1Test listImagesThenDo:^( NSDictionary * _Nullable dicImages )
                   {
                       IOStackImageObjectV2 * newImage = dicImages[ createdImage.uniqueID ];
                       XCTAssertNotNil( newImage );
                       XCTAssertTrue( [newImage.status isEqualToString:@"active"]);
                       
                       [imageV2_1Test reactivateImageWithID:createdImage.uniqueID
                                                     thenDo:^(BOOL isReactivated, id  _Nullable dicFullResponse)
                        {
                            XCTAssertTrue( isReactivated );
                            [imageV2_1Test deleteImageWithID:createdImage.uniqueID
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


@end
