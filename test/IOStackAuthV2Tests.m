//
//  IOStackAuthTests.m
//  IOpenStack
//
//  Created by Bruno Morel on 2015-11-26.
//  Copyright © 2015 Internap Inc. All rights reserved.
//

#import <XCTest/XCTest.h>

#import     "IOStackAuthV2.h"


@interface IOStackAuthV2Tests : XCTestCase


@end



@implementation IOStackAuthV2Tests
{
    IOStackAuthV2 *     authV2Session;
    NSDictionary *      dicSettingsTests;
}



- ( void ) setUp
{
    [super setUp];
    NSString * currentTestFilePath  = @__FILE__;
    NSString * currentSettingTests  = [NSString stringWithFormat:@"%@/SettingsTests.plist", [currentTestFilePath stringByDeletingLastPathComponent]];
    
    dicSettingsTests = [NSDictionary dictionaryWithContentsOfFile:currentSettingTests];
    
    XCTAssertNotNil( dicSettingsTests );
    XCTAssertNotNil( dicSettingsTests[ @"DEVSTACK_IDENTITY_ROOT" ] );
    XCTAssertNotNil( dicSettingsTests[ @"DEVSTACK_ACCOUNT_PROJECTORTENANT" ] );
    XCTAssertNotNil( dicSettingsTests[ @"DEVSTACK_ACCOUNT_LOGINDEMO" ] );
    XCTAssertNotNil( dicSettingsTests[ @"DEVSTACK_ACCOUNT_PASSWORDDEMO" ] );
    XCTAssertNotNil( dicSettingsTests[ @"DEVSTACK_ACCOUNT_LOGINADMIN" ] );
    XCTAssertNotNil( dicSettingsTests[ @"DEVSTACK_ACCOUNT_PASSWORDADMIN" ] );
    
    authV2Session = [IOStackAuthV2 initWithIdentityURL:dicSettingsTests[ @"DEVSTACK_IDENTITY_ROOT" ]];
}

- ( void ) tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- ( void ) testNotASingleton
{
    IOStackAuthV2 * auth2dSession = [IOStackAuthV2 initWithIdentityURL:dicSettingsTests[ @"DEVSTACK_IDENTITY_ROOT" ]];
    
    XCTAssertNotEqualObjects( auth2dSession, authV2Session );
}

- ( void ) testIsSetupedCorrectly
{
    XCTAssertNotNil( authV2Session );
    XCTAssertNotNil( [authV2Session urlPublic] );
    XCTAssertTrue( [[[authV2Session urlPublic] absoluteString] isEqualToString:dicSettingsTests[ @"DEVSTACK_IDENTITY_ROOT" ]] );
}

- ( void ) testAuthGiveValidToken
{
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"V2 - token is valid"];

    [authV2Session authenticateWithLogin:dicSettingsTests[ @"DEVSTACK_ACCOUNT_LOGINDEMO" ]
                             andPassword:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PASSWORDDEMO" ]
                               forDomain:nil
                      andProjectOrTenant:nil
                                  thenDo:^(NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse)
    {
        XCTAssertNotNil( strTokenIDResponse );
        XCTAssertNotNil( dicFullResponse );
        XCTAssertNotNil( authV2Session.currentTokenID );
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5000.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testTenantsGiveAtLeastOneID
{
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"V2 - tenant list is valid"];
    [authV2Session listProjectsOrTenantsWithLogin:dicSettingsTests[ @"DEVSTACK_ACCOUNT_LOGINDEMO" ]
                                      andPassword:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PASSWORDDEMO" ]
                                        forDomain:nil
                               andProjectOrTenant:nil
                                             From:nil To:nil
                                           thenDo:^( NSArray * _Nullable arrTenantResponse ) {
                                               XCTAssertNotNil( arrTenantResponse );
                                               XCTAssertGreaterThan( [arrTenantResponse count], 0 );
                                               [expectation fulfill];
                                           }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^( NSError *error ) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testFirstTenantIsAuthorized
{
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"V2 - tenant is authorized"];
    
    [authV2Session listProjectsOrTenantsWithLogin:dicSettingsTests[ @"DEVSTACK_ACCOUNT_LOGINDEMO" ]
                                      andPassword:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PASSWORDDEMO" ]
                                        forDomain:nil
                               andProjectOrTenant:nil
                                             From:nil To:nil
                                           thenDo:^( NSArray * _Nullable arrTenantResponse )
    {
        NSDictionary * firstTenant = [arrTenantResponse objectAtIndex:0];
        [authV2Session authenticateForDomain:nil
                          andProjectOrTenant:[firstTenant valueForKey:@"name"]
                                      thenDo:^( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse )
        {
            XCTAssertNotNil( strTokenIDResponse );
            XCTAssertNotNil( dicFullResponse );
            XCTAssertNotNil( authV2Session.currentTokenID );

            [expectation fulfill];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^( NSError *error ) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testTenantsDemoGotServices
{
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"V2 - demo project got services"];
    
    [authV2Session authenticateWithLogin:dicSettingsTests[ @"DEVSTACK_ACCOUNT_LOGINDEMO" ]
                             andPassword:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PASSWORDDEMO" ]
                               forDomain:nil
                      andProjectOrTenant:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PROJECTORTENANT" ]
                                  thenDo:^( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse )
    {
        XCTAssertNotNil( strTokenIDResponse );
        XCTAssertNotNil( dicFullResponse );
        
        XCTAssertNotNil( authV2Session.currentTokenID );
        XCTAssertNotNil( authV2Session.currentServices );
        XCTAssertNotNil( [authV2Session.currentServices valueForKey:COMPUTE_SERVICE] );
        XCTAssertNotNil( [authV2Session.currentServices valueForKey:NETWORK_SERVICE] );
        XCTAssertNotNil( [authV2Session.currentServices valueForKey:IMAGESTORAGE_SERVICE] );
        XCTAssertNotNil( [authV2Session.currentServices valueForKey:BLOCKSTORAGEV2_SERVICE] );
        XCTAssertNotNil( [authV2Session.currentServices valueForKey:IDENTITY_SERVICE] );
        if( [authV2Session.currentServices valueForKey:IDENTITY_SERVICE] )
        {
            IOStackService * identityService = [authV2Session.currentServices valueForKey:IDENTITY_SERVICE];
            NSString * identityPublicWithoutID = [[identityService.urlPublic absoluteString] substringToIndex:[dicSettingsTests[ @"DEVSTACK_IDENTITY_ROOT" ] length]];
            XCTAssertTrue( [identityPublicWithoutID isEqualToString:dicSettingsTests[ @"DEVSTACK_IDENTITY_ROOT" ]]);
        }
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}


- ( void ) testImageListExtensions
{
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"Image - extensions exist"];
    
    [authV2Session listExtensionsThenDo:^(NSArray * _Nullable arrExtensions)
    {
        XCTAssertNotNil( arrExtensions );
        XCTAssertTrue( [arrExtensions count] > 0 );
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}


@end
