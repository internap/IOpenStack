//
//  IOStackAuth_DreamTests.m
//  IOpenStack
//
//  Created by Bruno Morel on 2016-01-12.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "IOStackAuth_Dream.h"


@interface IOStackAuth_DreamTests : XCTestCase

@end



@implementation IOStackAuth_DreamTests
{
    IOStackAuth_Dream * authDreamSession;
    NSDictionary *      dicSettingsTests;
}


- ( void ) setUp
{
    [super setUp];
    NSString * currentTestFilePath  = @__FILE__;
    NSString * currentSettingTests  = [NSString stringWithFormat:@"%@/SettingsTests.plist", [currentTestFilePath stringByDeletingLastPathComponent]];
    
    dicSettingsTests = [NSDictionary dictionaryWithContentsOfFile:currentSettingTests];
    
    XCTAssertNotNil( dicSettingsTests );
    XCTAssertNotNil( dicSettingsTests[ @"DREAM_ACCOUNT_DOMAIN" ] );
    XCTAssertNotNil( dicSettingsTests[ @"DREAM_ACCOUNT_PROJECTORTENANT" ] );
    XCTAssertNotNil( dicSettingsTests[ @"DREAM_ACCOUNT_LOGIN" ] );
    XCTAssertNotNil( dicSettingsTests[ @"DREAM_ACCOUNT_PASSWORD" ] );
    
    authDreamSession = [IOStackAuth_Dream init];
}

- ( void ) tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- ( void ) testDreamNotASingleton
{
    IOStackAuth_Dream * auth2dSession = [IOStackAuth_Dream init];
    
    XCTAssertNotEqualObjects( auth2dSession, authDreamSession );
}

- ( void ) testDreamIsSetupedCorrectly
{
    XCTAssertNotNil( authDreamSession.iostackV2Manager );
    
    XCTAssertNotNil( [authDreamSession.iostackV2Manager.managerIdentity baseURL] );}

- ( void ) testDreamAuthGiveValidToken
{
    XCTestExpectation * expectation = [self expectationWithDescription:@"Dream - token is valid"];
    
    [authDreamSession authenticateWithLogin:dicSettingsTests[ @"DREAM_ACCOUNT_LOGIN" ]
                                andPassword:dicSettingsTests[ @"DREAM_ACCOUNT_PASSWORD" ]
                                  forDomain:dicSettingsTests[ @"DREAM_ACCOUNT_DOMAIN" ]
                         andProjectOrTenant:dicSettingsTests[ @"DREAM_ACCOUNT_PROJECTORTENANT" ]
                                     thenDo:^(NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse) {
                                         XCTAssertNotNil( strTokenIDResponse );
                                         XCTAssertNotNil( dicFullResponse );
                                         XCTAssertNotNil( authDreamSession.iostackV2Manager.currentTokenID );
                                        
                                         [expectation fulfill];
                                    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testDreamProjectGiveAtLeastOneID
{
    XCTestExpectation * expectation = [self expectationWithDescription:@"Dream - project list is valid"];
    
    [authDreamSession listProjectsWithLogin:dicSettingsTests[ @"DREAM_ACCOUNT_LOGIN" ]
                                andPassword:dicSettingsTests[ @"DREAM_ACCOUNT_PASSWORD" ]
                                  forDomain:dicSettingsTests[ @"DREAM_ACCOUNT_DOMAIN" ]
                         andProjectOrTenant:dicSettingsTests[ @"DREAM_ACCOUNT_PROJECTORTENANT" ]
                                     thenDo:^( NSArray * _Nullable arrProjectResponse ) {
                                         XCTAssertNotNil( arrProjectResponse );
                                         XCTAssertGreaterThan( [arrProjectResponse count], 0 );
                                        
                                         [expectation fulfill];
                                    }];
    
    
    [self waitForExpectationsWithTimeout:5.0 handler:^( NSError *error ) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testDreamFirstProjectIsAuthorized
{
    XCTestExpectation * expectation = [self expectationWithDescription:@"Dream - project is authorized"];
    
    [authDreamSession listProjectsWithLogin:dicSettingsTests[ @"DREAM_ACCOUNT_LOGIN" ]
                                andPassword:dicSettingsTests[ @"DREAM_ACCOUNT_PASSWORD" ]
                                  forDomain:dicSettingsTests[ @"DREAM_ACCOUNT_DOMAIN" ]
                         andProjectOrTenant:dicSettingsTests[ @"DREAM_ACCOUNT_PROJECTORTENANT" ]
                                     thenDo:^( NSArray * _Nullable arrProjectResponse ) {
                                         XCTAssertNotNil( arrProjectResponse );
                                         XCTAssertGreaterThan( [arrProjectResponse count], 0 );
                                         NSDictionary * firstProject = [arrProjectResponse objectAtIndex:0];
                                         [authDreamSession authenticateForProjectOrTenant:[firstProject valueForKey:@"name"]
                                                                                   thenDo:^(NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse) {
                                                                                       XCTAssertNotNil( strTokenIDResponse );
                                                                                       XCTAssertNotNil( dicFullResponse );
                                                                                       XCTAssertNotNil( authDreamSession.iostackV2Manager.currentTokenID );
                                                                                     
                                                                                       [expectation fulfill];
                                                                                   }];
                                     }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^( NSError *error ) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testDreamProjectDemoGotServices
{
    XCTestExpectation * expectation = [self expectationWithDescription:@"Dream - project has services"];
    
    [authDreamSession authenticateWithLogin:dicSettingsTests[ @"DREAM_ACCOUNT_LOGIN" ]
                                andPassword:dicSettingsTests[ @"DREAM_ACCOUNT_PASSWORD" ]
                                  forDomain:dicSettingsTests[ @"DREAM_ACCOUNT_DOMAIN" ]
                         andProjectOrTenant:dicSettingsTests[ @"DREAM_ACCOUNT_PROJECTORTENANT" ]
                                     thenDo:^( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse ) {
                                         XCTAssertNotNil( strTokenIDResponse );
                                         XCTAssertNotNil( dicFullResponse );
                                         XCTAssertNotNil( authDreamSession.iostackV2Manager.currentTokenID );
                                        
                                         XCTAssertNotNil( authDreamSession.iostackV2Manager.currentServices );
                                        
                                         [expectation fulfill];
                                     }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}


@end
