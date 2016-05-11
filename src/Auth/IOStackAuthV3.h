//
//  IOStackAuthV3.h
//  IOpenStack
//
//  Created by Bruno Morel on 2015-12-07.
//  Copyright © 2015 Internap Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#define IOStackAuthEndpointInterfaceTypePublic       @"public"
#define IOStackAuthEndpointInterfaceTypeInternal     @"internal"
#define IOStackAuthEndpointInterfaceTypeAdmin        @"admin"


#import "IOStackAuth.h"


@interface IOStackAuthV3 : IOStackService<IOStackIdentityInfos>

// IOStackIdentity protocol
@property (readonly, strong, nonatomic) NSString * _Nullable                currentTokenID;
@property (readonly, strong, nonatomic) NSDictionary * _Nullable            currentServices;
@property (readonly, strong, nonatomic) NSString * _Nullable                currentDomain;
@property (readonly, strong, nonatomic) NSString * _Nullable                currentProjectOrTenant;
@property (readonly, strong, nonatomic) NSString * _Nullable                currentProjectOrTenantID;

// local property accessors
@property (readonly, strong, nonatomic) NSDictionary * _Nullable        currentTokenObject;
@property (readonly, strong, nonatomic) NSArray * _Nullable             currentProjectsList;
@property (readonly, strong, nonatomic) NSString * _Nullable            currentDomainID;


+ ( nonnull instancetype ) initWithIdentityURL:( nonnull NSString * ) strIdentityRoot;
+ ( nonnull instancetype ) initWithIdentityURL:( nonnull NSString * ) strIdentityRoot
                                      andLogin:( nonnull NSString * ) strLogin
                                   andPassword:( nullable NSString * ) strPassword
                              forDefaultDomain:( nullable NSString * ) strDomain
                            andProjectOrTenant:( nullable NSString * ) strProjectOrTenant
                                        thenDo:( nullable void ( ^ ) ( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse ) ) doAfterInit;
+ ( nonnull instancetype ) initWithIdentityURL:( nonnull NSString * ) strIdentityRoot
                                    andTokenID:( nonnull NSString * ) strToken
                              forDefaultDomain:( nullable NSString * ) strDomain
                            andProjectOrTenant:( nullable NSString * ) strProjectOrTenant
                                        thenDo:( nullable void ( ^ ) ( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse ) ) doAfterInit;

- ( nonnull instancetype ) initWithIdentityURL:( nonnull NSString * ) strIdentityRoot;
- ( nonnull instancetype ) initWithIdentityURL:( nonnull NSString * ) strIdentityRoot
                                      andLogin:( nonnull NSString * ) strLogin
                                   andPassword:( nullable NSString * ) strPassword
                              forDefaultDomain:( nullable NSString * ) strDomain
                            andProjectOrTenant:( nullable NSString * ) strProjectOrTenant
                                        thenDo:( nullable void ( ^ ) ( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse ) ) doAfterInit;
- ( nonnull instancetype ) initWithIdentityURL:( nonnull NSString * ) strIdentityRoot
                                    andTokenID:( nonnull NSString * ) strToken
                              forDefaultDomain:( nullable NSString * ) strDomain
                            andProjectOrTenant:( nullable NSString * ) strProjectOrTenant
                                        thenDo:( nullable void ( ^ ) ( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse ) ) doAfterInit;
- ( void ) authenticateWithUrlParams:( nullable NSDictionary * ) dicUrlParams
                              thenDo:( nullable void ( ^ ) ( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse ) ) doAfterInit;
- ( void ) authenticateWithLogin:( nonnull NSString * ) strLogin
                     andPassword:( nullable NSString * ) strPassword
                       forDomain:( nullable NSString * ) strDomain
              andProjectOrTenant:( nullable NSString * ) strTenant
                          thenDo:( nullable void ( ^ ) ( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse ) ) doAfterInit;
- ( void ) authenticateWithTokenID:( nonnull NSString * ) strTokenID
                         forDomain:( nullable NSString * ) strDomain
                andProjectOrTenant:( nullable NSString * ) strTenant
                            thenDo:( nullable void ( ^ ) ( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse ) ) doAfterInit;
- ( void ) authenticateForDomain:( nullable NSString * ) strDomain
              andProjectOrTenant:( nullable NSString * ) strProjectOrTenant
                          thenDo:( nullable void ( ^ ) ( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse ) ) doAfterInit;
- ( void ) authenticateThenDo:( nullable void ( ^ ) ( NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse ) ) doAfterInit;
- ( void ) getdetailsForTokenWithID:( nonnull NSString * ) strTokenIDToCheck
                             thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable strTokenDetails ) ) doAfterGetDetails;
- ( void ) checkTokenWithID:( nonnull NSString * ) strTokenIDToCheck
                     thenDo:( nullable void ( ^ ) ( BOOL isValid ) ) doAfterCheck;
- ( void ) deleteTokenWithID:( nonnull NSString * ) strTokenIDToCheck
                      thenDo:( nullable void ( ^ ) ( BOOL isDeleted ) ) doAfterCheck;
- ( void ) listCredentialsThenDo:( nullable void ( ^ ) ( NSArray * _Nullable arrCredential, id _Nullable idFullResponse ) ) doAfterList;
- ( void ) createCredentialWithBlob:( nonnull NSString * ) jsonBlob
                       andProjectID:( nonnull NSString * ) uidProject
                            andType:( nonnull NSString * ) strType
                          andUserID:( nonnull NSString * ) uidUser
                             thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable credentialCreated, id _Nullable dicFullResponse ) ) doAfterCreate;
- ( void ) getdetailForCredentialWithID:( nonnull NSString * ) uidCredential
                                 thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicDomain ) ) doAfterGetDetail;
- ( void ) updateCredentialWithID:( nonnull NSString * ) uidCredential
                          newBlob:( nullable NSString * ) jsonBlob
                     newProjectID:( nullable NSString * ) uidProject
                          newType:( nullable NSString * ) strType
                        newUserID:( nullable NSString * ) uidUser
                           thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable credentialUpdated, id _Nullable dicFullResponse ) ) doAfterUpdate;
- ( void ) deleteCredentialWithID:( nonnull NSString * ) uidCredential
                           thenDo:( nullable void ( ^ ) ( bool isDeleted, id _Nullable idFullResponse ) ) doAfterDelete;
- ( void ) listDomainsThenDo:( nullable void ( ^ ) ( NSArray * _Nullable arrDomains, id _Nullable idFullResponse ) ) doAfterList;
- ( void ) createDomainWithName:( nonnull NSString * ) nameDomain
                 andDescription:( nullable NSString * ) strDescription
                      isEnabled:( BOOL ) isEnabled
                         thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable domainCreated, id _Nullable dicFullResponse ) ) doAfterCreate;
- ( void ) getdetailForDomainWithID:( nonnull NSString * ) uidDomain
                             thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicDomain ) ) doAfterGetDetail;
- ( void ) updateDomainWithID:( nonnull NSString * ) uidDomain
                      newName:( nullable NSString * ) nameDomain
               newDescription:( nullable NSString * ) strDescription
                    isEnabled:( BOOL ) isEnabled
                       thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable domainUpdated, id _Nullable dicFullResponse ) ) doAfterUpdate;
- ( void ) deleteDomainWithID:( nonnull NSString * ) uidDomain
                       thenDo:( nullable void ( ^ ) ( bool isDeleted, id _Nullable idFullResponse ) ) doAfterDelete;
- ( void ) listGroupsThenDo:( nullable void ( ^ ) ( NSArray * _Nullable arrGroups, id _Nullable idFullResponse ) ) doAfterList;
- ( void ) createGroupWithName:( nonnull NSString * ) nameGroup
                andDescription:( nullable NSString * ) strDescription
              andOwnerDomainID:( nullable NSString * ) uidOwnerDomain
                        thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable groupCreated, id _Nullable dicFullResponse ) ) doAfterCreate;
- ( void ) getdetailForGroupWithID:( nonnull NSString * ) uidGroup
                            thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicGroup ) ) doAfterGetDetail;
- ( void ) updateGroupWithID:( nonnull NSString * ) uidGroup
                     newName:( nullable NSString * ) nameGroup
              newDescription:( nullable NSString * ) strDescription
            newOwnerDomainID:( nullable NSString * ) uidOwnerDomain
                      thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable groupUpdated, id _Nullable dicFullResponse ) ) doAfterUpdate;
- ( void ) deleteGroupWithID:( nonnull NSString * ) uidGroup
                      thenDo:( nullable void ( ^ ) ( BOOL isDeleted, id _Nullable idFullResponse ) ) doAfterDelete;
- ( void ) listUsersInGroupWithID:( nonnull NSString * ) uidGroup
                           thenDo:( nullable void ( ^ ) ( NSArray * _Nullable arrUsers, id _Nullable idFullResponse ) ) doAfterList;
- ( void ) addUserWithID:( nonnull NSString * ) uidUser
           toGroupWithID:( nonnull NSString * ) uidGroup
                  thenDo:( nullable void ( ^ ) ( BOOL isAdded, id _Nullable dicFullResponse ) ) doAfterAdd;
- ( void ) checkUserWithID:( nonnull NSString * ) uidUser
      belongsToGroupWithID:( nonnull NSString * ) uidGroup
                    thenDo:( nullable void ( ^ ) ( BOOL isInGroup ) ) doAfterCheck;
- ( void ) deleteUserWithID:( nonnull NSString * ) uidUser
            fromGroupWithID:( nonnull NSString * ) uidGroup
                     thenDo:( nullable void ( ^ ) ( BOOL isDeleted, id _Nullable idFullResponse ) ) doAfterDelete;
- ( void ) listPoliciesThenDo:( nullable void ( ^ ) ( NSArray * _Nullable arrPolicies, id _Nullable idFullResponse ) ) doAfterList;
- ( void ) createPolicyWithBlob:( nonnull NSString * ) strBlob
                        andType:( nonnull NSString * ) mimeType
                   andProjectID:( nullable NSString * ) uidProject
                 andOwnerUserID:( nullable NSString * ) uidOwner
                         thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable policyCreated, id  _Nullable dicFullResponse ) ) doAfterCreate;
- ( void ) getdetailForPolicyWithID:( nonnull NSString * ) uidPolicy
                             thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicPolicy ) ) doAfterGetDetail;
- ( void ) updatePolicyWithID:( nonnull NSString * ) uidPolicy
                      newBlob:( nullable NSString * ) strBlob
                      newType:( nullable NSString * ) mimeType
                 newProjectID:( nullable NSString * ) uidProject
               newOwnerUserID:( nullable NSString * ) uidOwner
                       thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable policyUpdated, id _Nullable dicFullResponse ) ) doAfterUpdate;
- ( void ) deletePolicyWithID:( nonnull NSString * ) uidPolicy
                       thenDo:( nullable void ( ^ ) ( bool isDeleted, id _Nullable idFullResponse ) ) doAfterDelete;
- ( void ) listProjectsOrTenantsWithTokenID:( nonnull NSString * ) strTokenID
                                  forDomain:( nullable NSString * ) strDomainName
                                       From:( nullable NSString * ) strStartingFromID
                                         To:( nullable NSNumber * ) nLimit
                                     thenDo:( nullable void ( ^ ) ( NSArray * _Nullable arrProjectResponse ) ) doAfterList;
- ( void ) listProjectsOrTenantsWithLogin:( nonnull NSString * ) strLogin
                              andPassword:( nullable NSString * ) strPassword
                                forDomain:( nullable NSString * ) strDomainName
                       andProjectOrTenant:( nullable NSString * ) strProjectOrTenant
                                     From:( nullable NSString * ) strStartingFromID
                                       To:( nullable NSNumber * ) nLimit
                                   thenDo:( nullable void ( ^ ) ( NSArray * _Nullable arrProjectResponse ) ) doAfterList;
- ( void ) listProjectsOrTenantsFrom:( nullable NSString * ) strStartingFromID
                                  To:( nullable NSNumber * ) nLimit
                              thenDo:( nullable void ( ^ ) ( NSArray * _Nullable arrProjectResponse ) ) doAfterList;
- ( void ) listProjectsOrTenantsThenDo:( nullable void ( ^ ) ( NSArray * _Nullable arrProjectResponse ) ) doAfterList;
- ( void ) createProjectOrTenantWithName:( nonnull NSString * ) nameProjectOrTenant
                          andDescription:( nullable NSString * ) strDescription
                             andDomainID:( nullable NSString * ) uidDomain
              andParentProjectOrTenantID:( nullable NSString * ) uidParentProjectOrTenant
                                isDomain:( BOOL ) isAlsoDomain
                               isEnabled:( BOOL ) isEnabled
                                  thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable createdProjectOrTenant, id _Nullable dicFullResponse ) ) doAfterCreate;
- ( void ) getdetailForProjectOrTenantWithID:( nonnull NSString * ) uidProjectOrTenant
                                      thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicProjectOrTenant ) ) doAfterGetDetail;
- ( void ) updateProjectOrTenantWithID:( nonnull NSString * ) uidProjectOrTenant
                               newName:( nullable NSString * ) nameProjectOrTenant
                        newDescription:( nullable NSString * ) strDescription
                           newDomainID:( nullable NSString * ) uidDomain
                              isDomain:( BOOL ) isAlsoDomain
                             isEnabled:( BOOL ) isEnabled
                                thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable updatedProjectOrTenant, id _Nullable dicFullResponse ) ) doAfterUpdate;
- ( void ) deleteProjectOrTenantWithID:( nonnull NSString * ) uidProjectOrTenant
                                thenDo:( nullable void ( ^ ) ( bool isDeleted, id _Nullable idFullResponse ) ) doAfterDelete;
- ( void ) listRegionsThenDo:( nullable void ( ^ ) ( NSArray * _Nullable arrRegions, id _Nullable idFullResponse ) ) doAfterList;
- ( void ) createRegionWithDescription:( nullable NSString * ) strDescription
                           andForcedID:( nullable NSString * ) strRegionForcedID
                     andParentRegionID:( nullable NSString * ) uidParentRegion
                                thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable createdRegion, id _Nullable dicFullResponse ) ) doAfterCreate;
- ( void ) getdetailForRegionWithID:( nonnull NSString * ) uidRegion
                             thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicRegion ) ) doAfterGetDetail;
- ( void ) updateRegionWithID:( nonnull NSString * ) uidRegion
               newDescription:( nullable NSString * ) strDescription
            newParentRegionID:( nullable NSString * ) uidParentRegion
                       thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable updatedRegion, id _Nullable dicFullResponse ) ) doAfterUpdate;
- ( void ) deleteRegionWithID:( nonnull NSString * ) uidRegion
                       thenDo:( nullable void ( ^ ) ( bool isDeleted, id _Nullable idFullResponse ) ) doAfterDelete;
- ( void ) listServicesThenDo:( nullable void ( ^ ) ( NSArray * _Nullable arrServices, id _Nullable idFullResponse ) ) doAfterList;
- ( void ) createServiceWithType:( nonnull NSString * ) strServiceType
                         andName:( nonnull NSString * ) nameService
                  andDescription:( nullable NSString * ) strDescription
              andForcedServiceID:( nullable NSString * ) uidForced
                       isEnabled:( BOOL ) isEnabled
                          thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable createdService, id _Nullable dicFullResponse ) ) doAfterCreate;
- ( void ) getdetailForServiceWithID:( nonnull NSString * ) uidService
                              thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicService ) ) doAfterGetDetail;
- ( void ) updateServiceWithID:( nonnull NSString * ) uidService
                       newType:( nullable NSString * ) strServiceType
                       newName:( nullable NSString * ) nameService
                newDescription:( nullable NSString * ) strDescription
                     isEnabled:( BOOL ) isEnabled
                        thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable updatedService, id _Nullable dicFullResponse ) ) doAfterUpdate;
- ( void ) deleteServiceWithID:( nonnull NSString * ) uidService
                        thenDo:( nullable void ( ^ ) ( bool isDeleted, id _Nullable idFullResponse ) ) doAfterDelete;
- ( void ) listEndpointsWithInterface:( nullable NSString * ) strInterfaceToFilterBy
                         andServiceID:( nullable NSString * ) uidServiceToFilterBy
                               thenDo:( nullable void ( ^ ) ( NSArray * _Nullable arrEndpoints, id _Nullable idFullResponse ) ) doAfterList;
- ( void ) createEndpointWithName:( nonnull NSString * ) nameEndpoint
                     andInterface:( nonnull NSString * ) strInterface
                           andURL:( nonnull NSString * ) urlEndpoint
                     andServiceID:( nonnull NSString * ) uidService
                      andRegionID:( nullable NSString * ) uidRegion
                        isEnabled:( BOOL ) isEnabled
                           thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable createdEndpoint, id _Nullable dicFullResponse ) ) doAfterCreate;
- ( void ) getdetailForEndpointWithID:( nonnull NSString * ) uidEndpoint
                               thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicService ) ) doAfterGetDetail;
- ( void ) updateEndpointWithID:( nonnull NSString * ) uidEndpoint
                        newName:( nullable NSString * ) nameEndpoint
                   newInterface:( nullable NSString * ) strInterface
                         newURL:( nullable NSString * ) urlEndpoint
                   newServiceID:( nullable NSString * ) uidService
                    newRegionID:( nullable NSString * ) uidRegion
                      isEnabled:( BOOL ) isEnabled
                         thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable updatedEndpoint, id _Nullable dicFullResponse ) ) doAfterUpdate;
- ( void ) deleteEndpointWithID:( nonnull NSString * ) uidEndpoint
                         thenDo:( nullable void ( ^ ) ( bool isDeleted, id _Nullable idFullResponse ) ) doAfterDelete;
- ( void ) listUsersThenDo:( nullable void ( ^ ) ( NSArray * _Nullable arrUsers, id _Nullable idFullResponse ) ) doAfterList;
- ( void ) createUserWithName:( nonnull NSString * ) nameUser
                  andPassword:( nonnull NSString * ) strPassword
               andDescription:( nullable NSString * ) strDescription
                     andEmail:( nullable NSString * ) strEmail
          andDefaultProjectID:( nullable NSString * ) uidDefaultProjectOrTenant
                  andDomainID:( nullable NSString * ) uidDomain
                    isEnabled:( BOOL ) isEnabled
                       thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable createdUser, id _Nullable dicFullResponse ) ) doAfterCreate;
- ( void ) getdetailForUserWithID:( nonnull NSString * ) uidUser
                           thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicUser ) ) doAfterGetDetail;
- ( void ) updateUserWithID:( nonnull NSString * ) uidUser
                    newName:( nullable NSString * ) nameUser
                newPassword:( nullable NSString * ) strPassword
             newDescription:( nullable NSString * ) strDescription
                   newEmail:( nullable NSString * ) strEmail
        newDefaultProjectID:( nullable NSString * ) uidDefaultProjectOrTenant
                newDomainID:( nullable NSString * ) uidDomain
                  isEnabled:( BOOL ) isEnabled
                     thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable updatedUser, id _Nullable dicFullResponse ) ) doAfterUpdate;
- ( void ) deleteUserWithID:( nonnull NSString * ) uidUser
                     thenDo:( nullable void ( ^ ) ( bool isDeleted, id _Nullable idFullResponse ) ) doAfterDelete;
- ( void ) changeUserWithID:( nonnull NSString * ) uidUser
             andOldPassword:( nonnull NSString * ) strOldPassword
            withNewPassword:( nonnull NSString * ) strNewPassword
                     thenDo:( nullable void ( ^ ) ( BOOL isAdded, id _Nullable dicFullResponse ) ) doAfterChange;
- ( void ) listGroupsForUserWithID:( nonnull NSString * ) uidUser
                            thenDo:( nullable void ( ^ ) ( NSArray * _Nullable arrGroups, id _Nullable idFullResponse ) ) doAfterList;
- ( void ) listProjectsForUserWithID:( nonnull NSString * ) uidUser
                              thenDo:( nullable void ( ^ ) ( NSArray * _Nullable arrProjects, id _Nullable idFullResponse ) ) doAfterList;


@end
