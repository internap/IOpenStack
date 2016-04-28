//
//  IOStackBlockStorageV2.h
//  IOpenStack
//
//  Created by Bruno Morel on 2016-03-29.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import <IOpenStack/IOpenStack.h>


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
                                        andTokenID:( nonnull NSString * ) strTokenID;
+ ( nonnull instancetype ) initWithIdentity:( nonnull id<IOStackIdentityInfos> ) idUserIdentity;

- ( nonnull instancetype ) initWithBlockStorageURL:( nonnull NSString * ) strBlockStorageRoot
                                        andTokenID:( nonnull NSString * ) strTokenID
                              forProjectOrTenantID:( nonnull NSString * ) strProjectOrTenantID;
- ( nonnull instancetype ) initWithIdentity:( nonnull id<IOStackIdentityInfos> ) idUserIdentity;
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
- ( void ) deleteVolumeWithID:( nonnull NSString * ) uidVolume
           waitUntilIsDeleted:( BOOL ) bWaitDeleted
                       thenDo:( nullable void ( ^ ) ( bool isDeleted, id _Nullable idFullResponse ) ) doAfterDelete;
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
- ( void ) listSnapshotsThenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicSnapshots, id _Nullable idFullResponse ) ) doAfterList;
- ( void ) createSnapshotFromVolumeWithID:( nonnull NSString * ) uidVolumeToSnapshotFrom
                                 withName:( nullable NSString * ) nameSnapshot
                           andDescription:( nullable NSString * ) strSnapshotDescription
                                  force:( BOOL ) bForceSnapshot
                   waitUntilIsAvailable:( BOOL ) bWaitAvailable
                                 thenDo:( nullable void ( ^ ) ( IOStackBStorageSnapshotV2 * _Nullable snapshotCreated, id _Nullable dicFullResponse ) ) doAfterCreate;
- ( void ) deleteSnapshotWithID:( nonnull NSString * ) uidSnapshot
             waitUntilIsDeleted:( BOOL ) bWaitDeleted
                         thenDo:( nullable void ( ^ ) ( bool isDeleted, id _Nullable idFullResponse ) ) doAfterDelete;
- ( void ) listVolumeTransfersThenDo:( nullable void ( ^ ) ( NSDictionary * _Nullable dicVolumeTransfers, id _Nullable idFullResponse ) ) doAfterList;
- ( void ) createVolumeTransferForVolumeWithID:( nonnull NSString * ) uidVolumeToTransfer
                              withTransferName:( nullable NSString * ) nameVolumeTransfer
                                        thenDo:( nullable void ( ^ ) ( IOStackBStorageVolumeTransferV2 * _Nullable snapshotCreated, id _Nullable dicFullResponse ) ) doAfterCreate;
- ( void ) deleteVolumeTransferWithID:( nonnull NSString * ) uidVolumeTransfer
                               thenDo:( nullable void ( ^ ) ( bool isDeleted, id _Nullable idFullResponse ) ) doAfterDelete;
- ( void ) acceptVolumeTransferForVolumeWithID:( nonnull NSString * ) uidVolumeTransfer
                                   withAuthKey:( nonnull NSString * ) keyAuthentication
                                        thenDo:( nullable void ( ^ ) ( BOOL isTransferAccepted, id _Nullable dicFullResponse ) ) doAfterAccept;


@end
