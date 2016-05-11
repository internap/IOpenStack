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
                                  thenDo:^(NSString * strTokenIDResponse, NSDictionary * dicFullResponse)
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
                                thenDo:^(NSString * strTokenIDResponseDemo, NSDictionary * dicFullResponse)
    {
        XCTAssertNotNil(strTokenIDResponseDemo);
        
        [authV3Session authenticateWithLogin:dicSettingsTests[ @"DEVSTACK_ACCOUNT_LOGINADMIN" ]
                                 andPassword:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PASSWORDADMIN" ]
                                   forDomain:dicSettingsTests[ @"DEVSTACK_ACCOUNT_DOMAIN" ]
                          andProjectOrTenant:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PROJECTORTENANT" ]
                                      thenDo:^(NSString * strTokenIDResponseAdmin, NSDictionary * dicFullResponse)
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

- ( void ) testCreateListAndDeleteCredentials
{
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"V3 - credential list is valid"];
    
    [authV3Session authenticateWithLogin:dicSettingsTests[ @"DEVSTACK_ACCOUNT_LOGINADMIN" ]
                             andPassword:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PASSWORDADMIN" ]
                               forDomain:dicSettingsTests[ @"DEVSTACK_ACCOUNT_DOMAIN" ]
                      andProjectOrTenant:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PROJECTORTENANT" ]
                                  thenDo:^(NSString * strTokenIDResponseAdmin, NSDictionary * dicFullResponse)
     {
         XCTAssertNotNil(strTokenIDResponseAdmin);
         [authV3Session createCredentialWithBlob:@"{\"access\":\"181920\",\"secrete\":\"secretKey\"}"
                                    andProjectID:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PROJECTORTENANT" ]
                                         andType:@"ec2"
                                       andUserID:@"12345678"
                                          thenDo:^(NSDictionary * credentialCreated, id dicFullResponse)
          {
              XCTAssertNotNil( credentialCreated );
              XCTAssertNotNil( credentialCreated[ @"id" ] );
              [authV3Session listCredentialsThenDo:^(NSArray * arrCredential, id idFullResponse) {
                  XCTAssertNotNil( arrCredential );
                  XCTAssertTrue( [arrCredential count] > 0 );
                  
                  [authV3Session updateCredentialWithID:credentialCreated[ @"id" ]
                                                newBlob:nil
                                           newProjectID:nil
                                                newType:nil
                                              newUserID:@"1234ABCD"
                                                 thenDo:^(NSDictionary * credentialUpdated, id dicFullResponse)
                   {
                       XCTAssertTrue([credentialUpdated[ @"user_id" ] isEqualToString:@"1234ABCD" ]);
                       
                       [authV3Session deleteCredentialWithID:credentialCreated[ @"id" ]
                                                      thenDo:^(bool isDeleted, id idFullResponse)
                        {
                            XCTAssertTrue( isDeleted );
                            [expectation fulfill];
                        }];
                   }];
              }];
          }];
     }];
    
    [self waitForExpectationsWithTimeout:30.0 handler:^( NSError *error ) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testCreateListAndDeleteDomain
{
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"V3 - domain list is valid"];
    
    [authV3Session authenticateWithLogin:dicSettingsTests[ @"DEVSTACK_ACCOUNT_LOGINADMIN" ]
                             andPassword:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PASSWORDADMIN" ]
                               forDomain:dicSettingsTests[ @"DEVSTACK_ACCOUNT_DOMAIN" ]
                      andProjectOrTenant:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PROJECTORTENANT" ]
                                  thenDo:^(NSString * strTokenIDResponseAdmin, NSDictionary * dicFullResponse)
     {
         XCTAssertNotNil(strTokenIDResponseAdmin);
         [authV3Session createDomainWithName:@"test domain for testing IOpenStack"
                              andDescription:nil
                                   isEnabled:YES
                                      thenDo:^(NSDictionary * domainCreated, id dicFullResponse)
         {
             XCTAssertNotNil( domainCreated );
             XCTAssertNotNil( domainCreated[ @"id" ] );
             [authV3Session listDomainsThenDo:^(NSArray * arrDomains, id idFullResponse) {
                 XCTAssertNotNil( arrDomains );
                 XCTAssertTrue( [arrDomains count] > 0 );
                 
                 [authV3Session updateDomainWithID:domainCreated[ @"id" ]
                                           newName:@"new test domain for testing IOpenStack"
                                    newDescription:nil
                                         isEnabled:NO
                                            thenDo:^(NSDictionary * domainUpdated, id dicFullResponse)
                 {
                     XCTAssertTrue([domainUpdated[ @"name" ] isEqualToString:@"new test domain for testing IOpenStack" ]);
                     
                     [authV3Session deleteDomainWithID:domainCreated[ @"id" ]
                                                thenDo:^(bool isDeleted, id idFullResponse)
                      {
                          XCTAssertTrue( isDeleted );
                          [expectation fulfill];
                      }];
                 }];
             }];
         }];
     }];
    
    [self waitForExpectationsWithTimeout:30.0 handler:^( NSError *error ) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testCreateListAddUserAndDeleteGroup
{
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"V3 - groups list is valid"];
    
    [authV3Session authenticateWithLogin:dicSettingsTests[ @"DEVSTACK_ACCOUNT_LOGINADMIN" ]
                             andPassword:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PASSWORDADMIN" ]
                               forDomain:dicSettingsTests[ @"DEVSTACK_ACCOUNT_DOMAIN" ]
                      andProjectOrTenant:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PROJECTORTENANT" ]
                                  thenDo:^(NSString * strTokenIDResponseAdmin, NSDictionary * dicFullResponse)
     {
         __weak IOStackAuthV3 * wkAuth = authV3Session;
         XCTAssertNotNil(strTokenIDResponseAdmin);
         [authV3Session createGroupWithName:@"test group"
                             andDescription:@"test description for group"
                           andOwnerDomainID:nil
                                     thenDo:^(NSDictionary * groupCreated, id dicFullResponse)
         {
             XCTAssertNotNil( groupCreated );
             XCTAssertNotNil( groupCreated[ @"id" ] );
             
             NSString * uidCurrentUser = authV3Session.currentTokenObject[@"user"][@"id"];
             XCTAssertNotNil( uidCurrentUser );
             [authV3Session listGroupsThenDo:^(NSArray * arrGroups, id idFullResponse)
             {
                 XCTAssertNotNil( arrGroups );
                 XCTAssertTrue( [arrGroups count] > 0 );
                 [wkAuth addUserWithID:uidCurrentUser
                         toGroupWithID:groupCreated[ @"id" ]
                                thenDo:^(BOOL isAdded, id dicFullResponse)
                 {
                     XCTAssertTrue(isAdded);
                     [authV3Session checkUserWithID:uidCurrentUser
                               belongsToGroupWithID:groupCreated[ @"id" ]
                                             thenDo:^(BOOL isInGroup)
                     {
                         XCTAssertTrue(isInGroup);
                         [authV3Session deleteUserWithID:uidCurrentUser
                                         fromGroupWithID:groupCreated[@"id"]
                                                  thenDo:^(BOOL isDeleted, id idFullResponse)
                         {
                             XCTAssertTrue(isDeleted);
                             [wkAuth deleteGroupWithID:groupCreated[@"id"]
                                                thenDo:^(BOOL isDeleted, id idFullResponse)
                             {
                                 XCTAssertTrue(isDeleted);
                                 [expectation fulfill];
                             }];
                         }];
                     }];
                 }];
             }];
         }];
     }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^( NSError *error ) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testCreateListAndDeletePolicy
{
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"V3 - domain list is valid"];
    
    [authV3Session authenticateWithLogin:dicSettingsTests[ @"DEVSTACK_ACCOUNT_LOGINADMIN" ]
                             andPassword:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PASSWORDADMIN" ]
                               forDomain:dicSettingsTests[ @"DEVSTACK_ACCOUNT_DOMAIN" ]
                      andProjectOrTenant:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PROJECTORTENANT" ]
                                  thenDo:^(NSString * strTokenIDResponseAdmin, NSDictionary * dicFullResponse)
     {
         XCTAssertNotNil(strTokenIDResponseAdmin);
         [authV3Session createPolicyWithBlob:@"{'foobar_user': 'role:compute-user'}"
                                     andType:@"application/json"
                                andProjectID:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PROJECTORTENANT" ]
                              andOwnerUserID:nil
                                      thenDo:^(NSDictionary * policyCreated, id dicFullResponse)
          {
              XCTAssertNotNil( policyCreated );
              XCTAssertNotNil( policyCreated[ @"id" ] );
              [authV3Session listPoliciesThenDo:^(NSArray * arrPolicies, id idFullResponse)
              {
                  XCTAssertNotNil( arrPolicies );
                  XCTAssertTrue( [arrPolicies count] > 0 );
                  
                  NSString * uidCurrentUser = authV3Session.currentTokenObject[@"user"][@"id"];
                  XCTAssertNotNil( uidCurrentUser );
                  [authV3Session updatePolicyWithID:policyCreated[ @"id" ]
                                            newBlob:nil
                                            newType:nil
                                       newProjectID:nil
                                     newOwnerUserID:uidCurrentUser
                                             thenDo:^(NSDictionary * policyUpdated, id dicFullResponse)
                   {
                       XCTAssertTrue([policyUpdated[ @"user_id" ] isEqualToString:uidCurrentUser ]);
                       XCTAssertTrue([policyUpdated[ @"blob" ] isEqualToString:@"{'foobar_user': 'role:compute-user'}" ]);
                       
                       [authV3Session deletePolicyWithID:policyCreated[@"id"]
                                                  thenDo:^(bool isDeleted, id idFullResponse)
                        {
                            XCTAssertTrue( isDeleted );
                            [expectation fulfill];
                        }];
                   }];
              }];
          }];
     }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^( NSError *error ) {
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
                                  thenDo:^(NSString * strTokenIDResponse, NSDictionary * dicFullResponse)
    {
        [authV3Session listProjectsOrTenantsFrom:nil
                                              To:nil
                                          thenDo:^( NSArray * arrProjectResponse )
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
                                  thenDo:^(NSString * strTokenIDResponse, NSDictionary * dicFullResponse)
    {
        [authV3Session listProjectsOrTenantsFrom:nil
                                              To:nil
                                          thenDo:^( NSArray * arrProjectResponse )
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
                                  thenDo:^( NSString * strTokenIDResponse, NSDictionary * dicFullResponse )
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

- ( void ) testCreateListAndDeleteProject
{
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"V3 - domain list is valid"];
    
    [authV3Session authenticateWithLogin:dicSettingsTests[ @"DEVSTACK_ACCOUNT_LOGINADMIN" ]
                             andPassword:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PASSWORDADMIN" ]
                               forDomain:dicSettingsTests[ @"DEVSTACK_ACCOUNT_DOMAIN" ]
                      andProjectOrTenant:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PROJECTORTENANT" ]
                                  thenDo:^(NSString * strTokenIDResponseAdmin, NSDictionary * dicFullResponse)
     {
         XCTAssertNotNil(strTokenIDResponseAdmin);
         [authV3Session createProjectOrTenantWithName:@"Test project for IOStack"
                                       andDescription:@"test description"
                                          andDomainID:nil
                           andParentProjectOrTenantID:nil
                                             isDomain:NO
                                            isEnabled:YES
                                               thenDo:^(NSDictionary * createdProjectOrTenant, id dicFullResponse)
          {
              XCTAssertNotNil( createdProjectOrTenant );
              XCTAssertNotNil( createdProjectOrTenant[ @"id" ] );
              [authV3Session listProjectsOrTenantsThenDo:^(NSArray * arrProjectResponse)
               {
                   XCTAssertNotNil( arrProjectResponse );
                   XCTAssertTrue( [arrProjectResponse count] > 0 );
                   
                   [authV3Session updateProjectOrTenantWithID:createdProjectOrTenant[@"id"]
                                                      newName:nil
                                               newDescription:nil
                                                  newDomainID:nil
                                                     isDomain:NO
                                                    isEnabled:NO
                                                       thenDo:^(NSDictionary * updatedProjectOrTenant, id dicFullResponse)
                    {
                        XCTAssertTrue([updatedProjectOrTenant[ @"name" ] isEqualToString:@"Test project for IOStack" ]);
                        XCTAssertTrue(![updatedProjectOrTenant[ @"is_enabled" ] boolValue]);
                        
                        [authV3Session deleteProjectOrTenantWithID:createdProjectOrTenant[@"id"]
                                                            thenDo:^(bool isDeleted, id idFullResponse)
                         {
                             XCTAssertTrue( isDeleted );
                             [expectation fulfill];
                         }];
                    }];
               }];
          }];
     }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^( NSError *error ) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testCreateListAndDeleteRegion
{
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"V3 - domain list is valid"];
    
    [authV3Session authenticateWithLogin:dicSettingsTests[ @"DEVSTACK_ACCOUNT_LOGINADMIN" ]
                             andPassword:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PASSWORDADMIN" ]
                               forDomain:dicSettingsTests[ @"DEVSTACK_ACCOUNT_DOMAIN" ]
                      andProjectOrTenant:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PROJECTORTENANT" ]
                                  thenDo:^(NSString * strTokenIDResponseAdmin, NSDictionary * dicFullResponse)
     {
         XCTAssertNotNil(strTokenIDResponseAdmin);
         [authV3Session createRegionWithDescription:@"test description for region"
                                        andForcedID:@"testRegionID"
                                  andParentRegionID:nil
                                             thenDo:^(NSDictionary * createdRegion, id dicFullResponse)
          {
              XCTAssertNotNil( createdRegion );
              XCTAssertTrue( [createdRegion[ @"id" ] isEqualToString:@"testRegionID"] );
              [authV3Session listRegionsThenDo:^(NSArray * arrRegions, id idFullResponse)
               {
                   XCTAssertNotNil( arrRegions );
                   XCTAssertTrue( [arrRegions count] > 0 );
                   
                   [authV3Session updateRegionWithID:createdRegion[@"id"]
                                      newDescription:nil
                                   newParentRegionID:@"RegionOne"
                                              thenDo:^(NSDictionary * updatedRegion, id dicFullResponse)
                    {
                        XCTAssertTrue([updatedRegion[ @"parent_region_id" ] isEqualToString:@"RegionOne" ]);
                        XCTAssertTrue([updatedRegion[ @"description" ] isEqualToString:@"test description for region"]);
                        
                        [authV3Session deleteRegionWithID:createdRegion[@"id"]
                                                   thenDo:^(bool isDeleted, id idFullResponse)
                         {
                             XCTAssertTrue( isDeleted );
                             [expectation fulfill];
                         }];
                    }];
               }];
          }];
     }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^( NSError *error ) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testCreateListChangePasswordAndDeleteUser
{
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"V3 - domain list is valid"];
    
    [authV3Session authenticateWithLogin:dicSettingsTests[ @"DEVSTACK_ACCOUNT_LOGINADMIN" ]
                             andPassword:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PASSWORDADMIN" ]
                               forDomain:dicSettingsTests[ @"DEVSTACK_ACCOUNT_DOMAIN" ]
                      andProjectOrTenant:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PROJECTORTENANT" ]
                                  thenDo:^(NSString * strTokenIDResponseAdmin, NSDictionary * dicFullResponse)
     {
         XCTAssertNotNil(strTokenIDResponseAdmin);
         [authV3Session createUserWithName:@"testIOStack"
                               andPassword:@"testIOStack"
                            andDescription:nil
                                  andEmail:nil
                       andDefaultProjectID:nil
                               andDomainID:nil
                                 isEnabled:YES
                                    thenDo:^(NSDictionary * createdUser, id dicFullResponse)
          {
              XCTAssertNotNil( createdUser );
              XCTAssertTrue( [createdUser[ @"name" ] isEqualToString:@"testIOStack"] );
              [authV3Session listUsersThenDo:^(NSArray * arrUsers, id idFullResponse)
               {
                   XCTAssertNotNil( arrUsers );
                   XCTAssertTrue( [arrUsers count] > 0 );
                   
                   [authV3Session updateUserWithID:createdUser[@"id"]
                                           newName:nil
                                       newPassword:nil
                                    newDescription:@"test description"
                                          newEmail:@"test@test.com"
                               newDefaultProjectID:nil
                                       newDomainID:nil
                                         isEnabled:NO
                                            thenDo:^(NSDictionary * updatedUser, id dicFullResponse)
                    {
                        XCTAssertTrue([updatedUser[ @"name" ] isEqualToString:@"testIOStack" ]);
                        XCTAssertTrue([updatedUser[ @"email" ] isEqualToString:@"test@test.com"]);
                        
                        [authV3Session deleteRegionWithID:createdUser[@"id"]
                                                   thenDo:^(bool isDeleted, id idFullResponse)
                         {
                             XCTAssertTrue( isDeleted );
                             [expectation fulfill];
                         }];
                    }];
               }];
          }];
     }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^( NSError *error ) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testCreateListAndDeleteService
{
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"V3 - domain list is valid"];
    
    [authV3Session authenticateWithLogin:dicSettingsTests[ @"DEVSTACK_ACCOUNT_LOGINADMIN" ]
                             andPassword:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PASSWORDADMIN" ]
                               forDomain:dicSettingsTests[ @"DEVSTACK_ACCOUNT_DOMAIN" ]
                      andProjectOrTenant:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PROJECTORTENANT" ]
                                  thenDo:^(NSString * strTokenIDResponseAdmin, NSDictionary * dicFullResponse)
     {
         XCTAssertNotNil(strTokenIDResponseAdmin);
         [authV3Session createServiceWithType:EC2_SERVICE
                                      andName:@"Test EC2 service"
                               andDescription:nil
                           andForcedServiceID:nil
                                    isEnabled:NO
                                       thenDo:^(NSDictionary * createdService, id dicFullResponse)
          {
              XCTAssertNotNil( createdService );
              XCTAssertTrue( [createdService[ @"type" ] isEqualToString:EC2_SERVICE] );
              [authV3Session listServicesThenDo:^(NSArray * arrServices, id idFullResponse)
               {
                   XCTAssertNotNil( arrServices );
                   XCTAssertTrue( [arrServices count] > 0 );
                   XCTAssertNotNil( createdService );
                   XCTAssertTrue( [createdService[ @"type" ] isEqualToString:EC2_SERVICE] );
                   
                   [authV3Session listServicesThenDo:^(NSArray * arrServices, id idFullResponse)
                    {
                        XCTAssertNotNil( arrServices );
                        XCTAssertTrue( [arrServices count] > 0 );
                        
                        [authV3Session updateServiceWithID:createdService[@"id"]
                                                   newType:nil
                                                   newName:nil
                                            newDescription:@"Test description"
                                                 isEnabled:NO
                                                    thenDo:^(NSDictionary * updatedService, id dicFullResponse)
                         {
                             XCTAssertTrue([updatedService[ @"description" ] isEqualToString:@"Test description" ]);
                             XCTAssertTrue(![updatedService[ @"enabled" ] boolValue]);
                             
                             [authV3Session deleteServiceWithID:createdService[@"id"]
                                                         thenDo:^(bool isDeleted, id idFullResponse)
                              {
                                  XCTAssertTrue( isDeleted );
                                  [expectation fulfill];
                              }];
                         }];
                    }];
               }];
          }];
     }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^( NSError *error ) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testCreateListAndDeleteEndpoint
{
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"V3 - domain list is valid"];
    
    [authV3Session authenticateWithLogin:dicSettingsTests[ @"DEVSTACK_ACCOUNT_LOGINADMIN" ]
                             andPassword:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PASSWORDADMIN" ]
                               forDomain:dicSettingsTests[ @"DEVSTACK_ACCOUNT_DOMAIN" ]
                      andProjectOrTenant:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PROJECTORTENANT" ]
                                  thenDo:^(NSString * strTokenIDResponseAdmin, NSDictionary * dicFullResponse)
     {
         XCTAssertNotNil(strTokenIDResponseAdmin);
         [authV3Session listServicesThenDo:^(NSArray * arrServices, id idFullResponse)
         {
             XCTAssertNotNil( arrServices );
             XCTAssertTrue( [arrServices count] > 0 );
             
             XCTAssertNotNil(arrServices[ 0 ][@"id"]);
             [authV3Session createEndpointWithName:@"Test endpoint for IOStack"
                                            andInterface:IOStackAuthEndpointInterfaceTypeInternal
                                                  andURL:@"http://localhost"
                                            andServiceID:arrServices[ 0 ][@"id"]
                                             andRegionID:nil
                                               isEnabled:YES
                                                  thenDo:^(NSDictionary * createdEndpoint, id dicFullResponse)
              {
                  XCTAssertNotNil( createdEndpoint );
                  XCTAssertTrue( [createdEndpoint[ @"interface" ] isEqualToString:IOStackAuthEndpointInterfaceTypeInternal] );
                  [authV3Session listEndpointsWithInterface:nil
                                               andServiceID:nil
                                                     thenDo:^(NSArray * arrEndpoints, id  idFullResponse)
                   {
                       XCTAssertNotNil( arrEndpoints );
                       XCTAssertTrue( [arrEndpoints count] > 0 );
                       
                       [authV3Session updateEndpointWithID:createdEndpoint[@"id"]
                                                   newName:nil
                                              newInterface:nil
                                                    newURL:@"https://localhost"
                                              newServiceID:nil
                                               newRegionID:nil
                                                 isEnabled:NO
                                                    thenDo:^(NSDictionary * updatedEndpoint, id  dicFullResponse)
                        {
                            XCTAssertNotNil( updatedEndpoint );
                            XCTAssertTrue( [updatedEndpoint[ @"url" ] isEqualToString:@"https://localhost"] );
                            
                            [authV3Session deleteEndpointWithID:createdEndpoint[@"id"]
                                                         thenDo:^(bool isDeleted, id  idFullResponse)
                             {
                                 XCTAssertTrue( isDeleted );
                                 [expectation fulfill];
                             }];
                        }];
                   }];
              }];
          }];
     }];

    [self waitForExpectationsWithTimeout:5.0 handler:^( NSError *error ) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}




@end
