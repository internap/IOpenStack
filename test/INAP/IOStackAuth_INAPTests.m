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
    NSString * currentSettingTests  = [NSString stringWithFormat:@"%@/../SettingsTests.plist", [currentTestFilePath stringByDeletingLastPathComponent]];
    
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

- ( void ) testAuthINAPNotASingleton
{
    IOStackAuth_INAP * auth2dSession = [IOStackAuth_INAP init];
    
    XCTAssertNotEqualObjects( auth2dSession, authINAPSession );
}

- ( void ) testAuthINAPIsSetupedCorrectly
{
    XCTAssertNotNil( authINAPSession );
    XCTAssertNotNil( [authINAPSession urlPublic] );
    XCTAssertTrue( [[[authINAPSession urlPublic] absoluteString] isEqualToString:dicSettingsTests[ @"INAP_IDENTITY_ROOT" ]] );
}

- ( void ) testAuthINAPAuthGiveValidToken
{
    XCTestExpectation * expectation = [self expectationWithDescription:@"INAP - token is valid"];
    
    [authINAPSession authenticateWithLogin:dicSettingsTests[ @"INAP_ACCOUNT_LOGIN" ]
                               andPassword:dicSettingsTests[ @"INAP_ACCOUNT_PASSWORD" ]
                                 forDomain:nil
                        andProjectOrTenant:dicSettingsTests[ @"INAP_ACCOUNT_PROJECTORTENANT" ]
                                    thenDo:^(NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse)
     {
         XCTAssertNotNil( strTokenIDResponse );
         XCTAssertNotNil( dicFullResponse );
         XCTAssertNotNil( authINAPSession.currentTokenID );
         
         [expectation fulfill];
     }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testAuthINAPProjectGiveAtLeastOneID
{
    XCTestExpectation * expectation = [self expectationWithDescription:@"INAP - project list is valid"];
    
    [authINAPSession authenticateWithLogin:dicSettingsTests[ @"INAP_ACCOUNT_LOGIN" ]
                               andPassword:dicSettingsTests[ @"INAP_ACCOUNT_PASSWORD" ]
                                 forDomain:dicSettingsTests[ @"INAP_ACCOUNT_DOMAIN" ]
                        andProjectOrTenant:dicSettingsTests[ @"INAP_ACCOUNT_PROJECTORTENANT" ]
                                    thenDo:^(NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse)
     {
         [authINAPSession listProjectsOrTenantsFrom:nil
                                               To:nil
                                           thenDo:^( NSArray * _Nullable arrProjectResponse )
          {
              //Internap doesn't allow normal users to list projects
              XCTAssertNil( arrProjectResponse );
              
              [expectation fulfill];
          }];
     }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^( NSError *error ) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testAuthINAPFirstProjectIsAuthorized
{
    XCTestExpectation * expectation = [self expectationWithDescription:@"INAP - project is authorized"];
    
    [authINAPSession listProjectsOrTenantsWithLogin:dicSettingsTests[ @"INAP_ACCOUNT_LOGIN" ]
                                        andPassword:dicSettingsTests[ @"INAP_ACCOUNT_PASSWORD" ]
                                          forDomain:nil
                                 andProjectOrTenant:dicSettingsTests[ @"INAP_ACCOUNT_PROJECTORTENANT"]
                                               From:nil To:nil
                                             thenDo:^( NSArray * _Nullable arrTenantResponse )
     {
         XCTAssertNil( arrTenantResponse );

         [expectation fulfill];
     }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^( NSError *error ) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testAuthINAPProjectDemoGotServices
{
    XCTestExpectation * expectation = [self expectationWithDescription:@"INAP - project has services"];
    
    [authINAPSession authenticateWithLogin:dicSettingsTests[ @"INAP_ACCOUNT_LOGIN" ]
                               andPassword:dicSettingsTests[ @"INAP_ACCOUNT_PASSWORD" ]
                                 forDomain:nil
                        andProjectOrTenant:dicSettingsTests[ @"INAP_ACCOUNT_PROJECTORTENANT" ]
                                    thenDo:^( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse )
     {
         XCTAssertNotNil( strTokenIDResponse );
         XCTAssertNotNil( dicFullResponse );
         
         XCTAssertNotNil( authINAPSession.currentTokenID );
         XCTAssertNotNil( authINAPSession.currentServices );
         XCTAssertNotNil( [authINAPSession.currentServices valueForKey:COMPUTE_SERVICE] );
         XCTAssertNotNil( [authINAPSession.currentServices valueForKey:NETWORK_SERVICE] );
         XCTAssertNotNil( [authINAPSession.currentServices valueForKey:IMAGESTORAGE_SERVICE] );
         XCTAssertNotNil( [authINAPSession.currentServices valueForKey:BLOCKSTORAGEV2_SERVICE] );
         XCTAssertNotNil( [authINAPSession.currentServices valueForKey:OBJECTSTORAGE_SERVICE] );
         XCTAssertNotNil( [authINAPSession.currentServices valueForKey:IDENTITY_SERVICE] );
         if( [authINAPSession.currentServices valueForKey:IDENTITY_SERVICE] )
         {
             IOStackService * identityService = [authINAPSession.currentServices valueForKey:IDENTITY_SERVICE];
             NSString * identityPublicWithoutID = [[identityService.urlPublic absoluteString] substringToIndex:[dicSettingsTests[ @"INAP_IDENTITY_ROOT" ] length]];
             XCTAssertTrue( [identityPublicWithoutID isEqualToString:dicSettingsTests[ @"INAP_IDENTITY_ROOT" ]]);
         }
         
         [expectation fulfill];
     }];

    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}


@end
