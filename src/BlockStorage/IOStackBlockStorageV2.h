//
//  IOStackBlockStorageV2.h
//  IOpenStack
//
//  Created by Bruno Morel on 2016-03-29.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "IOStackAuth.h"
#import "IOStackBStorageVolumeV2.h"
#import "IOStackBStorageBackupV2.h"
#import "IOStackBStorageSnapshotV2.h"
#import "IOStackBStorageVolumeTransferV2.h"


@interface IOStackBlockStorageV2 : IOStackService


// local property accessors
@property (strong, nonatomic) NSString * _Nullable                      currentProjectOrTenantID;
@property (strong, nonatomic) NSString * _Nonnull                       currentTokenID;


+ ( nonnull instancetype ) initWithBlockStorageURL:( nonnull NSString * ) strBlockStorageRoot
                                        andTokenID:( nonnull NSString * ) strTokenID
                              forProjectOrTenantID:( nonnull NSString * ) strProjectOrTenantID;
+ ( nonnull instancetype ) initWithIdentity:( nonnull id<IOStackIdentityInfos> ) idUserIdentity;

- ( nonnull instancetype ) initWithBlockStorageURL:( nonnull NSString * ) strBlockStorageRoot
                                        andTokenID:( nonnull NSString * ) strTokenID
                              forProjectOrTenantID:( nonnull NSString * ) strProjectOrTenantID;
- ( nonnull instancetype ) initWithIdentity:( nonnull id<IOStackIdentityInfos> ) idUserIdentity;
- ( void ) listLimitsThenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicLimits ) ) doAfterList;
- ( void ) listVolumesThenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicVolumes, id _Nullable idFullResponse ) ) doAfterList;
- ( void ) createVolumeWithSize:( nonnull NSNumber * ) nSizeInGiB
                        andName:( nullable NSString * ) strVolumeName
                  andVolumetype:( nullable NSString * ) typeVolume
                 andDescription:( nullable NSString * ) strDescription
                    andMetadata:( nullable NSDictionary * ) dicMetadata
              andSchedulerHints:( nullable NSDictionary * ) dicSchedulerHints
          andConsistencyGroupID:( nullable NSString * ) uidConsistencyGroup
               allowMultiAttach:( BOOL ) bMultiAttachable
             inAvailabilityZone:( nullable NSString * ) nameAvailabilityZone
             fromSourceVolumeID:( nullable NSString * ) uidSourceVolume
               orSnapshotWithID:( nullable NSString * ) uidSnapshot
             orBootableImageRef:( nullable NSString * ) uidImageRef
                orSourceReplica:( nullable NSString * ) uidSourceReplica
           waitUntilIsAvailable:( BOOL ) bWaitAvailable
                         thenDo:( nullable void ( ^ ) ( IOStackBStorageVolumeV2 * _Nullable volumeCreated, id _Nullable dicFullResponse ) ) doAfterCreate;
- ( void ) createVolumeWithSize:( nonnull NSNumber * ) nSizeInGiB
           waitUntilIsAvailable:( BOOL ) bWaitAvailable
                         thenDo:( nullable void ( ^ ) ( IOStackBStorageVolumeV2 * _Nullable volumeCreated, id _Nullable dicFullResponse ) ) doAfterCreate;
- ( void ) getdetailForVolumeWithID:( nonnull NSString * ) uidVolume
                             thenDo:( nullable void ( ^ ) ( IOStackBStorageVolumeV2 * _Nullable volDetails ) ) doAfterGetDetail;
- ( void ) updateVolumeWithID:( nonnull NSString * ) uidVolume
                      newName:( nullable NSString * ) nameUser
               newDescription:( nullable NSString * ) strDescription
                  newMetadata:( nullable NSDictionary * ) dicMetadata
                       thenDo:( nullable void ( ^ ) ( IOStackBStorageVolumeV2 * _Nullable updatedUser, id _Nullable dicFullResponse ) ) doAfterUpdate;
- ( void ) deleteVolumeWithID:( nonnull NSString * ) uidVolume
           waitUntilIsDeleted:( BOOL ) bWaitDeleted
                       thenDo:( nullable void ( ^ ) ( bool isDeleted, id _Nullable idFullResponse ) ) doAfterDelete;
- ( void ) listVolumeTypesThenDo:( nullable void ( ^ ) ( NSArray * _Nullable arrVolumeTypes, id _Nullable idFullResponse ) ) doAfterList;
- ( void ) createVolumeTypeWithName:( nonnull NSString * ) nameVolumeType
                     andDescription:( nullable NSString * ) strDescription
                      andExtraSpecs:( nullable NSDictionary * ) dicExtraSpecs
                           isPublic:( BOOL ) isPublic
                             thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable createdVolumeType, id _Nullable dicFullResponse ) ) doAfterCreate;
- ( void ) getdetailForVolumeTypeWithID:( nonnull NSString * ) uidVolumeType
                                 thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicVolumeType ) ) doAfterGetDetail;
- ( void ) updateVolumeTypeWithID:( nonnull NSString * ) uidVolumeType
                          newName:( nullable NSString * ) nameVolumeType
                   newDescription:( nullable NSString * ) strDescription
                    newExtraSpecs:( nullable NSDictionary * ) dicExtraSpecs
                         isPublic:( BOOL ) isPublic
                           thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable updatedVolumeType, id _Nullable dicFullResponse ) ) doAfterUpdate;
- ( void ) deleteVolumeTypeWithID:( nonnull NSString * ) uidVolumeType
                           thenDo:( nullable void ( ^ ) ( bool isDeleted, id _Nullable idFullResponse ) ) doAfterDelete;
- ( void ) listProjectWithAccessToVolumeTypeWithID:( nonnull NSString * ) uidVolumeType
                                            thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicMetadata, id _Nullable idFullResponse ) ) doAfterList;
- ( void ) createAccessToVolumeTypeWithID:( nonnull NSString * ) uidVolumeType
                             forProjectID:( nonnull NSString * ) uidProjectOrTenant
                                   thenDo:( nullable void ( ^ ) ( BOOL isCreated, id _Nullable dicFullResponse ) ) doAfterCreate;
- ( void ) deleteAccessToVolumeTypeWithID:( nonnull NSString * ) uidVolumeType
                             forProjectID:( nonnull NSString * ) uidProjectOrTenant
                                   thenDo:( nullable void ( ^ ) ( BOOL isCreated, id _Nullable dicFullResponse ) ) doAfterCreate;
- ( void ) listMetadataForVolumeWithID:( nonnull NSString * ) uidVolume
                                thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicMetadata, id _Nullable idFullResponse ) ) doAfterList;
- ( void ) createMetadataForVolumeWithID:( nonnull NSString * ) uidVolume
                             andMetadata:( nonnull NSDictionary * ) dicMetadata
                                  thenDo:( nullable void ( ^ ) ( BOOL isCreated, id _Nullable dicFullResponse ) ) doAfterCreate;
- ( void ) updateMetadataForVolumeWithID:( nonnull NSString * ) uidVolume
                             andMetadata:( nonnull NSDictionary * ) dicMetadata
                                  thenDo:( nullable void ( ^ ) ( BOOL isUpdated, id _Nullable dicFullResponse ) ) doAfterUpdate;
- ( void ) extendVolumeWithID:( nonnull NSString * ) uidVolume
                       toSize:( nonnull NSNumber * ) nSizeInGiB
         waitUntilIsAvailable:( BOOL ) bWaitAvailable
                       thenDo:( nullable void ( ^ ) ( BOOL bExtended, id _Nullable idFullResponse ) ) doAfterUpdate;
/*TODO : find if those really are used
- ( void ) resetStatusforVolumeWithID:( nonnull NSString * ) uidVolume
                           withStatus:( nonnull NSString * ) strVolumeStatus
                               thenDo:( nullable void ( ^ ) ( BOOL bReset, id _Nullable idFullResponse ) ) doAfterReset;
- ( void ) resetAttachStatusforVolumeWithID:( nonnull NSString * ) uidVolume
                                 withStatus:( nonnull NSString * ) strAttachStatus
                                     thenDo:( nullable void ( ^ ) ( BOOL bReset, id _Nullable idFullResponse ) ) doAfterReset;
- ( void ) resetMigrationStatusforVolumeWithID:( nonnull NSString * ) uidVolume
                                    withStatus:( nonnull NSString * ) strMigrationStatus
                                        thenDo:( nullable void ( ^ ) ( BOOL bReset, id _Nullable idFullResponse ) ) doAfterReset;
- ( void ) resetStatusforVolumeWithID:( nonnull NSString * ) uidVolume
                     withVolumeStatus:( nullable NSString * ) strVolumeStatus
                      andAttachStatus:( nullable NSString * ) strAttachStatus
                   andMigrationStatus:( nullable NSString * ) strMigrationStatus
                               thenDo:( nullable void ( ^ ) ( BOOL bReset, id _Nullable idFullResponse ) ) doAfterReset;
*/
- ( void ) setImageMetadataForVolumeWithID:( nonnull NSString * ) uidVolume
                                toMetadata:( nonnull NSDictionary * ) dicImageMetadata
                                    thenDo:( nullable void ( ^ ) ( BOOL bSet, id _Nullable idFullResponse ) ) doAfterSet;
- ( void ) unsetImageMetadataForVolumeWithID:( nonnull NSString * ) uidVolume
                              forMetadataKey:( nonnull NSString * ) strMetadataName
                                      thenDo:( nullable void ( ^ ) ( BOOL bUnset, id _Nullable idFullResponse ) ) doAfterUnset;
- ( void ) attachVolumeWithID:( nonnull NSString * ) uidVolume
             toInstanceWithID:( nonnull NSString * ) uidInstance
                 atMountPoint:( nullable NSString * ) strMountPoint
                       thenDo:( nullable void ( ^ ) ( BOOL bAttached, id _Nullable idFullResponse ) ) doAfterAttached;
- ( void ) unmanageVolumeWithID:( nonnull NSString * ) uidVolume
                         thenDo:( nullable void ( ^ ) ( BOOL bUnset, id _Nullable idFullResponse ) ) doAfterUnset;
- ( void ) promoteReplicationWithVolumeID:( nonnull NSString * ) uidVolume
                                   thenDo:( nullable void ( ^ ) ( BOOL bPromoted, id _Nullable idFullResponse ) ) doAfterPromoted;
- ( void ) reenableReplicaWithVolumeID:( nonnull NSString * ) uidVolume
                                thenDo:( nonnull void ( ^ ) ( BOOL bReenabled, id _Nullable idFullResponse ) ) doAfterReenable;
- ( void ) listBackupsThenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicBackups, id _Nullable idFullResponse ) ) doAfterList;
- ( void ) createBackupFromVolumeWithID:( nonnull NSString * ) uidVolumeToBackupFrom
                               withName:( nullable NSString * ) nameBackup
                         andDescription:( nullable NSString * ) strBackupDescription
                       andContainerName:( nullable NSString * ) strContainerName
                          incrementally:( BOOL ) bIncremental
                                  force:( BOOL ) bForceBackup
                   waitUntilIsAvailable:( BOOL ) bWaitAvailable
                                 thenDo:( nullable void ( ^ ) ( IOStackBStorageBackupV2 * _Nullable backupCreated, id _Nullable dicFullResponse ) ) doAfterCreate;
- ( void ) deleteBackupWithID:( nonnull NSString * ) uidBackup
           waitUntilIsDeleted:( BOOL ) bWaitDeleted
                       thenDo:( nullable void ( ^ ) ( bool isDeleted, id _Nullable idFullResponse ) ) doAfterDelete;
- ( void ) restoreBackupWithID:( nonnull NSString * ) uidBackup
                ofVolumeWithID:( nullable NSString * ) uidVolume
                        orName:( nullable NSString * ) nameVolume
          waitUntilIsAvailable:( BOOL ) bWaitAvailable
                        thenDo:( nullable void ( ^ ) ( IOStackBStorageVolumeV2 * _Nullable volumeRestored ) ) doAfterCreate;
- ( void ) forcedeleteBackupWithID:( nonnull NSString * ) uidBackup
                            thenDo:( nullable void ( ^ ) ( BOOL isForceDeleted ) ) doAfterForceDelete;
- ( void ) listQuotasForProjectOrTenantWithID:( nonnull NSString * ) uidProjectOrTenant
                                       thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicQuotas ) ) doAfterList;
- ( void ) updateQuotaForProjectOrTenantWithID:( nonnull NSString * ) uidProjectOrTenant
                             newTotalSizeQuota:( nullable NSNumber * ) numMaxTotalGBytes
                               newVolumesQuota:( nullable NSNumber * ) numMaxVolumes
                             newPerVolumeQuota:( nullable NSNumber * ) numMaxPerVolumeGBytes
                                newBackupQuota:( nullable NSNumber * ) numMaxBackups
                       newBackupTotalSizeQuota:( nullable NSNumber * ) numMaxBackupTotalSizeGBytes
                              newSnapshotQuota:( nullable NSNumber * ) numMaxSnapshots
                                        thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable updatedQuota ) ) doAfterUpdate;
- ( void ) deleteQuotaForProjectOrTenantWithID:( nonnull NSString * ) uidProjectOrTenant
                                        thenDo:( nullable void ( ^ ) ( bool isDeleted, id _Nullable idFullResponse ) ) doAfterDelete;
- ( void ) getdetailDefaultQuotasThenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicQuota ) ) doAfterGetDetail;
- ( void ) listQuotasForUserWithID:( nonnull NSString * ) uidUser
          andProjectOrTenantWithID:( nonnull NSString * ) uidProjectOrTenant
                            thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicQuotas ) ) doAfterList;
- ( void ) updateQuotaForUserWithID:( nonnull NSString * ) uidUser
           andProjectOrTenantWithID:( nonnull NSString * ) uidProjectOrTenant
                  newTotalSizeQuota:( nullable NSNumber * ) numMaxTotalGBytes
                    newVolumesQuota:( nullable NSNumber * ) numMaxVolumes
                  newPerVolumeQuota:( nullable NSNumber * ) numMaxPerVolumeGBytes
                     newBackupQuota:( nullable NSNumber * ) numMaxBackups
            newBackupTotalSizeQuota:( nullable NSNumber * ) numMaxBackupTotalSizeGBytes
                   newSnapshotQuota:( nullable NSNumber * ) numMaxSnapshots
                             thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable updatedQuota ) ) doAfterUpdate;
- ( void ) deleteQuotaForUserWithID:( nonnull NSString * ) uidUser
           andProjectOrTenantWithID:( nonnull NSString * ) uidProjectOrTenant
                             thenDo:( nullable void ( ^ ) ( bool isDeleted, id _Nullable idFullResponse ) ) doAfterDelete;
- ( void ) getdetailQuotasForUserWithID:( nonnull NSString * ) uidUser
               andProjectOrTenantWithID:( nonnull NSString * ) uidProjectOrTenant
                                 thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicQuota ) ) doAfterGetDetail;
- ( void ) listSnapshotsThenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicSnapshots, id _Nullable idFullResponse ) ) doAfterList;
- ( void ) createSnapshotFromVolumeWithID:( nonnull NSString * ) uidVolumeToSnapshotFrom
                                 withName:( nullable NSString * ) nameSnapshot
                           andDescription:( nullable NSString * ) strSnapshotDescription
                                  force:( BOOL ) bForceSnapshot
                   waitUntilIsAvailable:( BOOL ) bWaitAvailable
                                 thenDo:( nullable void ( ^ ) ( IOStackBStorageSnapshotV2 * _Nullable snapshotCreated, id _Nullable dicFullResponse ) ) doAfterCreate;
- ( void ) getdetailForSnapshotWithID:( nonnull NSString * ) uidSnapshot
                               thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicSnapshot ) ) doAfterGetDetail;
- ( void ) updateQuotaForSnapshotWithID:( nonnull NSString * ) uidSnapshot
                                newName:( nullable NSString * ) nameSnapshot
                         newDescription:( nullable NSString * ) strDescription
                                 thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable updatedSnapshot ) ) doAfterUpdate;
- ( void ) deleteSnapshotWithID:( nonnull NSString * ) uidSnapshot
             waitUntilIsDeleted:( BOOL ) bWaitDeleted
                         thenDo:( nullable void ( ^ ) ( bool isDeleted, id _Nullable idFullResponse ) ) doAfterDelete;
- ( void ) listMetadataForSnapshotWithID:( nonnull NSString * ) uidSnapshot
                                  thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicSnapshot ) ) doAfterGetDetail;
- ( void ) updateMetadataForSnapshotWithID:( nonnull NSString * ) uidSnapshot
                               andMetadata:( nonnull NSDictionary * ) dicMetadata
                                    thenDo:( nullable void ( ^ ) ( BOOL isUpdated ) ) doAfterUpdate;
- ( void ) listStoragePoolsThenDo:( nullable void ( ^ ) ( NSArray * _Nullable arrStoragePools ) ) doAfterList;
- ( void ) listVolumeTransfersThenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicVolumeTransfers, id _Nullable idFullResponse ) ) doAfterList;
- ( void ) createVolumeTransferForVolumeWithID:( nonnull NSString * ) uidVolumeToTransfer
                              withTransferName:( nullable NSString * ) nameVolumeTransfer
                                        thenDo:( nullable void ( ^ ) ( IOStackBStorageVolumeTransferV2 * _Nullable snapshotCreated, id _Nullable dicFullResponse ) ) doAfterCreate;
- ( void ) deleteVolumeTransferWithID:( nonnull NSString * ) uidVolumeTransfer
                               thenDo:( nullable void ( ^ ) ( bool isDeleted, id _Nullable idFullResponse ) ) doAfterDelete;
- ( void ) acceptVolumeTransferForVolumeWithID:( nonnull NSString * ) uidVolumeTransfer
                                   withAuthKey:( nonnull NSString * ) keyAuthentication
                                        thenDo:( nullable void ( ^ ) ( BOOL isTransferAccepted, id _Nullable dicFullResponse ) ) doAfterAccept;
- ( void ) listConsistencyGroupsThenDo:( nullable void ( ^ ) ( NSArray * _Nullable arrConsistencyGroups, id _Nullable idFullResponse ) ) doAfterList;
- ( void ) createConsistencyGroupWithName:( nullable NSString * ) nameConsistencyGroup
                           andDescription:( nullable NSString * ) strDescription
                           andVolumeTypes:( nullable NSArray<NSString *> * ) arrVolumeTypes
                                forUserID:( nullable NSString * ) uidUser
                             andProjectID:( nullable NSString * ) uidProject
                                andStatus:( nullable NSString * ) statusConsistencyGroup
                       inAvailabilityZone:( nullable NSString * ) strAvailabilityZone
                                   thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable createdConsistencyGroup, id _Nullable dicFullResponse ) ) doAfterCreate;
- ( void ) createConsistencyGroupWithName:( nullable NSString * ) nameConsistencyGroup
                           andDescription:( nullable NSString * ) strDescription
                     fromConsistencyGroup:( nullable NSString * ) uidConsistencyGroupFrom
                            andCGSnapshot:( nullable NSString * ) uidConsistencyGroupSnapFrom
                                forUserID:( nullable NSString * ) uidUser
                             andProjectID:( nullable NSString * ) uidProject
                                andStatus:( nullable NSString * ) statusConsistencyGroup
                                   thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable createdConsistencyGroup, id _Nullable dicFullResponse ) ) doAfterCreate;
- ( void ) getdetailForConsistencyGroupWithID:( nullable NSString * ) uidConsistencyGroup
                                       thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicConsistencyGroup ) ) doAfterGetDetail;
- ( void ) updateConsistencyGroupWithID:( nonnull NSString * ) uidConsistencyGroup
                                newName:( nullable NSString * ) nameConsistencyGroup
                         newDescription:( nullable NSString * ) strDescription
                             addVolumes:( nullable NSArray<NSString *> * ) arrVolumeIDsToAdd
                          removeVolumes:( nullable NSArray<NSString *> * ) arrVolumeIDsToRemove
                                 thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable updatedConsistencyGroup, id _Nullable dicFullResponse ) ) doAfterUpdate;
- ( void ) deleteConsistencyGroupWithID:( nonnull NSString * ) uidConsistencyGroup
                                 thenDo:( nullable void ( ^ ) ( bool isDeleted, id _Nullable idFullResponse ) ) doAfterDelete;
- ( void ) listConsistencyGroupsSnapshotsThenDo:( nullable void ( ^ ) ( NSArray * _Nullable arrConsistencyGroups, id _Nullable idFullResponse ) ) doAfterList;
- ( void ) createConsistencyGroupSnapshotWithCGroupID:( nonnull NSString * ) uidConsistencyGroup
                                              andName:( nullable NSString * ) nameConsistencyGroup
                                       andDescription:( nullable NSString * ) strDescription
                                            forUserID:( nullable NSString * ) uidUser
                                         andProjectID:( nullable NSString * ) uidProject
                                            andStatus:( nullable NSString * ) statusConsistencyGroupSnapshot
                                               thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable createdConsistencyGroupSnapshot, id _Nullable dicFullResponse ) ) doAfterCreate;
- ( void ) getdetailForConsistencyGroupSnapshotWithID:( nonnull NSString * ) uidConsistencyGroupSnapshot
                                               thenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicConsistencyGroup ) ) doAfterGetDetail;
- ( void ) deleteConsistencyGroupSnapshotWithID:( nonnull NSString * ) uidConsistencyGroupSnapshot
                                         thenDo:( nullable void ( ^ ) ( bool isDeleted, id _Nullable idFullResponse ) ) doAfterDelete;


@end
