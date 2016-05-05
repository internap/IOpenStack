//
//  IOStackComputeV2_1Tests.m
//  IOpenStack
//
//  Created by Bruno Morel on 2016-01-18.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import <XCTest/XCTest.h>

#import     "IOStackAuthV3.h"
#import     "IOStackImageV2.h"
#import     "IOStackComputeV2_1.h"


@interface IOStackComputeV2_1Tests : XCTestCase

@end


@implementation IOStackComputeV2_1Tests
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
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        // handle failure
    }];
}

- ( void ) tearDown
{
    [super tearDown];
}


- ( void ) testComputeNotASingleton
{
    XCTAssertNotNil(computeV2_1Test.currentTokenID);
    XCTAssertNotNil(computeV2_1Test.currentProjectOrTenantID);
    
    IOStackComputeV2_1 *    computeV2_1Test2 = [IOStackComputeV2_1 initWithComputeURL:dicSettingsTests[ @"DEVSTACK_COMPUTE_ROOT" ]
                                                                           andTokenID:authV3Session.currentTokenID
                                                                 forProjectOrTenantID:authV3Session.currentProjectOrTenantID];
    XCTAssertNotEqualObjects( computeV2_1Test, computeV2_1Test2 );
}

- ( void ) testComputeListFlavors
{
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"Compute - flavors exists"];
    
    [computeV2_1Test listFlavorsThenDo:^( NSDictionary * dicFlavors )
    {
        XCTAssertNotNil( dicFlavors );
        XCTAssertTrue( [dicFlavors count] > 0 );
        NSString * uidFlavorNano = [IOStackComputeFlavorV2_1 findIDForFlavors:dicFlavors
                                                           withNameContaining:@"nano" ];
        XCTAssertNotNil( uidFlavorNano );
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testComputeListNetworks
{
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"Compute - flavors exists"];
    
    [computeV2_1Test listNetworksThenDo:^(NSDictionary * _Nullable dicNetworks, id  _Nullable idFullResponse)
    {
        XCTAssertNotNil( dicNetworks );
        XCTAssertTrue( [dicNetworks count] > 0 );
        NSArray * arrUIDNetwork = [IOStackComputeNetworkV2_1 findIDsForNetworks:dicNetworks
                                                               withExactLabel:@"public" ];
        XCTAssertNotNil( arrUIDNetwork );
        XCTAssertTrue( [arrUIDNetwork count] > 0 );
        
        IOStackComputeNetworkV2_1 * firstNetwork = [dicNetworks objectForKey:[arrUIDNetwork objectAtIndex:0]];
        XCTAssertNotNil( firstNetwork );
        XCTAssertNotNil( firstNetwork.labelNetwork );
        XCTAssertTrue( [firstNetwork.labelNetwork isEqualToString:@"public"] );
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testComputeCreateServerListAndDeleteIt
{
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"Compute - create instance succeed"];
    
    [computeV2_1Test listFlavorsThenDo:^( NSDictionary * dicFlavors ) {
        XCTAssertTrue( dicFlavors );
        XCTAssertTrue( [dicFlavors count] > 0 );
        NSString * uidFlavorNano = [IOStackComputeFlavorV2_1 findIDForFlavors:dicFlavors
                                                           withNameContaining:@"nano" ];
        XCTAssertNotNil( uidFlavorNano );
        XCTAssertNotNil( [arrOSImages[ 0 ] valueForKey:@"uniqueID" ] );
        [computeV2_1Test createServerWithName:@"test Instance"
                                  andFlavorID:uidFlavorNano
                                   andImageID:[arrOSImages[ 0 ] valueForKey:@"uniqueID" ]
                            waitUntilIsActive:NO
                                       thenDo:^(IOStackComputeServerV2_1 * serverCreated, NSDictionary * dicFullResponse)
         {
             XCTAssertNotNil( serverCreated );
             [computeV2_1Test listServersThenDo:^(NSDictionary * dicServers, id idFullResponse) {
                 XCTAssertNotNil( dicServers );
                 XCTAssertNotNil( [dicServers objectForKey:serverCreated.uniqueID] );
                 [computeV2_1Test deleteServerWithID:serverCreated.uniqueID
                                              thenDo:^( bool isDeleted, id idFullResponse )
                  {
                      XCTAssertTrue( isDeleted );
                      
                      [expectation fulfill];
                  }];
             }];
         }];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testComputeCreateServerListActionsAndDeleteIt
{
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"Compute - create instance and list actions succeed"];
    
    [computeV2_1Test listFlavorsThenDo:^( NSDictionary * dicFlavors ) {
        XCTAssertTrue( dicFlavors );
        XCTAssertTrue( [dicFlavors count] > 0 );
        NSString * uidFlavorNano = [IOStackComputeFlavorV2_1 findIDForFlavors:dicFlavors
                                                           withNameContaining:@"nano" ];
        XCTAssertNotNil( uidFlavorNano );
        XCTAssertNotNil( [arrOSImages[ 0 ] valueForKey:@"uniqueID" ] );
        [computeV2_1Test createServerWithName:@"test Instance"
                                  andFlavorID:uidFlavorNano
                                   andImageID:[arrOSImages[ 0 ] valueForKey:@"uniqueID" ]
                            waitUntilIsActive:NO
                                       thenDo:^(IOStackComputeServerV2_1 * serverCreated, NSDictionary * dicFullResponse)
         {
             XCTAssertNotNil( serverCreated );
             [computeV2_1Test listActionsForServer:serverCreated.uniqueID
                                            thenDo:^(NSArray * arrServerActions, id  idFullResponse)
              {
                  XCTAssertNotNil( arrServerActions );
                  [computeV2_1Test deleteServerWithID:serverCreated.uniqueID
                                               thenDo:^( bool isDeleted, id  idFullResponse )
                   {
                       XCTAssertTrue( isDeleted );
                       
                       [expectation fulfill];
                   }];
              }];
         }];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testComputeCreateKeypairListAndDeleteIt
{
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"Compute - create keypair succeed"];
    NSString * strKeypairNameRandom = [NSString stringWithFormat:@"%@-%@", @"testkeypair", [[NSUUID UUID] UUIDString]];
    NSString * currentTestFilePath = @__FILE__;
    NSString * currentKeyDataFilePath = [NSString stringWithFormat:@"%@/testkey-id_rsa.pub", [currentTestFilePath stringByDeletingLastPathComponent]];
    NSError * errRead;
    NSString * strPublicKeyData     = [NSString stringWithContentsOfFile:currentKeyDataFilePath
                                                                encoding:NSUTF8StringEncoding
                                                                   error:&errRead];
    XCTAssertNotNil( strPublicKeyData );
    
    [computeV2_1Test createKeypairWithName:strKeypairNameRandom
                              andPublicKey:nil
                                    thenDo:^(IOStackComputeKeypairV2_1 * keyCreated, id idFullResponse)
     {
         XCTAssertNotNil( keyCreated );
         XCTAssertTrue( [strKeypairNameRandom isEqualToString:keyCreated.uniqueID] );
         [computeV2_1Test listKeypairsThenDo:^( NSDictionary * dicKeypairs, id idFulleResponse )
         {
             XCTAssertNotNil( dicKeypairs );
             XCTAssertNotNil( [dicKeypairs objectForKey:strKeypairNameRandom] );
             [computeV2_1Test deleteKeypairWithName:strKeypairNameRandom
                                             thenDo:^( bool isDeleted )
              {
                  XCTAssertTrue( isDeleted );
                  
                  [expectation fulfill];
              }];
         }];
     }];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testComputeCreateKeypairFromFileListAndDeleteIt
{
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"Compute - create keypair from file succeed"];
    NSString * strKeypairNameRandom = [NSString stringWithFormat:@"%@-%@", @"testkeypair", [[NSUUID UUID] UUIDString]];
    NSString * currentTestFilePath  = @__FILE__;
    NSString * currentKeyDataFilePath = [NSString stringWithFormat:@"%@/testkey-id_rsa.pub", [currentTestFilePath stringByDeletingLastPathComponent]];
    
    [computeV2_1Test createKeypairWithName:strKeypairNameRandom
                      andPublicKeyFilePath:currentKeyDataFilePath
                                    thenDo:^(IOStackComputeKeypairV2_1 * keyCreated, id idFullResponse)
     {
         XCTAssertNotNil( keyCreated );
         XCTAssertTrue( [strKeypairNameRandom isEqualToString:keyCreated.uniqueID] );
         [computeV2_1Test listKeypairsThenDo:^( NSDictionary * dicKeypairs, id idFulleResponse )
          {
              XCTAssertNotNil( dicKeypairs );
              XCTAssertNotNil( [dicKeypairs objectForKey:strKeypairNameRandom] );
              [computeV2_1Test deleteKeypairWithName:strKeypairNameRandom
                                              thenDo:^( bool isDeleted )
               {
                   XCTAssertTrue( isDeleted );
                   
                   [expectation fulfill];
               }];
          }];
     }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testComputeCreateSecurityGroupListAndDeleteIt
{
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"Compute - create security group succeed"];
    NSString * strTestSecName       = [NSString stringWithFormat:@"%@ - %@", @"test Security", [[NSUUID UUID] UUIDString]];
    
    [computeV2_1Test createSecurityGroupWithName:strTestSecName
                                  andDescription:nil
                                          thenDo:^(IOStackComputeSecurityGroupV2_1 * secCreated, id idFullResponse)
    {
        XCTAssertNotNil( secCreated );
        XCTAssertTrue( [secCreated.name isEqualToString:strTestSecName ] );
        [computeV2_1Test listSecurityGroupsThenDo:^(NSDictionary * dicSecurityGroups, id idFullResponse) {
            XCTAssertNotNil( dicSecurityGroups );
            XCTAssertTrue( [dicSecurityGroups count ] > 0 );
            XCTAssertNotNil( [dicSecurityGroups objectForKey:secCreated.uniqueID] );
            [computeV2_1Test deleteSecurityGroupWithID:secCreated.uniqueID
                                                thenDo:^(bool isDeleted)
            {
                XCTAssertTrue( isDeleted );
                
                [expectation fulfill];
            }];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testComputeCreateSecurityGroupAddRuleAndDeleteIt
{
    //to avoid some precompiler buggy warning...
    __weak IOStackComputeV2_1 * weakComputeForTest = computeV2_1Test;
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"Compute - create security group rule succeed"];
    NSString * strTestSecName       = [NSString stringWithFormat:@"%@ - %@", @"test Security", [[NSUUID UUID] UUIDString]];
    NSString * strTestProto         = @"tcp";
    NSNumber * nTestPort            = @443;
    NSString * strTestCIDR          = @"0.0.0.0/0";
    
    [weakComputeForTest createSecurityGroupWithName:strTestSecName
                                     andDescription:nil
                                             thenDo:^(IOStackComputeSecurityGroupV2_1 * secCreated, id idFullResponse)
     {
         XCTAssertNotNil( secCreated );
         XCTAssertTrue( [secCreated.name isEqualToString:strTestSecName ] );
         [weakComputeForTest addRuleToSecurityGroupWithID:secCreated.uniqueID
                                             withProtocol:strTestProto
                                                 FromPort:nTestPort
                                                   ToPort:nTestPort
                                                  AndCIDR:strTestCIDR
                                                   thenDo:^(IOStackComputeSecurityGroupRuleV2_1 * ruleCreated, id idFullResponse)
         {
             XCTAssertNotNil( ruleCreated );
             XCTAssertNotNil( ruleCreated.uniqueID );
             [weakComputeForTest deleteSecurityGroupRuleWithID:ruleCreated.uniqueID
                                                        thenDo:^(bool isDeleted)
             {
                 XCTAssertTrue( isDeleted );
                 [weakComputeForTest deleteSecurityGroupWithID:secCreated.uniqueID
                                                     thenDo:^(bool isDeleted)
                  {
                      XCTAssertTrue( isDeleted );
                      
                      [expectation fulfill];
                  }];
             }];
         }];
     }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testComputeCreateServerWithKeypairAndSecurityGroupAndDeleteIt
{
    __weak IOStackComputeV2_1 * weakComputeForTest = computeV2_1Test;
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"Compute - create security group rule succeed"];
    
    NSString * strKeypairNameRandom = [NSString stringWithFormat:@"%@-%@", @"testkeypair", [[NSUUID UUID] UUIDString]];
    NSString * currentTestFilePath = @__FILE__;
    NSString * currentKeyDataFilePath = [NSString stringWithFormat:@"%@/testkey-id_rsa.pub", [currentTestFilePath stringByDeletingLastPathComponent]];
    NSString * strTestSecName       = [NSString stringWithFormat:@"%@ - %@", @"test Security", [[NSUUID UUID] UUIDString]];
    NSString * strTestProto         = @"tcp";
    NSNumber * nTestPort            = @443;
    NSString * strTestCIDR          = @"0.0.0.0/0";
    
    [weakComputeForTest createSecurityGroupWithName:strTestSecName
                                     andDescription:nil
                                             thenDo:^(IOStackComputeSecurityGroupV2_1 * secCreated, id idFullResponse)
     {
         XCTAssertNotNil( secCreated );
         if( secCreated == nil )
             NSLog( @"no security group created" );
         
         XCTAssertTrue( [secCreated.name isEqualToString:strTestSecName ] );
         [weakComputeForTest addRuleToSecurityGroupWithID:secCreated.uniqueID
                                             withProtocol:strTestProto
                                                 FromPort:nTestPort
                                                   ToPort:nTestPort
                                                  AndCIDR:strTestCIDR
                                                   thenDo:^(IOStackComputeSecurityGroupRuleV2_1 * ruleCreated, id idFullResponse)
          {
              XCTAssertNotNil( ruleCreated );
              XCTAssertNotNil( ruleCreated.uniqueID );
              [weakComputeForTest createKeypairWithName:strKeypairNameRandom
                                   andPublicKeyFilePath:currentKeyDataFilePath
                                                 thenDo:^(IOStackComputeKeypairV2_1 * keyCreated, id idFullResponse)
              {
                  [weakComputeForTest listFlavorsThenDo:^( NSDictionary * dicFlavors )
                  {
                      XCTAssertTrue( dicFlavors );
                      XCTAssertTrue( [dicFlavors count] > 0 );
                      NSString * uidFlavorNano = [IOStackComputeFlavorV2_1 findIDForFlavors:dicFlavors
                                                                         withNameContaining:@"nano" ];
                      XCTAssertNotNil( uidFlavorNano );
                      XCTAssertNotNil( [arrOSImages[ 0 ] valueForKey:@"uniqueID" ] );
                      
                      NSString * uidImage = [arrOSImages[ 0 ] valueForKey:@"uniqueID" ];
                      NSArray * arrSecGroups = [NSArray arrayWithObjects:secCreated.name, @"default", nil];
                      
                      [weakComputeForTest createServerWithName:@"Test with keypair"
                                                   andFlavorID:uidFlavorNano
                                                    andImageID:uidImage
                                                andKeypairName:strKeypairNameRandom
                                                   andUserData:nil
                                        andSecurityGroupsNames:arrSecGroups
                                             onNetworksWithIDs:nil
                                             waitUntilIsActive:YES
                                                        thenDo:^(IOStackComputeServerV2_1 * serverCreated, NSDictionary * dicFullResponse)
                      {
                          XCTAssertNotNil( serverCreated );
                          
                          [computeV2_1Test deleteKeypairWithName:strKeypairNameRandom
                                                          thenDo:^(bool isDeleted)
                           {
                               XCTAssertTrue( isDeleted );
                               
                               [computeV2_1Test deleteServerWithID:serverCreated.uniqueID
                                                waitUntilIsDeleted:YES
                                                            thenDo:^(bool isDeleted, id  _Nullable idFullResponse)
                                {
                                    XCTAssertTrue(isDeleted);
                                    [computeV2_1Test deleteSecurityGroupWithID:secCreated.uniqueID
                                                                        thenDo:^(bool isDeleted)
                                     {
                                         XCTAssertTrue( isDeleted );
                                         
                                         [expectation fulfill];
                                     }];
                                }];
                           }];
                      }];
                   }];
                  
              }];
          }];
     }];
    
    [self waitForExpectationsWithTimeout:6000.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testComputeCreateServerKeypairSecurityGroupUserDataAndDeleteIt
{
    __weak IOStackComputeV2_1 * weakComputeForTest = computeV2_1Test;
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"Compute - create security group rule succeed"];
    
    NSString * strKeypairNameRandom = [NSString stringWithFormat:@"%@-%@", @"testkeypair", [[NSUUID UUID] UUIDString]];
    NSString * currentTestFilePath  = @__FILE__;
    NSString * currentKeyDataFilePath = [NSString stringWithFormat:@"%@/testkey-id_rsa.pub", [currentTestFilePath stringByDeletingLastPathComponent]];
    NSString * strTestSecName       = [NSString stringWithFormat:@"%@ - %@", @"test Security", [[NSUUID UUID] UUIDString]];
    NSString * strTestProto         = @"tcp";
    NSNumber * nTestPort            = @443;
    NSString * strTestCIDR          = @"0.0.0.0/0";
    
    [computeV2_1Test createSecurityGroupWithName:strTestSecName
                                  andDescription:nil
                                          thenDo:^(IOStackComputeSecurityGroupV2_1 * secCreated, id idFullResponse)
     {
         XCTAssertNotNil( secCreated );
         XCTAssertTrue( [secCreated.name isEqualToString:strTestSecName ] );
         [weakComputeForTest addRuleToSecurityGroupWithID:secCreated.uniqueID
                                             withProtocol:strTestProto
                                                 FromPort:nTestPort
                                                   ToPort:nTestPort
                                                  AndCIDR:strTestCIDR
                                                   thenDo:^(IOStackComputeSecurityGroupRuleV2_1 * ruleCreated, id idFullResponse)
          {
              XCTAssertNotNil( ruleCreated );
              XCTAssertNotNil( ruleCreated.uniqueID );
              [computeV2_1Test createKeypairWithName:strKeypairNameRandom
                                andPublicKeyFilePath:currentKeyDataFilePath
                                              thenDo:^(IOStackComputeKeypairV2_1 * keyCreated, id idFullResponse)
               {
                   [computeV2_1Test listFlavorsThenDo:^( NSDictionary * dicFlavors )
                    {
                        XCTAssertTrue( dicFlavors );
                        XCTAssertTrue( [dicFlavors count] > 0 );
                        NSString * uidFlavorNano = [IOStackComputeFlavorV2_1 findIDForFlavors:dicFlavors
                                                                           withNameContaining:@"nano" ];
                        XCTAssertNotNil( uidFlavorNano );
                        XCTAssertNotNil( [arrOSImages[ 0 ] valueForKey:@"uniqueID" ] );
                        
                        NSString * uidImage = [arrOSImages[ 0 ] valueForKey:@"uniqueID" ];
                        NSArray * arrSecGroups = [NSArray arrayWithObjects:secCreated.name, @"default", nil];
                        
                        [computeV2_1Test createServerWithName:@"Test with userdata"
                                                  andFlavorID:uidFlavorNano
                                                   andImageID:uidImage
                                               andKeypairName:strKeypairNameRandom
                                                  andUserData:@"#!/usr/bin/env bash \necho world"
                                       andSecurityGroupsNames:arrSecGroups
                                            onNetworksWithIDs:nil
                                            waitUntilIsActive:YES
                                                       thenDo:^(IOStackComputeServerV2_1 * serverCreated, NSDictionary * dicFullResponse)
                         {
                             XCTAssertNotNil( serverCreated );
                             
                             [computeV2_1Test deleteKeypairWithName:strKeypairNameRandom
                                                             thenDo:^(bool isDeleted)
                              {
                                  XCTAssertTrue( isDeleted );
                                  
                                  [computeV2_1Test deleteServerWithID:serverCreated.uniqueID
                                                   waitUntilIsDeleted:YES
                                                               thenDo:^(bool isDeleted, id  _Nullable idFullResponse)
                                   {
                                       XCTAssertTrue(isDeleted);
                                       [computeV2_1Test deleteSecurityGroupWithID:secCreated.uniqueID
                                                                           thenDo:^(bool isDeleted)
                                        {
                                            XCTAssertTrue( isDeleted );
                                            
                                            [expectation fulfill];
                                        }];
                                   }];
                              }];
                         }];
                    }];
                   
               }];
          }];
     }];
    
    [self waitForExpectationsWithTimeout:60.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testComputeCreateServerListIPsAndDeleteIt
{
    __weak IOStackComputeV2_1 * weakComputeForTest = computeV2_1Test;
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"Compute - create security group rule succeed"];
    
    NSString * strKeypairNameRandom = [NSString stringWithFormat:@"%@-%@", @"testkeypair", [[NSUUID UUID] UUIDString]];
    NSString * currentTestFilePath  = @__FILE__;
    NSString * currentKeyDataFilePath = [NSString stringWithFormat:@"%@/testkey-id_rsa.pub", [currentTestFilePath stringByDeletingLastPathComponent]];
    NSString * strTestSecName       = [NSString stringWithFormat:@"%@ - %@", @"test Security", [[NSUUID UUID] UUIDString]];
    NSString * strTestProto         = @"tcp";
    NSNumber * nTestPort            = @443;
    NSString * strTestCIDR          = @"0.0.0.0/0";
    
    [computeV2_1Test createSecurityGroupWithName:strTestSecName
                                  andDescription:nil
                                          thenDo:^(IOStackComputeSecurityGroupV2_1 * secCreated, id idFullResponse)
     {
         XCTAssertNotNil( secCreated );
         XCTAssertTrue( [secCreated.name isEqualToString:strTestSecName ] );
         [weakComputeForTest addRuleToSecurityGroupWithID:secCreated.uniqueID
                                             withProtocol:strTestProto
                                                 FromPort:nTestPort
                                                   ToPort:nTestPort
                                                  AndCIDR:strTestCIDR
                                                   thenDo:^(IOStackComputeSecurityGroupRuleV2_1 * ruleCreated, id idFullResponse)
          {
              XCTAssertNotNil( ruleCreated );
              XCTAssertNotNil( ruleCreated.uniqueID );
              [computeV2_1Test createKeypairWithName:strKeypairNameRandom
                                andPublicKeyFilePath:currentKeyDataFilePath
                                              thenDo:^(IOStackComputeKeypairV2_1 * keyCreated, id idFullResponse)
               {
                   [computeV2_1Test listFlavorsThenDo:^( NSDictionary * dicFlavors )
                    {
                        XCTAssertTrue( dicFlavors );
                        XCTAssertTrue( [dicFlavors count] > 0 );
                        NSString * uidFlavorNano = [IOStackComputeFlavorV2_1 findIDForFlavors:dicFlavors
                                                                           withNameContaining:@"nano" ];
                        XCTAssertNotNil( uidFlavorNano );
                        XCTAssertNotNil( [arrOSImages[ 0 ] valueForKey:@"uniqueID" ] );
                        
                        NSString * uidImage = [arrOSImages[ 0 ] valueForKey:@"uniqueID" ];
                        NSArray * arrSecGroups = [NSArray arrayWithObjects:secCreated.name, @"default", nil];
                        
                        [computeV2_1Test createServerWithName:@"Test and list IP"
                                                  andFlavorID:uidFlavorNano
                                                   andImageID:uidImage
                                               andKeypairName:strKeypairNameRandom
                                                  andUserData:@"#!/usr/bin/env bash \necho world"
                                       andSecurityGroupsNames:arrSecGroups
                                            onNetworksWithIDs:nil
                                            waitUntilIsActive:YES
                                                       thenDo:^(IOStackComputeServerV2_1 * serverCreated, NSDictionary * dicFullResponse)
                         {
                             XCTAssertNotNil( serverCreated );
                             
                             [computeV2_1Test listIPsForServerWithID:serverCreated.uniqueID
                                                              thenDo:^(NSArray * arrPrivateIPs, NSArray * arrPublicIPs, id idFullResponse)
                              {
                                  XCTAssertTrue( ( arrPrivateIPs != nil ) && ( [arrPrivateIPs count] > 0 ) || ( arrPublicIPs != nil ) && ( [arrPublicIPs count] > 0 ) );
                                  
                                  [computeV2_1Test deleteKeypairWithName:strKeypairNameRandom
                                                                  thenDo:^(bool isDeleted)
                                   {
                                       XCTAssertTrue( isDeleted );
                                       
                                       [computeV2_1Test deleteServerWithID:serverCreated.uniqueID
                                                        waitUntilIsDeleted:YES
                                                                    thenDo:^(bool isDeleted, id  _Nullable idFullResponse)
                                        {
                                            XCTAssertTrue(isDeleted);
                                            [computeV2_1Test deleteSecurityGroupWithID:secCreated.uniqueID
                                                                                thenDo:^(bool isDeleted)
                                             {
                                                 XCTAssertTrue( isDeleted );
                                                 
                                                 [expectation fulfill];
                                             }];
                                        }];
                                   }];
                              }];
                         }];
                    }];
               }];
          }];
     }];
    
    [self waitForExpectationsWithTimeout:40.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

//Internap doesn't allow to allocate IP from Pool
- ( void ) testComputeAllocatedIPPoolStartsEmpty
{
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"Compute - list IPs from pool"];
    
    [computeV2_1Test listIPFromPoolWithStatus:nil
                            excludingFixedIPs:NO
                                       thenDo:^(NSDictionary * _Nullable dicIPsFromPool, id  _Nullable idFullResponse)
    {
        XCTAssertNotNil( dicIPsFromPool );
        XCTAssertTrue( [dicIPsFromPool count] == 0 );
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}


- ( void ) testComputeAllocateFloatingIPFromPoolThenRemove
{
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"Compute - Allocate IPs from pool"];
    
    [computeV2_1Test createIPAllocationFromPool:nil
                                         thenDo:^(IOStackComputeIPAllocationV2_1 * _Nullable fipCreated, id  _Nullable idFullResponse)
    {
        XCTAssertNotNil( fipCreated );
        [computeV2_1Test listIPFromPoolWithStatus:nil
                                excludingFixedIPs:NO
                                           thenDo:^(NSDictionary * _Nullable dicIPsFromPool, id  _Nullable idFullResponse)
         {
             XCTAssertNotNil( dicIPsFromPool );
             XCTAssertNotNil( [dicIPsFromPool valueForKey:fipCreated.uniqueID] );
             XCTAssertTrue( [[[dicIPsFromPool valueForKey:fipCreated.uniqueID] valueForKey:@"ipAddressFloating"] isEqualToString:fipCreated.ipAddress] );
             
             [computeV2_1Test deleteIPAllocationWithID:fipCreated.uniqueID
                                                thenDo:^(bool isDeleted)
              {
                  XCTAssertTrue( isDeleted );
                  [computeV2_1Test listIPFromPoolWithStatus:nil
                                          excludingFixedIPs:NO
                                                     thenDo:^(NSDictionary * _Nullable dicIPsFromPool, id  _Nullable idFullResponse)
                   {
                       XCTAssertNotNil( dicIPsFromPool );
                       XCTAssertTrue( [dicIPsFromPool count] == 0 );
                       
                       [expectation fulfill];
                   }];
              }];

         }];
        
            }];
    
    [self waitForExpectationsWithTimeout:5000.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}

- ( void ) testComputeAddFloatingIPToServerThenDeleteAll
{
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"Compute - create instance and list actions succeed"];
    __weak IOStackComputeV2_1 * weakComputeForTest = computeV2_1Test;
    
    [computeV2_1Test listFlavorsThenDo:^( NSDictionary * dicFlavors ) {
        XCTAssertTrue( dicFlavors );
        XCTAssertTrue( [dicFlavors count] > 0 );
        NSString * uidFlavorNano = [IOStackComputeFlavorV2_1 findIDForFlavors:dicFlavors
                                                           withNameContaining:@"nano" ];
        XCTAssertNotNil( uidFlavorNano );
        XCTAssertNotNil( [arrOSImages[ 0 ] valueForKey:@"uniqueID" ] );
        [computeV2_1Test createServerWithName:@"test Instance"
                                  andFlavorID:uidFlavorNano
                                   andImageID:[arrOSImages[ 0 ] valueForKey:@"uniqueID" ]
                            waitUntilIsActive:YES
                                       thenDo:^(IOStackComputeServerV2_1 * serverCreated, NSDictionary * dicFullResponse)
         {
             XCTAssertNotNil( serverCreated );
             [computeV2_1Test createIPAllocationFromPool:nil
                                                  thenDo:^(IOStackComputeIPAllocationV2_1 * _Nullable fipCreated, id  _Nullable idFullResponse)
              {
                  XCTAssertNotNil( fipCreated );
                  XCTAssertNotNil( fipCreated.ipAddress );
                  
                  [weakComputeForTest addIPToServerWithID:serverCreated.uniqueID
                                   usingFloatingIPAddress:fipCreated.ipAddress
                                                   thenDo:^(BOOL isAssociated, id  _Nullable idFullResponse)
                  {
                      XCTAssertTrue( isAssociated );
                      
                      [computeV2_1Test deleteServerWithID:serverCreated.uniqueID
                                                   thenDo:^( bool isDeleted, id  idFullResponse )
                       {
                           XCTAssertTrue( isDeleted );
                           [computeV2_1Test deleteIPAllocationWithID:fipCreated.uniqueID
                                                              thenDo:^(bool isDeleted)
                            {
                                XCTAssertTrue( isDeleted );
                                
                                [expectation fulfill];
                            }];
                       }];
                  }];
              }];
         }];
    }];
    
    [self waitForExpectationsWithTimeout:30.0 handler:^(NSError *error) {
        if( error ) NSLog(@"Timeout Error: %@", error);
    }];
}


@end
