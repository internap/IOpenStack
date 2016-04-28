//
//  IOStackAuth_INAP.m
//  IOpenStack
//
//  Created by Bruno Morel on 2015-12-07.
//  Copyright © 2015 Internap Inc. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "IOStackAuth_INAP.h"


@interface IOStackAuth_INAPTests : XCTestCase

@end



@implementation IOStackAuth_INAPTests
{
    IOStackAuth_INAP *  authINAPSession;
    NSDictionary *      dicSettingsTests;
}


- ( void ) setUp
{
    [super setUp];
    NSString * currentTestFilePath  = @__FILE__;
    NSString * currentSettingTests  = [NSString stringWithFormat:@"%@/SettingsTests.plist", [currentTestFilePath stringByDeletingLastPathComponent]];
    
    dicSettingsTests = [NSDictionary dictionaryWithContentsOfFile:currentSettingTests];
    
    XCTAssertNotNil( dicSettingsTests );
    XCTAssertNotNil( dicSettingsTests[ @"INAP_ACCOUNT_DOMAIN" ] );
    XCTAssertNotNil( dicSettingsTests[ @"INAP_ACCOUNT_PROJECTORTENANT" ] );
    XCTAssertNotNil( dicSettingsTests[ @"INAP_ACCOUNT_LOGIN" ] );
    XCTAssertNotNil( dicSettingsTests[ @"INAP_ACCOUNT_PASSWORD" ] );
    
    authINAPSession = [IOStackAuth_INAP init];
}

- ( void ) tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- ( void ) testINAPNotASingleton
{
    IOStackAuth_INAP * auth2dSession = [IOStackAuth_INAP init];
    
    XCTAssertNotEqualObjects( auth2dSession, authINAPSession );
}

- ( void ) testINAPIsSetupedCorrectly
{
    XCTAssertNotNil( authINAPSession.iostackV2Manager );
    XCTAssertNotNil( authINAPSession.iostackV3Manager );
}

- ( void ) testINAPAuthGiveValidToken
{
    XCTestExpectation * expectation = [self expectationWithDescription:@"INAP - token is valid"];
    
    [authINAPSession authenticateWithLogin:dicSettingsTests[ @"INAP_ACCOUNT_LOGIN" ]
                               andPassword:dicSettingsTests[ @"INAP_ACCOUNT_PASSWORD" ]
                                 forDomain:dicSettingsTests[ @"INAP_ACCOUNT_DOMAIN" ]
                        andProjectOrTenant:dicSettingsTests[ @"INAP_ACCOUNT_PROJECTORTENANT" ]
                                  thenDo:^(NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse) {
                                      XCTAssertNotNil( strTokenIDResponse );
                                      XCTAssertNotNil( dicFullResponse );
                                      XCTAssertNotNil( authINAPSession.iostackV2Manager.currentTokenID );
                                      XCTAssertNotNil( authINAPSession.iostackV3Manager.currentTokenID );
                                      
                                      [expectation fulfill];
                                  }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testINAPProjectGiveAtLeastOneID
{
    XCTestExpectation * expectation = [self expectationWithDescription:@"INAP - project list is valid"];
    
    [authINAPSession listProjectsOrTenantsWithLogin:dicSettingsTests[ @"INAP_ACCOUNT_LOGIN" ]
                                        andPassword:dicSettingsTests[ @"INAP_ACCOUNT_PASSWORD" ]
                                          forDomain:dicSettingsTests[ @"INAP_ACCOUNT_DOMAIN" ]
                                               From:nil To:nil
                                             thenDo:^( NSArray * _Nullable arrProjectResponse ) {
                                                 XCTAssertNotNil( arrProjectResponse );
                                                 XCTAssertGreaterThan( [arrProjectResponse count], 0 );
                                                 
                                                 [expectation fulfill];
                                             }];

    
    [self waitForExpectationsWithTimeout:5.0 handler:^( NSError *error ) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testINAPFirstProjectIsAuthorized
{
    XCTestExpectation * expectation = [self expectationWithDescription:@"INAP - project is authorized"];
    
    [authINAPSession listProjectsOrTenantsWithLogin:dicSettingsTests[ @"INAP_ACCOUNT_LOGIN" ]
                                        andPassword:dicSettingsTests[ @"INAP_ACCOUNT_PASSWORD" ]
                                          forDomain:dicSettingsTests[ @"INAP_ACCOUNT_DOMAIN" ]
                                               From:nil To:nil
                                             thenDo:^( NSArray * _Nullable arrProjectResponse ) {
                                                 if( arrProjectResponse == nil )
                                                     return;
                                                 
                                                 NSDictionary * firstProject = [arrProjectResponse objectAtIndex:0];
                                                 [authINAPSession authenticateForDomain:nil
                                                                     andProjectOrTenant:[firstProject valueForKey:@"name"]
                                                                                 thenDo:^(NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse) {
                                                                                     XCTAssertNotNil( strTokenIDResponse );
                                                                                     XCTAssertNotNil( dicFullResponse );
                                                                                     XCTAssertNotNil( authINAPSession.iostackV2Manager.currentTokenID );
                                                                                     XCTAssertNotNil( authINAPSession.iostackV3Manager.currentTokenID );
                                                                            
                                                                                     [expectation fulfill];
                                                                                 }];
                                             }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^( NSError *error ) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testINAPProjectDemoGotServices
{
    XCTestExpectation * expectation = [self expectationWithDescription:@"INAP - project has services"];
    
    [authINAPSession authenticateWithLogin:dicSettingsTests[ @"INAP_ACCOUNT_LOGIN" ]
                               andPassword:dicSettingsTests[ @"INAP_ACCOUNT_PASSWORD" ]
                                 forDomain:dicSettingsTests[ @"INAP_ACCOUNT_DOMAIN" ]
                        andProjectOrTenant:dicSettingsTests[ @"INAP_ACCOUNT_PROJECTORTENANT" ]
                                    thenDo:^( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse ) {
                                        XCTAssertNotNil( strTokenIDResponse );
                                        XCTAssertNotNil( dicFullResponse );
                                        XCTAssertNotNil( authINAPSession.iostackV2Manager.currentTokenID );
                                        XCTAssertNotNil( authINAPSession.iostackV3Manager.currentTokenID );
                                      
                                        XCTAssertNotNil( authINAPSession.iostackV2Manager.currentServices );
                                        XCTAssertNotNil( authINAPSession.iostackV3Manager.currentServices );
                                      
                                        [expectation fulfill];
                                  }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}


@end
