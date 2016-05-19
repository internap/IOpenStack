//
//  getting_started.m
//  IOpenStack
//
//  Created by Bruno Morel on 2016-05-19.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import <XCTest/XCTest.h>


#import     "IOStackAuthV3.h"
#import     "IOStackImageV2.h"
#import     "IOStackComputeV2_1.h"


@interface getting_started : XCTestCase

@end


@implementation getting_started
{
    IOStackAuthV3 *         authV3Session;
    IOStackImageV2 *        imageV2;
    IOStackComputeV2_1 *    computeV2_1Test;
    NSArray *               arrOSImages;
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
    XCTAssertNotNil( dicSettingsTests[ @"DEVSTACK_COMPUTE_ROOT" ] );
}

- ( void ) tearDown
{
    [super tearDown];
}

- (void)testFirstApp1_1
{
    __weak XCTestExpectation * exp = [self expectationWithDescription:@"Setuping Auth"];
    
    authV3Session = [IOStackAuthV3 initWithIdentityURL:dicSettingsTests[ @"DEVSTACK_IDENTITY_ROOT" ]
                                              andLogin:dicSettingsTests[ @"DEVSTACK_ACCOUNT_LOGINDEMO" ]
                                           andPassword:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PASSWORDDEMO" ]
                                      forDefaultDomain:dicSettingsTests[ @"DEVSTACK_ACCOUNT_DOMAIN" ]
                                    andProjectOrTenant:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PROJECTORTENANT" ]
                                                thenDo:^(NSString * strTokenIDResponse, NSDictionary * dicFullResponse)
                     {
                         XCTAssertNotNil(strTokenIDResponse);
                         
                         imageV2 = [IOStackImageV2 initWithIdentity:authV3Session];
                         [imageV2 listImagesThenDo:^( NSDictionary * dicImages ){
                             arrOSImages = [dicImages allValues];
                             
                             computeV2_1Test = [IOStackComputeV2_1 initWithIdentity:authV3Session];
                             
                             [exp fulfill];
                         }];
                     }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        // handle failure
    }];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
