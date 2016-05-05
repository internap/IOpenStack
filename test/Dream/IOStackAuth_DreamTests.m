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
    NSString * currentSettingTests  = [NSString stringWithFormat:@"%@/../SettingsTests.plist", [currentTestFilePath stringByDeletingLastPathComponent]];
    
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

- ( void ) testAuthDreamNotASingleton
{
    IOStackAuth_Dream * auth2dSession = [IOStackAuth_Dream init];
    
    XCTAssertNotEqualObjects( auth2dSession, authDreamSession );
}

- ( void ) testAuthDreamIsSetupedCorrectly
{
    XCTAssertNotNil( authDreamSession );
    
    XCTAssertNotNil( [authDreamSession urlPublic] );
    XCTAssertTrue( [[[authDreamSession urlPublic] absoluteString] isEqualToString:dicSettingsTests[ @"DREAM_IDENTITY_ROOT" ]] );
}

- ( void ) testAuthDreamAuthGiveValidToken
{
    XCTestExpectation * expectation = [self expectationWithDescription:@"Dream - token is valid"];
    
    [authDreamSession authenticateWithLogin:dicSettingsTests[ @"DREAM_ACCOUNT_LOGIN" ]
                                andPassword:dicSettingsTests[ @"DREAM_ACCOUNT_PASSWORD" ]
                                  forDomain:nil
                         andProjectOrTenant:nil
                                     thenDo:^(NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse)
     {
         XCTAssertNotNil( strTokenIDResponse );
         XCTAssertNotNil( dicFullResponse );
         XCTAssertNotNil( authDreamSession.currentTokenID );
         
         [expectation fulfill];
     }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testAuthDreamProjectGiveAtLeastOneID
{
    XCTestExpectation * expectation = [self expectationWithDescription:@"V2 - tenant list is valid"];
    [authDreamSession listProjectsOrTenantsWithLogin:dicSettingsTests[ @"DREAM_ACCOUNT_LOGIN" ]
                                         andPassword:dicSettingsTests[ @"DREAM_ACCOUNT_PASSWORD" ]
                                           forDomain:nil
                                  andProjectOrTenant:nil
                                                From:nil To:nil
                                              thenDo:^( NSArray * _Nullable arrTenantResponse )
     {
         XCTAssertNotNil( arrTenantResponse );
         XCTAssertGreaterThan( [arrTenantResponse count], 0 );
         [expectation fulfill];
     }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^( NSError *error ) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testAuthDreamFirstProjectIsAuthorized
{
    XCTestExpectation * expectation = [self expectationWithDescription:@"Dream - project is authorized"];
    
    [authDreamSession listProjectsOrTenantsWithLogin:dicSettingsTests[ @"DREAM_ACCOUNT_LOGIN" ]
                                         andPassword:dicSettingsTests[ @"DREAM_ACCOUNT_PASSWORD" ]
                                           forDomain:nil
                                  andProjectOrTenant:nil
                                                From:nil To:nil
                                              thenDo:^( NSArray * _Nullable arrTenantResponse )
     {
         NSDictionary * firstTenant = [arrTenantResponse objectAtIndex:0];
         [authDreamSession authenticateForDomain:nil
                              andProjectOrTenant:[firstTenant valueForKey:@"name"]
                                          thenDo:^( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse )
          {
              XCTAssertNotNil( strTokenIDResponse );
              XCTAssertNotNil( dicFullResponse );
              XCTAssertNotNil( authDreamSession.currentTokenID );
              
              [expectation fulfill];
          }];
     }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^( NSError *error ) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testAuthDreamGotServices
{
    XCTestExpectation * expectation = [self expectationWithDescription:@"V2 - tenant got services"];
    
    [authDreamSession authenticateWithLogin:dicSettingsTests[ @"DREAM_ACCOUNT_LOGIN" ]
                                andPassword:dicSettingsTests[ @"DREAM_ACCOUNT_PASSWORD" ]
                                  forDomain:nil
                         andProjectOrTenant:dicSettingsTests[ @"DREAM_ACCOUNT_PROJECTORTENANT" ]
                                     thenDo:^( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse )
     {
         XCTAssertNotNil( strTokenIDResponse );
         XCTAssertNotNil( dicFullResponse );
         
         XCTAssertNotNil( authDreamSession.currentTokenID );
         XCTAssertNotNil( authDreamSession.currentServices );
         XCTAssertNotNil( [authDreamSession.currentServices valueForKey:COMPUTE_SERVICE] );
         XCTAssertNotNil( [authDreamSession.currentServices valueForKey:NETWORK_SERVICE] );
         XCTAssertNotNil( [authDreamSession.currentServices valueForKey:IMAGESTORAGE_SERVICE] );
         XCTAssertNotNil( [authDreamSession.currentServices valueForKey:BLOCKSTORAGEV2_SERVICE] );
         XCTAssertNotNil( [authDreamSession.currentServices valueForKey:IDENTITY_SERVICE] );
         if( [authDreamSession.currentServices valueForKey:IDENTITY_SERVICE] )
         {
             IOStackService * identityService = [authDreamSession.currentServices valueForKey:IDENTITY_SERVICE];
             NSString * identityPublicWithoutID = [[identityService.urlPublic absoluteString] substringToIndex:[dicSettingsTests[ @"DREAM_IDENTITY_ROOT" ] length]];
             XCTAssertTrue( [identityPublicWithoutID isEqualToString:dicSettingsTests[ @"DREAM_IDENTITY_ROOT" ]]);
         }
         
         [expectation fulfill];
     }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}


@end
