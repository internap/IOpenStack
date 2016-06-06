//
//  getting_started.m
//  IOpenStack
//
//  Created by Bruno Morel on 2016-05-19.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import <XCTest/XCTest.h>


#import     "IOStackAuthV3.h"
#import     "IOStackImageV2.h"
#import     "IOStackComputeV2_1.h"


@interface getting_startedTests : XCTestCase

@end


@implementation getting_startedTests
{
    NSDictionary *          dicSettingsTests;
    IOStackAuthV3 *         authV3Session;
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
    
    __weak XCTestExpectation * exp = [self expectationWithDescription:@"First app guide - step 1"];
    
    authV3Session = [IOStackAuthV3 initWithIdentityURL:dicSettingsTests[ @"DEVSTACK_IDENTITY_ROOT" ]
                                              andLogin:dicSettingsTests[ @"DEVSTACK_ACCOUNT_LOGINDEMO" ]
                                           andPassword:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PASSWORDDEMO" ]
                                      forDefaultDomain:dicSettingsTests[ @"DEVSTACK_ACCOUNT_DOMAIN" ]
                                    andProjectOrTenant:dicSettingsTests[ @"DEVSTACK_ACCOUNT_PROJECTORTENANT" ]
                                                thenDo:^(NSString * strTokenIDResponse, NSDictionary * dicFullResponse)
    {
        XCTAssertNotNil(strTokenIDResponse);
        
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        // handle failure
    }];
}

- ( void ) tearDown
{
    [super tearDown];
}

- ( void ) testFirstApp1_1
{
    XCTAssertNotNil( authV3Session );
    XCTAssertNotNil( authV3Session.currentTokenID );
    XCTAssertNotNil( authV3Session.currentUserID );
}

- ( void ) testFirstApp1_2
{
    __weak XCTestExpectation * exp = [self expectationWithDescription:@"First app guide - step 2"];
    
    IOStackComputeV2_1 * computeV2_1Test = [IOStackComputeV2_1 initWithIdentity:authV3Session];
        
    NSLog( @"Checking for private network" );
    [computeV2_1Test listNetworksThenDo:^(NSDictionary * _Nullable dicNetworks, id  _Nullable idFullResponse)
     {
         XCTAssertNotNil( dicNetworks );
         XCTAssertTrue( [dicNetworks count] > 0 );
         NSArray * arrUIDNetwork = [IOStackComputeNetworkV2_1 findIDsForNetworks:dicNetworks
                                                                  withExactLabel:@"private" ];
         XCTAssertNotNil( arrUIDNetwork );
         XCTAssertTrue( [arrUIDNetwork count] > 0 );
         
         IOStackComputeNetworkV2_1 * firstNetwork = [dicNetworks objectForKey:[arrUIDNetwork objectAtIndex:0]];
         XCTAssertNotNil( firstNetwork );
         XCTAssertNotNil( firstNetwork.labelNetwork );
         XCTAssertTrue( [firstNetwork.labelNetwork isEqualToString:@"private"] );
         NSLog( @"First private network found : %@", firstNetwork );
         
         NSLog( @"Done! Congrats" );
         [exp fulfill];
     }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        // handle failure
    }];
}

- ( void ) testFirstApp1_3
{
    __weak XCTestExpectation * exp = [self expectationWithDescription:@"First app guide - step 3"];
    
    IOStackComputeV2_1 * computeV2_1Test = [IOStackComputeV2_1 initWithIdentity:authV3Session];
    
    NSLog( @"Listing flavors" );
    [computeV2_1Test listFlavorsThenDo:^( NSDictionary * dicFlavors )
     {
         XCTAssertNotNil( dicFlavors );
         XCTAssertTrue( [dicFlavors count] > 0 );
         for( NSString * currentFlavorID in dicFlavors )
             NSLog( @"- flavor : %@", dicFlavors[ currentFlavorID ] );
         
         NSString * uidFlavorNano = [IOStackComputeFlavorV2_1 findIDForFlavors:dicFlavors
                                                            withNameContaining:@"nano" ];
         XCTAssertNotNil( uidFlavorNano );
         
         IOStackImageV2 * imageV2 = [IOStackImageV2 initWithIdentity:authV3Session];
         
         NSLog( @"Listing images" );
         [imageV2 listImagesThenDo:^( NSDictionary * dicImages ){
             XCTAssertNotNil( dicImages );
             XCTAssertTrue( [dicImages count] > 0 );
             
             for( NSString * currentImageID in dicImages )
                 NSLog( @"- image : %@", dicImages[ currentImageID ] );
             
             NSLog( @"Done! Congrats" );
             [exp fulfill];
         }];
     }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        // handle failure
    }];
}

- ( void ) testFirstApp1_4
{
    __weak XCTestExpectation * exp = [self expectationWithDescription:@"First app guide - step 4"];
    
    IOStackImageV2 * imageV2 = [IOStackImageV2 initWithIdentity:authV3Session];
        
    [imageV2 listImagesThenDo:^( NSDictionary * dicImages ){
        XCTAssertNotNil( dicImages );
        XCTAssertTrue( [dicImages count] > 0 );
        
        NSLog( @"First Image : %@", [dicImages allValues][ 0 ] );
        
        NSLog( @"Done! Congrats" );
        [exp fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        // handle failure
    }];
}

- ( void ) testFirstApp1_5
{
    __weak XCTestExpectation * exp = [self expectationWithDescription:@"First app guide - step 5"];
    
    IOStackComputeV2_1 * computeV2_1Test = [IOStackComputeV2_1 initWithIdentity:authV3Session];
    
    [computeV2_1Test listFlavorsThenDo:^( NSDictionary * dicFlavors )
     {
         XCTAssertNotNil( dicFlavors );
         XCTAssertTrue( [dicFlavors count] > 0 );
         
         NSString * uidFlavorNano = [IOStackComputeFlavorV2_1 findIDForFlavors:dicFlavors
                                                            withNameContaining:@"nano" ];
         XCTAssertNotNil( uidFlavorNano );
         NSLog( @"First flavor : %@", dicFlavors[ uidFlavorNano ] );
         
         NSLog( @"Done! Congrats" );
         [exp fulfill];
     }];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        // handle failure
    }];
}

- ( void ) testFirstApp1_6
{
    __weak XCTestExpectation * exp = [self expectationWithDescription:@"First app guide - step 6"];
    
    
    IOStackComputeV2_1 * computeV2_1Test = [IOStackComputeV2_1 initWithIdentity:authV3Session];
    [computeV2_1Test listNetworksThenDo:^(NSDictionary * _Nullable dicNetworks, id  _Nullable idFullResponse)
     {
         NSArray * arrUIDNetwork = [IOStackComputeNetworkV2_1 findIDsForNetworks:dicNetworks
                                                                  withExactLabel:@"private" ];
         IOStackComputeNetworkV2_1 * firstNetwork = [dicNetworks objectForKey:[arrUIDNetwork objectAtIndex:0]];
         NSLog( @"First private network found : %@", firstNetwork );
         
         IOStackImageV2 * imageV2 = [IOStackImageV2 initWithIdentity:authV3Session];
         [imageV2 listImagesThenDo:^( NSDictionary * dicImages ){
             
             NSLog( @"First Image : %@", [dicImages allValues][ 0 ] );
             
             [computeV2_1Test listFlavorsThenDo:^( NSDictionary * dicFlavors )
              {
                  NSString * uidFlavorNano = [IOStackComputeFlavorV2_1 findIDForFlavors:dicFlavors
                                                                     withNameContaining:@"nano" ];
                  NSLog( @"First flavor : %@", dicFlavors[ uidFlavorNano ] );
                  
                  NSLog( @"Done! Congrats" );
                  [exp fulfill];
              }];
         }];
     }];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        // handle failure
    }];
}

- ( void ) testFirstApp1_7and8
{
    __weak XCTestExpectation * exp = [self expectationWithDescription:@"First app guide - step 7"];
    
    IOStackImageV2 * imageV2 = [IOStackImageV2 initWithIdentity:authV3Session];
    [imageV2 listImagesThenDo:^( NSDictionary * dicImages )
     {
         IOStackComputeV2_1 * computeV2_1Test = [IOStackComputeV2_1 initWithIdentity:authV3Session];
         [computeV2_1Test listFlavorsThenDo:^( NSDictionary * dicFlavors )
          {
              NSString * uidFlavorNano = [IOStackComputeFlavorV2_1 findIDForFlavors:dicFlavors
                                                                 withNameContaining:@"nano" ];
              IOStackImageObjectV2 * firstImage = [dicImages allValues][ 0 ];
              [computeV2_1Test createServerWithName:@"test Instance"
                                        andFlavorID:uidFlavorNano
                                         andImageID:firstImage.uniqueID
                                  waitUntilIsActive:NO
                                             thenDo:^(IOStackComputeServerV2_1 * serverCreated, NSDictionary * dicFullResponse)
               {
                   XCTAssertNotNil( serverCreated );
                   NSLog( @"Server created : %@", serverCreated );
                   
                   NSLog( @"List servers" );
                   [computeV2_1Test listServersThenDo:^(NSDictionary * dicServers, id idFullResponse) {
                       XCTAssertNotNil( dicServers );
                       XCTAssertNotNil( [dicServers objectForKey:serverCreated.uniqueID] );
                       for( NSString * currentServerID in dicServers )
                           NSLog( @" - server : %@", dicServers[ currentServerID ] );
                       
                       [computeV2_1Test deleteServerWithID:serverCreated.uniqueID
                                                    thenDo:^( bool isDeleted, id idFullResponse )
                        {
                            XCTAssertTrue( isDeleted );
                            
                            NSLog( @"Done! Congrats" );
                            [exp fulfill];
                        }];
                   }];
               }];
          }];
     }];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        // handle failure
    }];
}

- ( void ) testFirstApp1_9
{
    __weak XCTestExpectation * exp = [self expectationWithDescription:@"First app guide - step 9"];
    NSString * strKeypairNameRandom = [NSString stringWithFormat:@"%@-%@", @"testkeypair", [[NSUUID UUID] UUIDString]];
    NSString * currentTestFilePath = @__FILE__;
    NSString * currentKeyDataFilePath = [NSString stringWithFormat:@"%@/testkey-id_rsa.pub", [currentTestFilePath stringByDeletingLastPathComponent]];
    NSError * errRead;
    NSString * strPublicKeyData     = [NSString stringWithContentsOfFile:currentKeyDataFilePath
                                                                encoding:NSUTF8StringEncoding
                                                                   error:&errRead];
    XCTAssertNotNil( strPublicKeyData );
    
    IOStackComputeV2_1 * computeV2_1Test = [IOStackComputeV2_1 initWithIdentity:authV3Session];
    [computeV2_1Test createKeypairWithName:strKeypairNameRandom
                              andPublicKey:nil
                                    thenDo:^(IOStackComputeKeypairV2_1 * keyCreated, id idFullResponse)
     {
         XCTAssertNotNil( keyCreated );
         XCTAssertTrue( [strKeypairNameRandom isEqualToString:keyCreated.uniqueID] );
         NSLog( @"List servers" );
         [computeV2_1Test listKeypairsThenDo:^( NSDictionary * dicKeypairs, id idFulleResponse )
          {
              XCTAssertNotNil( dicKeypairs );
              XCTAssertNotNil( [dicKeypairs objectForKey:strKeypairNameRandom] );
              for( NSString * currentKeypairID in dicKeypairs )
                  NSLog( @" - server : %@", dicKeypairs[ currentKeypairID ] );
              
              [computeV2_1Test deleteKeypairWithName:strKeypairNameRandom
                                              thenDo:^( bool isDeleted )
               {
                   XCTAssertTrue( isDeleted );
                   
                   NSLog( @"Done! Congrats" );
                   [exp fulfill];
               }];
          }];
     }];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        // handle failure
    }];
}

- ( void ) testFirstApp1_10and11
{
    __weak XCTestExpectation * exp = [self expectationWithDescription:@"First app guide - step 10"];
    NSString * strTestSecName       = [NSString stringWithFormat:@"%@ - %@", @"test Security", [[NSUUID UUID] UUIDString]];
    NSString * strTestProto         = @"tcp";
    NSNumber * nTestPort            = @443;
    NSString * strTestCIDR          = @"0.0.0.0/0";
    
    IOStackComputeV2_1 * computeV2_1Test = [IOStackComputeV2_1 initWithIdentity:authV3Session];
    __weak IOStackComputeV2_1 * weakComputeForTest = computeV2_1Test;
        
    [computeV2_1Test createSecurityGroupWithName:strTestSecName
                                  andDescription:nil
                                          thenDo:^(IOStackComputeSecurityGroupV2_1 * secCreated, id idFullResponse)
     {
         XCTAssertNotNil( secCreated );
         XCTAssertTrue( [secCreated.name isEqualToString:strTestSecName ] );
         [computeV2_1Test addRuleToSecurityGroupWithID:secCreated.uniqueID
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
                   
                   NSLog( @"List security groups" );
                   [weakComputeForTest listSecurityGroupsThenDo:^(NSDictionary * dicSecurityGroups, id idFullResponse)
                    {
                        XCTAssertNotNil( dicSecurityGroups );
                        XCTAssertTrue( [dicSecurityGroups count ] > 0 );
                        XCTAssertNotNil( [dicSecurityGroups objectForKey:secCreated.uniqueID] );
                        
                        for( NSString * currentSecurityGroupID in dicSecurityGroups )
                            NSLog( @" - security group : %@", dicSecurityGroups[ currentSecurityGroupID ] );
                        
                        [weakComputeForTest deleteSecurityGroupWithID:secCreated.uniqueID
                                                               thenDo:^(bool isDeleted)
                         {
                             XCTAssertTrue( isDeleted );
                             
                             NSLog( @"Done! Congrats" );
                             [exp fulfill];
                         }];
                    }];
               }];
          }];
     }];

    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        // handle failure
    }];
}

- ( void ) testFirstApp1_12and13and14
{
    __weak XCTestExpectation * exp = [self expectationWithDescription:@"First app guide - step 12"];
    NSString * strTestSecName       = [NSString stringWithFormat:@"%@ - %@", @"test Security", [[NSUUID UUID] UUIDString]];
    NSString * strTestProto         = @"tcp";
    NSNumber * nTestPort            = @443;
    NSString * strTestCIDR          = @"0.0.0.0/0";
    NSString * strUserData          = @"#!/bin/bash \ncurl -L -s https://git.openstack.org/cgit/openstack/faafo/plain/contrib/install.sh | bash -s -- -i faafo -i messaging -r api -r worker -r demo";
    
    NSString * strKeypairNameRandom = [NSString stringWithFormat:@"%@-%@", @"testkeypair", [[NSUUID UUID] UUIDString]];
    NSString * currentTestFilePath = @__FILE__;
    NSString * currentKeyDataFilePath = [NSString stringWithFormat:@"%@/testkey-id_rsa.pub", [currentTestFilePath stringByDeletingLastPathComponent]];
    NSError * errRead;
    NSString * strPublicKeyData     = [NSString stringWithContentsOfFile:currentKeyDataFilePath
                                                                encoding:NSUTF8StringEncoding
                                                                   error:&errRead];
    XCTAssertNotNil( strPublicKeyData );
    
    IOStackComputeV2_1 * computeV2_1Test = [IOStackComputeV2_1 initWithIdentity:authV3Session];
    __weak IOStackComputeV2_1 * weakComputeForTest = computeV2_1Test;
    
    [computeV2_1Test createSecurityGroupWithName:strTestSecName
                                  andDescription:nil
                                          thenDo:^(IOStackComputeSecurityGroupV2_1 * secCreated, id idFullResponse)
     {
         XCTAssertNotNil( secCreated );
         XCTAssertTrue( [secCreated.name isEqualToString:strTestSecName ] );
         [computeV2_1Test addRuleToSecurityGroupWithID:secCreated.uniqueID
                                          withProtocol:strTestProto
                                              FromPort:nTestPort
                                                ToPort:nTestPort
                                               AndCIDR:strTestCIDR
                                                thenDo:^(IOStackComputeSecurityGroupRuleV2_1 * ruleCreated, id idFullResponse)
          {
              XCTAssertNotNil( ruleCreated );
              XCTAssertNotNil( ruleCreated.uniqueID );
              [weakComputeForTest createKeypairWithName:strKeypairNameRandom
                                           andPublicKey:nil
                                                 thenDo:^(IOStackComputeKeypairV2_1 * keyCreated, id idFullResponse)
               {
                   XCTAssertNotNil( keyCreated );
                   XCTAssertTrue( [strKeypairNameRandom isEqualToString:keyCreated.uniqueID] );
                   IOStackImageV2 * imageV2 = [IOStackImageV2 initWithIdentity:authV3Session];
                   [imageV2 listImagesThenDo:^( NSDictionary * dicImages )
                    {
                        [weakComputeForTest listFlavorsThenDo:^( NSDictionary * dicFlavors )
                         {
                             NSString * uidFlavorNano = [IOStackComputeFlavorV2_1 findIDForFlavors:dicFlavors
                                                                                withNameContaining:@"nano" ];
                             IOStackImageObjectV2 * firstImage = [dicImages allValues][ 0 ];
                             NSString * uidFirstImage = firstImage.uniqueID;
                             
                             [weakComputeForTest listNetworksThenDo:^(NSDictionary * _Nullable dicNetworks, id  _Nullable idFullResponse)
                              {
                                  XCTAssertNotNil( dicNetworks );
                                  XCTAssertTrue( [dicNetworks count] > 0 );
                                  NSArray * arrUIDNetwork = [IOStackComputeNetworkV2_1 findIDsForNetworks:dicNetworks
                                                                                           withExactLabel:@"private" ];
                                  XCTAssertNotNil( arrUIDNetwork );
                                  XCTAssertTrue( [arrUIDNetwork count] > 0 );
                                  
                                  IOStackComputeNetworkV2_1 * firstNetwork = [dicNetworks objectForKey:[arrUIDNetwork objectAtIndex:0]];
                                  
                                  [weakComputeForTest activateDebug:YES];
                                  [weakComputeForTest createServerWithName:@"test Instance for FirstAppGuide"
                                                               andFlavorID:uidFlavorNano
                                                                andImageID:uidFirstImage
                                                            andKeypairName:strKeypairNameRandom
                                                               andUserData:strUserData
                                                    andSecurityGroupsNames:@[ strTestSecName ]
                                                         onNetworksWithIDs:@[ firstNetwork.uniqueID ]
                                                         waitUntilIsActive:YES
                                                                    thenDo:^(IOStackComputeServerV2_1 * _Nullable serverCreated, NSDictionary * _Nullable dicFullResponse)
                                   {
                                       XCTAssertNotNil( serverCreated );
                                       NSLog( @"Server created : %@", serverCreated );
                                       
                                       XCTAssertNotNil( serverCreated.arrIPsPrivate );
                                       XCTAssertTrue( [serverCreated.arrIPsPrivate count] );
                                       NSLog( @" - with private IPs : " );
                                       for( id currentIP in serverCreated.arrIPsPrivate )
                                           NSLog( @" ---> %@", currentIP );
                                       
                                       //devstack doesn't assign public IPs by default
                                       /*XCTAssertNotNil( serverCreated.arrIPsPublic );
                                       XCTAssertTrue( [serverCreated.arrIPsPublic count] );
                                       NSLog( @" - with public IPs : " );
                                       for( id currentIP in serverCreated.arrIPsPublic )
                                           NSLog( @" ---> %@", currentIP );
                                       */
                                       
                                       [weakComputeForTest deleteServerWithID:serverCreated.uniqueID
                                                                    thenDo:^( bool isDeleted, id idFullResponse )
                                        {
                                            XCTAssertTrue( isDeleted );
                                            [weakComputeForTest deleteKeypairWithName:strKeypairNameRandom
                                                                               thenDo:^( bool isDeleted )
                                             {
                                                 XCTAssertTrue( isDeleted );
                                                 [weakComputeForTest deleteSecurityGroupRuleWithID:ruleCreated.uniqueID
                                                                                            thenDo:^(bool isDeleted)
                                                  {
                                                      [weakComputeForTest deleteSecurityGroupWithID:secCreated.uniqueID
                                                                                             thenDo:^(bool isDeleted)
                                                       {
                                                           XCTAssertTrue( isDeleted );
                                                           
                                                           NSLog( @"Done! Congrats" );
                                                           [exp fulfill];
                                                       }];
                                                  }];
                                             }];
                                        }];
                                   }];
                              }];
                         }];
                    }];
               }];
          }];
     }];
    
    [self waitForExpectationsWithTimeout:30.0 handler:^(NSError *error) {
        // handle failure
    }];
}


@end
