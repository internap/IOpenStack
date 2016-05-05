//
//  IOStackImage_DreamTests.m
//  IOpenStack
//
//  Created by Bruno Morel on 2016-04-30.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import <XCTest/XCTest.h>


#import     "IOStackAuth_Dream.h"
#import     "IOStackImageV2.h"


@interface IOStackImage_DreamTests : XCTestCase

@end


@implementation IOStackImage_DreamTests
{
    IOStackAuth_Dream *      authV3Session;
    IOStackImageV2 *        imageV2_1Test;
    NSDictionary *          dicSettingsTests;
}


- ( void )setUp
{
    [super setUp];
    NSString * currentTestFilePath  = @__FILE__;
    NSString * currentSettingTests  = [NSString stringWithFormat:@"%@/../SettingsTests.plist", [currentTestFilePath stringByDeletingLastPathComponent]];
    
    dicSettingsTests = [NSDictionary dictionaryWithContentsOfFile:currentSettingTests];
    
    XCTAssertNotNil( dicSettingsTests );
    XCTAssertNotNil( dicSettingsTests[ @"DREAM_IDENTITY_ROOT" ] );
    XCTAssertNotNil( dicSettingsTests[ @"DREAM_ACCOUNT_PROJECTORTENANT" ] );
    XCTAssertNotNil( dicSettingsTests[ @"DREAM_ACCOUNT_DOMAIN" ] );
    XCTAssertNotNil( dicSettingsTests[ @"DREAM_ACCOUNT_LOGIN" ] );
    XCTAssertNotNil( dicSettingsTests[ @"DREAM_ACCOUNT_PASSWORD" ] );
    XCTAssertNotNil( dicSettingsTests[ @"DREAM_IMAGE_ROOT" ] );
    
    __weak XCTestExpectation *exp = [self expectationWithDescription:@"Setuping Auth"];
    
    authV3Session = [IOStackAuth_Dream initWithLogin:dicSettingsTests[ @"DREAM_ACCOUNT_LOGIN" ]
                                         andPassword:dicSettingsTests[ @"DREAM_ACCOUNT_PASSWORD" ]
                                    forDefaultDomain:nil
                                  andProjectOrTenant:dicSettingsTests[ @"DREAM_ACCOUNT_PROJECTORTENANT" ]
                                              thenDo:^(NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse)
    {
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


- ( void ) testImageDreamNotASingleton
{
    XCTAssertNotNil(imageV2_1Test.currentTokenID);
    
    IOStackImageV2 *    imageV2_1Test2 = [IOStackImageV2 initWithImageURL:dicSettingsTests[ @"DREAM_IMAGE_ROOT" ]
                                                               andTokenID:authV3Session.currentTokenID];
    XCTAssertNotEqualObjects( imageV2_1Test, imageV2_1Test2 );
}

- ( void ) testImageDreamListFlavors
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
