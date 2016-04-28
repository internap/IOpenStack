//
//  IOStackAuthV3Tests.m
//  IOpenStack
//
//  Created by Bruno Morel on 2015-12-18.
//  Copyright © 2015 Internap Inc. All rights reserved.
//

#import <XCTest/XCTest.h>

#include "IOStackAuthV3.h"


@interface IOStackAuthV3Tests : XCTestCase

@end


@implementation IOStackAuthV3Tests
{
    IOStackAuthV3 *     authV3Session;
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
    XCTAssertNotNil( dicSettingsTests[ @"DEVSTACK_ACCOUNT_DOMAIN" ] );
    XCTAssertNotNil( dicSettingsTests[ @"DEVSTACK_ACCOUNT_LOGINDEMO" ] );
    XCTAssertNotNil( dicSettingsTests[ @"DEVSTACK_ACCOUNT_PASSWORDDEMO" ] );
    XCTAssertNotNil( dicSettingsTests[ @"DEVSTACK_ACCOUNT_LOGINADMIN" ] );
    XCTAssertNotNil( dicSettingsTests[ @"DEVSTACK_ACCOUNT_PASSWORDADMIN" ] );
    
    authV3Session = [IOStackAuthV3 initWithIdentityURL:dicSettingsTests[ @"DEVSTACK_IDENTITY_ROOT" ]];
}

- ( void ) tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- ( void ) testNotASingleton
{
    IOStackAuthV3 * auth2dSession = [IOStackAuthV3 initWithIdentityURL:dicSettingsTests[ @"DEVSTACK_IDENTITY_ROOT" ]];
    
    XCTAssertNotEqualObjects( auth2dSession, authV3Session );
}

- ( void ) testIsSetupedCorrectly
{
    XCTAssertNotNil( authV3Session );
    XCTAssertNotNil( [authV3Session urlPublic] );
    XCTAssertTrue( [[[authV3Session urlPublic] absoluteString] isEqualToString:dicSettingsTests[ @"DEVSTACK_IDENTITY_ROOT" ]] );
    XCTAssertTrue( [authV3Session.currentDomain isEqualToString:@"Default"] );
}

- ( void ) testAuthGiveValidToken
{
    XCTestExpectation * expectation = [self expectationWithDescription:@"V3 - token is valid"];
    
    [authV3Session authenticateWithLogin:dicSettingsTests[ @"DEVSTACK_ACCOUNT_LOGINDEMO" ]
                             andPassword:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PASSWORDDEMO" ]
                               forDomain:dicSettingsTests[ @"DEVSTACK_ACCOUNT_DOMAIN" ]
                      andProjectOrTenant:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PROJECTORTENANT" ]
                                  thenDo:^(NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse)
    {
        XCTAssertNotNil( strTokenIDResponse );
        XCTAssertNotNil( authV3Session.currentTokenID );
        XCTAssertNotNil( dicFullResponse );
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}


- ( void ) testProjectsGiveAtLeastOneID
{
    XCTestExpectation * expectation = [self expectationWithDescription:@"V3 - project list is valid"];
    
    [authV3Session authenticateWithLogin:dicSettingsTests[ @"DEVSTACK_ACCOUNT_LOGINADMIN" ]
                             andPassword:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PASSWORDADMIN" ]
                               forDomain:dicSettingsTests[ @"DEVSTACK_ACCOUNT_DOMAIN" ]
                      andProjectOrTenant:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PROJECTORTENANT" ]
                                  thenDo:^(NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse)
    {
        [authV3Session listProjectsOrTenantsFrom:nil
                                              To:nil
                                          thenDo:^( NSArray * _Nullable arrProjectResponse )
        {
            XCTAssertNotNil( arrProjectResponse );
            XCTAssertGreaterThan( [arrProjectResponse count], 0 );
            
            [expectation fulfill];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^( NSError *error ) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testFirstProjectIsAuthorized
{
    XCTestExpectation * expectation = [self expectationWithDescription:@"V3 - project is authorized"];
    
    [authV3Session authenticateWithLogin:dicSettingsTests[ @"DEVSTACK_ACCOUNT_LOGINADMIN" ]
                             andPassword:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PASSWORDADMIN" ]
                               forDomain:dicSettingsTests[ @"DEVSTACK_ACCOUNT_DOMAIN" ]
                      andProjectOrTenant:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PROJECTORTENANT" ]
                                  thenDo:^(NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse)
    {
        [authV3Session listProjectsOrTenantsFrom:nil
                                              To:nil
                                          thenDo:^( NSArray * _Nullable arrProjectResponse )
        {
            XCTAssertNotNil(arrProjectResponse);
            if( arrProjectResponse == nil )
                return;
            NSDictionary * firstProject = [arrProjectResponse objectAtIndex:0];
            XCTAssertNotNil(firstProject);
            
            [expectation fulfill];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^( NSError *error ) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testProjectDemoGotServices
{
    XCTestExpectation * expectation = [self expectationWithDescription:@"V3 - project got service"];
    
    [authV3Session authenticateWithLogin:dicSettingsTests[ @"DEVSTACK_ACCOUNT_LOGINDEMO" ]
                             andPassword:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PASSWORDDEMO" ]
                               forDomain:dicSettingsTests[ @"DEVSTACK_ACCOUNT_DOMAIN" ]
                      andProjectOrTenant:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PROJECTORTENANT" ]
                                  thenDo:^( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse )
    {
        XCTAssertNotNil( strTokenIDResponse );
        XCTAssertNotNil( dicFullResponse );
        XCTAssertNotNil( authV3Session.currentTokenID );
        
        XCTAssertNotNil( authV3Session.currentServices );
        XCTAssertNotNil( [authV3Session.currentServices valueForKey:COMPUTE_SERVICE] );
        XCTAssertNotNil( [authV3Session.currentServices valueForKey:NETWORK_SERVICE] );
        XCTAssertNotNil( [authV3Session.currentServices valueForKey:IMAGESTORAGE_SERVICE] );
        XCTAssertNotNil( [authV3Session.currentServices valueForKey:BLOCKSTORAGEV2_SERVICE] );
        XCTAssertNotNil( [authV3Session.currentServices valueForKey:IDENTITY_SERVICE] );
        if( [authV3Session.currentServices valueForKey:IDENTITY_SERVICE] )
        {
            IOStackService * identityService = [authV3Session.currentServices valueForKey:IDENTITY_SERVICE];
            NSString * identityPublicWithoutID = [[identityService.urlPublic absoluteString] substringToIndex:[dicSettingsTests[ @"DEVSTACK_IDENTITY_ROOT" ] length]];
            XCTAssertTrue( [identityPublicWithoutID isEqualToString:dicSettingsTests[ @"DEVSTACK_IDENTITY_ROOT" ]]);
        }
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}


@end
