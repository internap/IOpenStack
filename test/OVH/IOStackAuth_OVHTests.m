//
//  IOStackAuth_OVHTests.m
//  IOpenStack
//
//  Created by Bruno Morel on 2016-01-12.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "IOStackAuth_OVH.h"


@interface IOStackAuth_OVHTests : XCTestCase

@end



@implementation IOStackAuth_OVHTests
{
    IOStackAuth_OVH *   authOVHSession;
    NSDictionary *      dicSettingsTests;
}


- ( void ) setUp
{
    [super setUp];
    NSString * currentTestFilePath  = @__FILE__;
    NSString * currentSettingTests  = [NSString stringWithFormat:@"%@/SettingsTests.plist", [currentTestFilePath stringByDeletingLastPathComponent]];
    
    dicSettingsTests = [NSDictionary dictionaryWithContentsOfFile:currentSettingTests];
    
    XCTAssertNotNil( dicSettingsTests );
    XCTAssertNotNil( dicSettingsTests[ @"OVH_ACCOUNT_DOMAIN" ] );
    XCTAssertNotNil( dicSettingsTests[ @"OVH_ACCOUNT_PROJECTORTENANT" ] );
    XCTAssertNotNil( dicSettingsTests[ @"OVH_ACCOUNT_LOGIN" ] );
    XCTAssertNotNil( dicSettingsTests[ @"OVH_ACCOUNT_PASSWORD" ] );
    
    authOVHSession = [IOStackAuth_OVH init];
}

- ( void ) tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- ( void ) testOVHNotASingleton
{
    IOStackAuth_OVH * auth2dSession = [IOStackAuth_OVH init];
    
    XCTAssertNotEqualObjects( auth2dSession, authOVHSession );
}

- ( void ) testOVHIsSetupedCorrectly
{
    XCTAssertNotNil( authOVHSession.iostackV2Manager );
    
    XCTAssertNotNil( [authOVHSession.iostackV2Manager.managerIdentity baseURL] );}

- ( void ) testOVHAuthGiveValidToken
{
    XCTestExpectation * expectation = [self expectationWithDescription:@"OVH - token is valid"];
    
    [authOVHSession authenticateWithLogin:dicSettingsTests[ @"OVH_ACCOUNT_LOGIN" ]
                              andPassword:dicSettingsTests[ @"OVH_ACCOUNT_PASSWORD" ]
                                forDomain:dicSettingsTests[ @"OVH_ACCOUNT_DOMAIN" ]
                       andProjectOrTenant:dicSettingsTests[ @"OVH_ACCOUNT_PROJECTORTENANT" ]
                                   thenDo:^(NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse) {
                                       XCTAssertNotNil( strTokenIDResponse );
                                       XCTAssertNotNil( dicFullResponse );
                                       XCTAssertNotNil( authOVHSession.iostackV2Manager.currentTokenID );
                                         
                                       [expectation fulfill];
                                   }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testOVHProjectGiveAtLeastOneID
{
    XCTestExpectation * expectation = [self expectationWithDescription:@"OVH - project list is valid"];
    
    [authOVHSession listProjectsWithLogin:dicSettingsTests[ @"OVH_ACCOUNT_LOGIN" ]
                                andPassword:dicSettingsTests[ @"OVH_ACCOUNT_PASSWORD" ]
                                  forDomain:dicSettingsTests[ @"OVH_ACCOUNT_DOMAIN" ]
                         andProjectOrTenant:dicSettingsTests[ @"OVH_ACCOUNT_PROJECTORTENANT" ]
                                     thenDo:^( NSArray * _Nullable arrProjectResponse ) {
                                         XCTAssertNotNil( arrProjectResponse );
                                         XCTAssertGreaterThan( [arrProjectResponse count], 0 );
                                         
                                         [expectation fulfill];
                                     }];
    
    
    [self waitForExpectationsWithTimeout:5.0 handler:^( NSError *error ) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testOVHFirstProjectIsAuthorized
{
    XCTestExpectation * expectation = [self expectationWithDescription:@"OVH - project is authorized"];
    
    [authOVHSession listProjectsWithLogin:dicSettingsTests[ @"OVH_ACCOUNT_LOGIN" ]
                              andPassword:dicSettingsTests[ @"OVH_ACCOUNT_PASSWORD" ]
                                forDomain:dicSettingsTests[ @"OVH_ACCOUNT_DOMAIN" ]
                       andProjectOrTenant:dicSettingsTests[ @"OVH_ACCOUNT_PROJECTORTENANT" ]
                                   thenDo:^( NSArray * _Nullable arrProjectResponse ) {
                                       XCTAssertNotNil( arrProjectResponse );
                                       XCTAssertGreaterThan( [arrProjectResponse count], 0 );
                                       NSDictionary * firstProject = [arrProjectResponse objectAtIndex:0];
                                       [authOVHSession authenticateForProjectOrTenant:[firstProject valueForKey:@"name"]
                                                                               thenDo:^(NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse) {
                                                                                   XCTAssertNotNil( strTokenIDResponse );
                                                                                   XCTAssertNotNil( dicFullResponse );
                                                                                   XCTAssertNotNil( authOVHSession.iostackV2Manager.currentTokenID );
                                                                                   
                                                                                   [expectation fulfill];
                                                                               }];
                                   }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^( NSError *error ) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testOVHProjectDemoGotServices
{
    XCTestExpectation * expectation = [self expectationWithDescription:@"OVH - project has services"];
    
    [authOVHSession authenticateWithLogin:dicSettingsTests[ @"OVH_ACCOUNT_LOGIN" ]
                              andPassword:dicSettingsTests[ @"OVH_ACCOUNT_PASSWORD" ]
                                forDomain:dicSettingsTests[ @"OVH_ACCOUNT_DOMAIN" ]
                       andProjectOrTenant:dicSettingsTests[ @"OVH_ACCOUNT_PROJECTORTENANT" ]
                                   thenDo:^( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse ) {
                                       XCTAssertNotNil( strTokenIDResponse );
                                       XCTAssertNotNil( dicFullResponse );
                                       XCTAssertNotNil( authOVHSession.iostackV2Manager.currentTokenID );
                                       
                                       XCTAssertNotNil( authOVHSession.iostackV2Manager.currentServices );
                                       
                                       [expectation fulfill];
                                   }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}


@end
