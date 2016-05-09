//
//  IOStackAuthV3Tests.m
//  IOpenStack
//
//  Created by Bruno Morel on 2015-12-18.
//  Copyright © 2015 Internap Inc. All rights reserved.
//

#import <XCTest/XCTest.h>

#import     "IOStackAuthV3.h"


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
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"V3 - token is valid"];
    
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

- ( void ) testCreateCheckAndDeleteToken
{
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"V3 - project list is valid"];
    
    [IOStackAuthV3 initWithIdentityURL:dicSettingsTests[ @"DEVSTACK_IDENTITY_ROOT" ]
                              andLogin:dicSettingsTests[ @"DEVSTACK_ACCOUNT_LOGINDEMO" ]
                           andPassword:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PASSWORDDEMO" ]
                      forDefaultDomain:dicSettingsTests[ @"DEVSTACK_ACCOUNT_DOMAIN" ]
                    andProjectOrTenant:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PROJECTORTENANT" ]
                                thenDo:^(NSString * _Nullable strTokenIDResponseDemo, NSDictionary * _Nullable dicFullResponse)
    {
        XCTAssertNotNil(strTokenIDResponseDemo);
        
        [authV3Session authenticateWithLogin:dicSettingsTests[ @"DEVSTACK_ACCOUNT_LOGINADMIN" ]
                                 andPassword:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PASSWORDADMIN" ]
                                   forDomain:dicSettingsTests[ @"DEVSTACK_ACCOUNT_DOMAIN" ]
                          andProjectOrTenant:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PROJECTORTENANT" ]
                                      thenDo:^(NSString * _Nullable strTokenIDResponseAdmin, NSDictionary * _Nullable dicFullResponse)
         {
             [authV3Session checkTokenWithID:strTokenIDResponseDemo
                                      thenDo:^(BOOL isValid)
             {
                  XCTAssertTrue( isValid );
                 
                 [authV3Session deleteTokenWithID:strTokenIDResponseDemo
                                           thenDo:^(BOOL isDeleted)
                 {
                     XCTAssertTrue( isDeleted );
                     [expectation fulfill];
                 }];
             }];
         }];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:^( NSError *error ) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testListDomain
{
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"V3 - domain list is valid"];
    
    [IOStackAuthV3 initWithIdentityURL:dicSettingsTests[ @"DEVSTACK_IDENTITY_ROOT" ]
                              andLogin:dicSettingsTests[ @"DEVSTACK_ACCOUNT_LOGINADMIN" ]
                           andPassword:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PASSWORDADMIN" ]
                      forDefaultDomain:dicSettingsTests[ @"DEVSTACK_ACCOUNT_DOMAIN" ]
                    andProjectOrTenant:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PROJECTORTENANT" ]
                                thenDo:^(NSString * _Nullable strTokenIDResponseDemo, NSDictionary * _Nullable dicFullResponse)
     {
         XCTAssertNotNil(strTokenIDResponseDemo);
         [authV3Session activateDebug:YES];
         /*Devstack default policy doesn't allow for domain editing
         [authV3Session createDomainWithName:@"test domain"
                              andDescription:nil
                                     enabled:YES
                                      thenDo:^(NSDictionary * _Nullable domainCreated, id  _Nullable dicFullResponse)
         {
             XCTAssertNotNil( domainCreated );
             XCTAssertNotNil( domainCreated[ @"id" ] );
             */
             [authV3Session listDomainsThenDo:^(NSArray * _Nullable arrDomains, id  _Nullable idFullResponse) {
                 XCTAssertNotNil( arrDomains );
                 XCTAssertTrue( [arrDomains count] > 0 );
                 
                 /*
                 [authV3Session deleteDomainWithID:domainCreated[ @"id" ]
                                            thenDo:^(bool isDeleted, id  _Nullable idFullResponse)
                 {
                     XCTAssertTrue( isDeleted );
                 */
                    [expectation fulfill];
                 /*
                  }];
                  */
             }];
         /*
         }];
          */
     }];
    
    [self waitForExpectationsWithTimeout:50.0 handler:^( NSError *error ) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testProjectsGiveAtLeastOneID
{
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"V3 - project list is valid"];
    
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
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"V3 - project is authorized"];
    
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
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"V3 - project got service"];
    
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
