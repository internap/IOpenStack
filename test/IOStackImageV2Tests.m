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

- ( void ) testImageListFlavors
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


@end
