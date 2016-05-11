//
//  IOStackBlockStorageV2.m
//  IOpenStack
//
//  Created by Bruno Morel on 2016-03-29.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import "IOStackBlockStorageV2.h"


#define BLOCKSTORAGEV2_SERVICE_URI                  @"v2/"
#define BLOCKSTORAGEV2_VOLUMES_URN                  @"volumes"
#define BLOCKSTORAGEV2_VOLUMESDETAIL_URN            @"volumes/detail"
#define BLOCKSTORAGEV2_VOLUMEMETADATA_URN           @"metadata"
#define BLOCKSTORAGEV2_VOLUMETYPES_URN              @"types"
#define BLOCKSTORAGEV2_VOLUMEACTION_URN             @"action"
#define BLOCKSTORAGEV2_BACKUPS_URN                  @"backups"
#define BLOCKSTORAGEV2_BACKUPSDETAIl_URN            @"backups/detail"
#define BLOCKSTORAGEV2_BACKUPSACTION_URN            @"action"
#define BLOCKSTORAGEV2_SNAPSHOTS_URN                @"snapshots"
#define BLOCKSTORAGEV2_SNAPSHOTSDETAIl_URN          @"snapshots/detail"
#define BLOCKSTORAGEV2_SNAPSHOTSACTION_URN          @"action"
#define BLOCKSTORAGEV2_VOLUMETRANSFERS_URN          @"os-volume-transfer"
#define BLOCKSTORAGEV2_VOLUMETRANSFERSDETAIl_URN    @"os-volume-transfer/detail"
#define BLOCKSTORAGEV2_VOLUMETRANSFERSACCEPT_URN    @"accept"


@implementation IOStackBlockStorageV2


@synthesize currentProjectOrTenantID;
@synthesize currentTokenID;


+ ( instancetype ) initWithBlockStorageURL:( NSString * ) strBlockStorageRoot
                                andTokenID:( NSString * ) strTokenID
                      forProjectOrTenantID:( NSString * ) strProjectOrTenantID
{
    return [ [ self alloc ] initWithBlockStorageURL:strBlockStorageRoot
                                         andTokenID:strTokenID
                               forProjectOrTenantID:strProjectOrTenantID ];
}

+ ( instancetype ) initWithIdentity:( id<IOStackIdentityInfos> ) idUserIdentity
{
    return [ [ self alloc ] initWithIdentity:idUserIdentity ];
}


#pragma mark - Object init
- ( instancetype ) initWithBlockStorageURL:( NSString * ) strBlockStorageRoot
                                andTokenID:( NSString * ) strTokenID
                      forProjectOrTenantID:( NSString * ) strProjectOrTenantID
{
    if( self = [super initWithPublicURL:[NSURL URLWithString:strBlockStorageRoot]
                                andType:BLOCKSTORAGEV2_SERVICE
                        andMajorVersion:@2
                        andMinorVersion:@0
                        andProviderName:GENERIC_SERVICENAME] )
    {
        currentTokenID              = strTokenID;
        currentProjectOrTenantID    = strProjectOrTenantID;
        
        [self setHTTPHeader:@"X-Auth-Token"
                  withValue:currentTokenID];
    }
    return self;
}

- ( instancetype ) initWithIdentity:( id<IOStackIdentityInfos> ) idUserIdentity
{
    IOStackService * currentService = [idUserIdentity.currentServices valueForKey:BLOCKSTORAGEV2_SERVICE];
    
    if( idUserIdentity.currentProjectOrTenantID == nil )
        return nil;
    
    return [self initWithBlockStorageURL:[[currentService urlPublic] absoluteString]
                              andTokenID:idUserIdentity.currentTokenID
                    forProjectOrTenantID:idUserIdentity.currentProjectOrTenantID];
}

#pragma mark - Volume management
- ( void ) listVolumesThenDo:( void ( ^ ) ( NSDictionary * dicVolumes, id idFullResponse ) ) doAfterList
{
    [self listResource:BLOCKSTORAGEV2_VOLUMESDETAIL_URN
            withHeader:nil
          andUrlParams:nil
             insideKey:@"volumes"
                thenDo:^(NSArray * _Nullable arrFound, id  _Nullable dataResponse)
     {
         if( doAfterList != nil )
             doAfterList( [IOStackBStorageVolumeV2 parseFromAPIResponse:arrFound], dataResponse );
     }];
}

- ( void ) createVolumeWithUrlParams:( NSDictionary * ) dicUrlParams
                waitUntilIsAvailable:( BOOL ) bWaitAvailable
                              thenDo:( void ( ^ ) ( IOStackBStorageVolumeV2 * volumeCreated, id dicFullResponse ) ) doAfterCreate
{
    [self createResource:BLOCKSTORAGEV2_VOLUMES_URN
              withHeader:nil
            andUrlParams:dicUrlParams
                  thenDo:^(NSDictionary * _Nullable dicResponseHeaders, id  _Nullable idFullResponse)
     {
         if( ![[idFullResponse objectForKey:@"volume"] isKindOfClass:[NSDictionary class]] &&
                doAfterCreate != nil )
         {
             doAfterCreate( nil, nil );
             return;
         }
         
         IOStackBStorageVolumeV2 * newVolume = [IOStackBStorageVolumeV2 initFromAPIResponse:[idFullResponse objectForKey:@"volume"]];
         
         if( bWaitAvailable )
             [self waitVolumeWithID:newVolume.uniqueID
                          forStatus:IOStackVolumeStatusAvailable
                             thenDo:^( bool isWithStatus )
              {
                  if( isWithStatus )
                      [newVolume setAvailable:YES];
                  
                  if( doAfterCreate != nil )
                  {
                      if( isWithStatus )
                          doAfterCreate( newVolume, idFullResponse );
                      
                      else
                      {
                          NSLog( @"Creation failed" );
                          doAfterCreate( nil, nil );
                      }
                  }
              }];
         
         else
             doAfterCreate( newVolume, idFullResponse );
     }];
}

- ( void ) createVolumeWithSize:( NSNumber * ) nSizeInGiB
                        andName:( NSString * ) strVolumeName
                  andVolumetype:( NSString * ) typeVolume
                 andDescription:( NSString * ) strDescription
                    andMetadata:( NSDictionary * ) dicMetadata
              andSchedulerHints:( NSDictionary * ) dicSchedulerHints
          andConsistencyGroupID:( NSString * ) uidConsistencyGroup
               allowMultiAttach:( BOOL ) bMultiAttachable
             inAvailabilityZone:( NSString * ) nameAvailabilityZone
             fromSourceVolumeID:( NSString * ) uidSourceVolume
               orSnapshotWithID:( NSString * ) uidSnapshot
             orBootableImageRef:( NSString * ) uidImageRef
                orSourceReplica:( NSString * ) uidSourceReplica
           waitUntilIsAvailable:( BOOL ) bWaitAvailable
                         thenDo:( void ( ^ ) ( IOStackBStorageVolumeV2 * volumeCreated, id dicFullResponse ) ) doAfterCreate
{
    NSMutableDictionary * dicParams = [NSMutableDictionary dictionary];
    
    [dicParams setValue:nSizeInGiB
                 forKey:@"size"];

    if( strVolumeName != nil )
        [dicParams setValue:strVolumeName
                     forKey:@"name"];
    
    if( uidSourceVolume != nil )
        [dicParams setValue:uidSourceVolume
                     forKey:@"source_volid"];
    
    if( typeVolume != nil )
        [dicParams setValue:typeVolume
                     forKey:@"volume_type"];
    
    if( strDescription != nil )
        [dicParams setValue:strDescription
                     forKey:@"description"];
    
    if( dicMetadata != nil )
        [dicParams setValue:dicMetadata
                     forKey:@"metadata"];
    
    if( dicSchedulerHints != nil )
        [dicParams setValue:dicSchedulerHints
                     forKey:@"scheduler_hints"];
    
    if( uidConsistencyGroup != nil )
        [dicParams setValue:uidConsistencyGroup
                     forKey:@"consistencygroup_id"];
    
    [dicParams setValue:[NSNumber numberWithBool:bMultiAttachable]
                 forKey:@"multiattach"];
    
    if( nameAvailabilityZone != nil )
        [dicParams setValue:nameAvailabilityZone
                     forKey:@"availability_zone"];
    
    if( uidSnapshot != nil )
        [dicParams setValue:uidSnapshot
                     forKey:@"snapshot_id"];
    
    if( uidImageRef != nil )
        [dicParams setValue:uidImageRef
                     forKey:@"imageRef"];
    
    if( uidSourceReplica != nil )
        [dicParams setValue:uidSourceReplica
                     forKey:@"source_replica"];
    
    [self createVolumeWithUrlParams:@{@"volume": dicParams }
               waitUntilIsAvailable:bWaitAvailable
                             thenDo:doAfterCreate];
}

- ( void ) createVolumeWithSize:( NSNumber * ) nSizeInGiB
           waitUntilIsAvailable:( BOOL ) bWaitAvailable
                         thenDo:( void ( ^ ) ( IOStackBStorageVolumeV2 * volumeCreated, id dicFullResponse ) ) doAfterCreate
{
    [self createVolumeWithSize:nSizeInGiB
                       andName:nil
                 andVolumetype:nil
                andDescription:nil
                   andMetadata:nil
             andSchedulerHints:nil
         andConsistencyGroupID:nil
              allowMultiAttach:NO
            inAvailabilityZone:nil
            fromSourceVolumeID:nil
              orSnapshotWithID:nil
            orBootableImageRef:nil
               orSourceReplica:nil
          waitUntilIsAvailable:bWaitAvailable
                        thenDo:doAfterCreate];
}

- ( void ) deleteVolumeWithID:( NSString * ) uidVolume
           waitUntilIsDeleted:( BOOL ) bWaitDeleted
                       thenDo:( void ( ^ ) ( bool isDeleted, id idFullResponse ) ) doAfterDelete
{
    NSString * urlVolume = [NSString stringWithFormat:@"%@/%@", BLOCKSTORAGEV2_VOLUMES_URN, uidVolume];
    [self deleteResource:urlVolume
              withHeader:nil
                  thenDo:^(NSDictionary * _Nullable dicResults, id  _Nullable idFullResponse)
    {
        if( bWaitDeleted )
            [self waitVolumeWithID:uidVolume
                         forStatus:IOStackVolumeStatusDeleting
                            thenDo:^(bool isWithStatus)
             {
                 if( doAfterDelete != nil )
                     doAfterDelete( isWithStatus, idFullResponse );
             }];
        else if( doAfterDelete != nil )
            doAfterDelete( dicResults != nil, idFullResponse );
    }];
}


#pragma mark - Refresh Volume status info loop mechanism
- ( void ) waitVolumeWithID:( NSString * ) uidVolume
                  forStatus:( NSString * ) statusVolume
                     thenDo:( void ( ^ ) ( bool isWithStatus ) ) doAfterWait
{
    NSString * urlVolume = [NSString stringWithFormat:@"%@/%@", BLOCKSTORAGEV2_VOLUMES_URN, uidVolume];
    if( [statusVolume isEqualToString:IOStackVolumeStatusDeleting] )
        [self waitResource:urlVolume
             withUrlParams:nil
                 insideKey:@"volume"
                  forField:nil
              toEqualValue:nil
             orErrorValues:IOStackVolumeStatusErrorArray
                    thenDo:doAfterWait];
    
    else
        [self waitResource:urlVolume
             withUrlParams:nil
                 insideKey:@"volume"
                  forField:@"status"
              toEqualValue:statusVolume
             orErrorValues:IOStackVolumeStatusErrorArray
                    thenDo:doAfterWait];
}


#pragma mark - Volume Metadata
- ( void ) listMetadataForVolumeWithID:( NSString * ) uidVolume
                                thenDo:( void ( ^ ) ( NSDictionary * dicMetadata, id idFullResponse ) ) doAfterList
{
    NSString * strVolumeMetadataURL = [NSString stringWithFormat:@"%@/%@/%@", BLOCKSTORAGEV2_VOLUMES_URN, uidVolume, BLOCKSTORAGEV2_VOLUMEMETADATA_URN ];
    
    [self readResource:strVolumeMetadataURL
            withHeader:nil
          andUrlParams:nil
             insideKey:@"metadata"
                thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable dataResponse)
     {
         if( doAfterList != nil )
             doAfterList( dicObjectFound, dataResponse );
     }];
    /*
     NSString * strVolumeMetadataURL = [NSString stringWithFormat:@"%@/%@/%@", BLOCKSTORAGEV2_VOLUMES_URN, uidVolume, BLOCKSTORAGEV2_VOLUMEMETADATA_URN ];
    
    [self serviceGET:strVolumeMetadataURL
          withParams:nil
    onServiceSuccess:^( NSString * uidServiceTask, id responseObject, NSDictionary * dicResponseHeaders ) {
        if( ![responseObject isKindOfClass:[NSDictionary class]] )
            [NSException exceptionWithName:[NSString stringWithFormat:@"Method %@ bad return", strVolumeMetadataURL]
                                    reason:@"Return value is not a NSDictionnary"
                                  userInfo:@{@"returnedValue": responseObject}];
        
        NSDictionary * dicResponse     = responseObject;
        if( ![[dicResponse objectForKey:@"metadata"] isKindOfClass:[NSArray class]] )
            [NSException exceptionWithName:[NSString stringWithFormat:@"Method %@ bad return", strVolumeMetadataURL]
                                    reason:@"Access object is not a NSDictionnary"
                                  userInfo:@{@"returnedValue": responseObject}];
        
        if( doAfterList != nil )
            doAfterList( [dicResponse objectForKey:@"metadata"], dicResponse );
    }
    onServiceFailure:^( NSString * uidServiceTask, NSError * error, NSUInteger nHTTPStatus ) {
        NSLog( @"Call failed : %@", error );
        
        if( doAfterList != nil )
            doAfterList( nil, nil );
    }];
     */
}

- ( void ) createMetadataForVolumeWithID:( NSString * ) uidVolume
                             andMetadata:( NSDictionary * ) dicMetadata
                              thenDo:( void ( ^ ) ( BOOL isCreated, id dicFullResponse ) ) doAfterCreate
{
    NSString * strVolumeMetadataURL = [NSString stringWithFormat:@"%@/%@/%@", BLOCKSTORAGEV2_VOLUMES_URN, uidVolume, BLOCKSTORAGEV2_VOLUMEMETADATA_URN ];
    
    [self createResource:strVolumeMetadataURL
              withHeader:nil
            andUrlParams:@{ @"metadata" : dicMetadata }
                  thenDo:^(NSDictionary * _Nullable dicResults, id _Nullable idFullResponse) {
                      if( doAfterCreate != nil )
                          doAfterCreate( dicResults != nil, idFullResponse );
                  }];
}

- ( void ) updateMetadataForVolumeWithID:( NSString * ) uidVolume
                             andMetadata:( NSDictionary * ) dicMetadata
                                  thenDo:( void ( ^ ) ( BOOL isUpdated, id dicFullResponse ) ) doAfterUpdate
{
    NSString * strVolumeMetadataURL = [NSString stringWithFormat:@"%@/%@/%@", BLOCKSTORAGEV2_VOLUMES_URN, uidVolume, BLOCKSTORAGEV2_VOLUMEMETADATA_URN ];
    
    [self replaceResource:strVolumeMetadataURL
               withHeader:nil
                andUrlParams:@{ @"metadata" : dicMetadata }
                   thenDo:^(NSDictionary * _Nullable dicResponseHeader, id _Nullable idFullResponse)
    {
        if( doAfterUpdate != nil )
            doAfterUpdate( dicResponseHeader != nil, idFullResponse );
    }];
}


#pragma mark - Action management
- ( void ) updateActionForVolumeWithID:( NSString * ) uidVolume
                          andUrlParams:( NSDictionary * ) urlParams
                       waitUntilStatus:( NSString * ) statusToWaitFor
                                thenDo:( void ( ^ ) ( BOOL bActionDone, id idFullResponse ) ) doAfterUpdate
{
    NSString * strVolumeActionURL = [NSString stringWithFormat:@"%@/%@/%@", BLOCKSTORAGEV2_VOLUMES_URN, uidVolume, BLOCKSTORAGEV2_VOLUMEACTION_URN ];
    
    [self createResource:strVolumeActionURL
              withHeader:nil
            andUrlParams:urlParams
                  thenDo:^(NSDictionary * _Nullable dicResults, id _Nullable idFullResponse)
    {
        if( statusToWaitFor != nil )
            [self waitVolumeWithID:uidVolume
                         forStatus:statusToWaitFor
                            thenDo:^(bool isWithStatus)
             {
                 if( doAfterUpdate != nil )
                     doAfterUpdate( isWithStatus, idFullResponse );
             }];
        else if( doAfterUpdate )
            doAfterUpdate( dicResults != nil, idFullResponse );
    }];
}

- ( void ) extendVolumeWithID:( NSString * ) uidVolume
                       toSize:( NSNumber * ) nSizeInGiB
         waitUntilIsAvailable:( BOOL ) bWaitAvailable
                       thenDo:( void ( ^ ) ( BOOL bExtended, id idFullResponse ) ) doAfterExtend
{
    [self updateActionForVolumeWithID:uidVolume
                         andUrlParams:@{ @"os-extend": @{ @"new_size": nSizeInGiB } }
                 waitUntilStatus:IOStackVolumeStatusAvailable
                               thenDo:doAfterExtend];
}

/* TODO : find if those really are used
- ( void ) resetStatusforVolumeWithID:( NSString * ) uidVolume
                           withStatus:( NSString * ) strVolumeStatus
                               thenDo:( void ( ^ ) ( BOOL bReset, id idFullResponse ) ) doAfterReset
{
    [self updateActionForVolumeWithID:uidVolume
                         andUrlParams:@{ @"os-reset_status": @{ @"status": strVolumeStatus } }
                      waitUntilStatus:IOStackVolumeStatusAvailable
                               thenDo:doAfterReset];
}

- ( void ) resetAttachStatusforVolumeWithID:( NSString * ) uidVolume
                                 withStatus:( NSString * ) strAttachStatus
                                     thenDo:( void ( ^ ) ( BOOL bReset, id idFullResponse ) ) doAfterReset
{
    [self updateActionForVolumeWithID:uidVolume
                         andUrlParams:@{ @"os-reset_status": @{ @"attach_status": strAttachStatus } }
                      waitUntilStatus:nil
                               thenDo:doAfterReset];
}

- ( void ) resetMigrationStatusforVolumeWithID:( NSString * ) uidVolume
                                    withStatus:( NSString * ) strMigrationStatus
                                        thenDo:( void ( ^ ) ( BOOL bReset, id idFullResponse ) ) doAfterReset
{
    [self updateActionForVolumeWithID:uidVolume
                         andUrlParams:@{ @"os-reset_status": @{ @"migration_status": strMigrationStatus } }
                      waitUntilStatus:nil
                               thenDo:doAfterReset];
}

- ( void ) resetStatusforVolumeWithID:( NSString * ) uidVolume
                     withVolumeStatus:( NSString * ) strVolumeStatus
                      andAttachStatus:( NSString * ) strAttachStatus
                   andMigrationStatus:( NSString * ) strMigrationStatus
                               thenDo:( void ( ^ ) ( BOOL bReset, id idFullResponse ) ) doAfterReset
{
    NSMutableDictionary * dicStatuses = nil;
    
    if( strVolumeStatus != nil )
        dicStatuses[ @"status" ] = strVolumeStatus;
    
    if( strAttachStatus != nil )
        dicStatuses[ @"attach_status" ] = strAttachStatus;
    
    if( strMigrationStatus != nil )
        dicStatuses[ @"migration_status" ] = strMigrationStatus;
    
    if( [dicStatuses count] >= 1 )
        [self updateActionForVolumeWithID:uidVolume
                             andUrlParams:@{ @"os-reset_status": dicStatuses }
                          waitUntilStatus:nil
                                   thenDo:doAfterReset];
}
*/
- ( void ) setImageMetadataForVolumeWithID:( NSString * ) uidVolume
                                toMetadata:( NSDictionary * ) dicImageMetadata
                                    thenDo:( void ( ^ ) ( BOOL bSet, id idFullResponse ) ) doAfterSet
{
    if( [dicImageMetadata count] >= 1 )
        [self updateActionForVolumeWithID:uidVolume
                             andUrlParams:@{ @"os-set_image_metadata": @{ @"metadata": dicImageMetadata } }
                          waitUntilStatus:nil
                                   thenDo:doAfterSet];
}

- ( void ) unsetImageMetadataForVolumeWithID:( NSString * ) uidVolume
                              forMetadataKey:( NSString * ) strMetadataName
                                    thenDo:( void ( ^ ) ( BOOL bUnset, id idFullResponse ) ) doAfterUnset
{
    [self updateActionForVolumeWithID:uidVolume
                         andUrlParams:@{ @"os-unset_image_metadata": @{ @"key": strMetadataName } }
                      waitUntilStatus:nil
                               thenDo:doAfterUnset];
}

- ( void ) attachVolumeWithID:( NSString * ) uidVolume
             toInstanceWithID:( NSString * ) uidInstance
                 atMountPoint:( NSString * ) strMountPoint
                       thenDo:( void ( ^ ) ( BOOL bAttached, id idFullResponse ) ) doAfterAttached
{
    NSMutableDictionary * dicAttachement = nil;
    
    if( uidInstance != nil )
        dicAttachement[ @"instance_uuid" ] = uidInstance;
    
    if( strMountPoint != nil )
        dicAttachement[ @"mountpoint" ] = strMountPoint;
    
    [self updateActionForVolumeWithID:uidVolume
                         andUrlParams:@{ @"os-attach": dicAttachement }
                      waitUntilStatus:nil
                               thenDo:doAfterAttached];
}

- ( void ) unmanageVolumeWithID:( NSString * ) uidVolume
                         thenDo:( void ( ^ ) ( BOOL bUnset, id idFullResponse ) ) doAfterUnset
{
    [self updateActionForVolumeWithID:uidVolume
                         andUrlParams:@{ @"os-unmanage": [NSNull null] }
                      waitUntilStatus:nil
                               thenDo:doAfterUnset];
}

- ( void ) promoteReplicationWithVolumeID:( NSString * ) uidVolume
                                   thenDo:( void ( ^ ) ( BOOL bPromoted, id idFullResponse ) ) doAfterPromoted
{
    [self updateActionForVolumeWithID:uidVolume
                         andUrlParams:@{ @"os-promote-replica": [NSNull null] }
                      waitUntilStatus:nil
                               thenDo:doAfterPromoted];
}

- ( void ) reenableReplicaWithVolumeID:( NSString * ) uidVolume
                                thenDo:( void ( ^ ) ( BOOL bReenabled, id idFullResponse ) ) doAfterReenable
{
    [self updateActionForVolumeWithID:uidVolume
                         andUrlParams:@{ @"os-reenable-replica": [NSNull null] }
                      waitUntilStatus:nil
                               thenDo:doAfterReenable];
}


#pragma mark - Backup management
- ( void ) listBackupsThenDo:( void ( ^ ) ( NSDictionary * dicBackups, id idFullResponse ) ) doAfterList
{
    [self listResource:BLOCKSTORAGEV2_BACKUPSDETAIl_URN
            withHeader:nil
          andUrlParams:nil
             insideKey:@"backups"
                thenDo:^(NSArray * _Nullable arrFound, id _Nullable dataResponse)
    {
        if( doAfterList != nil )
            doAfterList( [IOStackBStorageBackupV2 parseFromAPIResponse:arrFound], dataResponse );
        
    }];
}

- ( void ) createBackupWithUrlParams:( NSDictionary * ) dicUrlParams
                waitUntilIsAvailable:( BOOL ) bWaitAvailable
                              thenDo:( void ( ^ ) ( IOStackBStorageBackupV2 * backupCreated, id dicFullResponse ) ) doAfterCreate
{
    [self createResource:BLOCKSTORAGEV2_BACKUPS_URN
              withHeader:nil
            andUrlParams:dicUrlParams
                  thenDo:^(NSDictionary * _Nullable dicResponseHeaders, id  _Nullable idFullResponse)
    {
        IOStackBStorageBackupV2 * newBackup = [IOStackBStorageBackupV2 initFromAPIResponse:[idFullResponse objectForKey:@"backup"]];
        
        if( bWaitAvailable )
            [self waitBackupWithID:newBackup.uniqueID
                         forStatus:IOStackBackupStatusAvailable
                            thenDo:^( bool isWithStatus )
             {
                 if( isWithStatus )
                     [newBackup setAvailable:YES];
                 
                 if( doAfterCreate != nil )
                 {
                     if( isWithStatus )
                         doAfterCreate( newBackup, idFullResponse );
                     
                     else
                     {
                         NSLog( @"Creation failed" );
                         doAfterCreate( nil, nil );
                     }
                 }
             }];
        
        else
            doAfterCreate( newBackup, idFullResponse );
    }];
}

- ( void ) createBackupFromVolumeWithID:( NSString * ) uidVolumeToBackupFrom
                               withName:( NSString * ) nameBackup
                         andDescription:( NSString * ) strBackupDescription
                       andContainerName:( NSString * ) strContainerName
                          incrementally:( BOOL ) bIncremental
                                  force:( BOOL ) bForceBackup
                   waitUntilIsAvailable:( BOOL ) bWaitAvailable
                                 thenDo:( void ( ^ ) ( IOStackBStorageBackupV2 * backupCreated, id dicFullResponse ) ) doAfterCreate
{
    NSMutableDictionary * dicParams = [NSMutableDictionary dictionary];
    
    [dicParams setValue:uidVolumeToBackupFrom
                 forKey:@"volume_id"];
    
    if( nameBackup != nil )
        [dicParams setValue:nameBackup
                     forKey:@"name"];
    
    if( strBackupDescription != nil )
        [dicParams setValue:strBackupDescription
                     forKey:@"description"];
    
    if( strContainerName != nil )
        [dicParams setValue:strContainerName
                     forKey:@"container"];
    
    if( bIncremental )
        [dicParams setValue:[NSNumber numberWithBool:YES]
                     forKey:@"incremental"];
    
    if( bForceBackup )
        [dicParams setValue:[NSNumber numberWithBool:YES]
                     forKey:@"force"];
    
    [self createBackupWithUrlParams:@{@"backup": dicParams }
               waitUntilIsAvailable:bWaitAvailable
                             thenDo:doAfterCreate];
}

- ( void ) deleteBackupWithID:( NSString * ) uidBackup
           waitUntilIsDeleted:( BOOL ) bWaitDeleted
                       thenDo:( void ( ^ ) ( bool isDeleted, id idFullResponse ) ) doAfterDelete
{
    NSString * strBackupURL = [NSString stringWithFormat:@"%@/%@", BLOCKSTORAGEV2_BACKUPS_URN, uidBackup];
    [self deleteResource:strBackupURL
              withHeader:nil
                  thenDo:^(NSDictionary * _Nullable dicResults, id  _Nullable idFullResponse)
    {
        if( bWaitDeleted )
            [self waitBackupWithID:uidBackup
                         forStatus:IOStackBackupStatusDeleting
                            thenDo:^(bool isWithStatus)
             {
                 if( doAfterDelete != nil )
                     doAfterDelete( isWithStatus, idFullResponse );
             }];
        
        else if( doAfterDelete != nil )
            doAfterDelete( dicResults != nil, idFullResponse );
    }];
}

#pragma mark - Refresh Backup status info loop mechanism
- ( void ) waitBackupWithID:( NSString * ) uidBackup
                  forStatus:( NSString * ) statusBackup
                     thenDo:( void ( ^ ) ( bool isWithStatus ) ) doAfterWait
{
    NSString * urlBackup = [NSString stringWithFormat:@"%@/%@", BLOCKSTORAGEV2_BACKUPS_URN, uidBackup];
    if( [statusBackup isEqualToString:IOStackBackupStatusDeleting] )
        [self waitResource:urlBackup
             withUrlParams:nil
                 insideKey:@"backup"
                  forField:nil
              toEqualValue:nil
             orErrorValues:IOStackBackupStatusErrorArray
                    thenDo:doAfterWait];
    
    else
        [self waitResource:urlBackup
             withUrlParams:nil
                 insideKey:@"backup"
                  forField:@"status"
              toEqualValue:statusBackup
             orErrorValues:IOStackBackupStatusErrorArray
                    thenDo:doAfterWait];
}


#pragma mark - Snapshots management
- ( void ) listSnapshotsThenDo:( void ( ^ ) ( NSDictionary * dicSnapshots, id idFullResponse ) ) doAfterList
{
    [self listResource:BLOCKSTORAGEV2_SNAPSHOTSDETAIl_URN
            withHeader:nil
          andUrlParams:nil
             insideKey:@"snapshots"
                thenDo:^(NSArray * _Nullable arrFound, id _Nullable dataResponse)
     {
         if( doAfterList != nil )
             doAfterList( [IOStackBStorageSnapshotV2 parseFromAPIResponse:arrFound], dataResponse );
         
     }];
}

- ( void ) createSnapshotWithUrlParams:( NSDictionary * ) dicUrlParams
                waitUntilIsAvailable:( BOOL ) bWaitAvailable
                              thenDo:( void ( ^ ) ( IOStackBStorageSnapshotV2 * snapshotCreated, id dicFullResponse ) ) doAfterCreate
{
    [self createResource:BLOCKSTORAGEV2_SNAPSHOTS_URN
              withHeader:nil
            andUrlParams:dicUrlParams
                  thenDo:^(NSDictionary * _Nullable dicResponseHeaders, id  _Nullable idFullResponse)
     {
         IOStackBStorageSnapshotV2 * newSnapshot = [IOStackBStorageSnapshotV2 initFromAPIResponse:[idFullResponse objectForKey:@"snapshot"]];
         
         if( bWaitAvailable )
             [self waitSnapshotWithID:newSnapshot.uniqueID
                          forStatus:IOStackSnapshotStatusAvailable
                             thenDo:^( bool isWithStatus )
              {
                  if( isWithStatus )
                      [newSnapshot setAvailable:YES];
                  
                  if( doAfterCreate != nil )
                  {
                      if( isWithStatus )
                          doAfterCreate( newSnapshot, idFullResponse );
                      
                      else
                      {
                          NSLog( @"Creation failed" );
                          doAfterCreate( nil, nil );
                      }
                  }
              }];
         
         else
             doAfterCreate( newSnapshot, idFullResponse );
     }];
}

- ( void ) createSnapshotFromVolumeWithID:( NSString * ) uidVolumeToSnapshotFrom
                               withName:( NSString * ) nameSnapshot
                         andDescription:( NSString * ) strSnapshotDescription
                                  force:( BOOL ) bForceSnapshot
                   waitUntilIsAvailable:( BOOL ) bWaitAvailable
                                 thenDo:( void ( ^ ) ( IOStackBStorageSnapshotV2 * snapshotCreated, id dicFullResponse ) ) doAfterCreate
{
    NSMutableDictionary * dicParams = [NSMutableDictionary dictionary];
    
    [dicParams setValue:uidVolumeToSnapshotFrom
                 forKey:@"volume_id"];
    
    if( nameSnapshot != nil )
        [dicParams setValue:nameSnapshot
                     forKey:@"name"];
    
    if( strSnapshotDescription != nil )
        [dicParams setValue:strSnapshotDescription
                     forKey:@"description"];
    
    if( bForceSnapshot )
        [dicParams setValue:[NSNumber numberWithBool:YES]
                     forKey:@"force"];
    
    [self createSnapshotWithUrlParams:@{@"snapshot": dicParams }
               waitUntilIsAvailable:bWaitAvailable
                             thenDo:doAfterCreate];
}

- ( void ) deleteSnapshotWithID:( NSString * ) uidSnapshot
           waitUntilIsDeleted:( BOOL ) bWaitDeleted
                       thenDo:( void ( ^ ) ( bool isDeleted, id idFullResponse ) ) doAfterDelete
{
    NSString * strSnapshotURL = [NSString stringWithFormat:@"%@/%@", BLOCKSTORAGEV2_SNAPSHOTS_URN, uidSnapshot];
    [self deleteResource:strSnapshotURL
              withHeader:nil
                  thenDo:^(NSDictionary * _Nullable dicResults, id  _Nullable idFullResponse)
     {
         if( bWaitDeleted )
             [self waitSnapshotWithID:uidSnapshot
                          forStatus:IOStackSnapshotStatusDeleting
                             thenDo:^(bool isWithStatus)
              {
                  if( doAfterDelete != nil )
                      doAfterDelete( isWithStatus, idFullResponse );
              }];
         
         else if( doAfterDelete != nil )
             doAfterDelete( dicResults != nil, idFullResponse );
     }];
}


#pragma mark - Refresh Snapshot status info loop mechanism
- ( void ) waitSnapshotWithID:( NSString * ) uidSnapshot
                    forStatus:( NSString * ) statusSnapshot
                       thenDo:( void ( ^ ) ( bool isWithStatus ) ) doAfterWait
{
    NSString * urlSnapshot = [NSString stringWithFormat:@"%@/%@", BLOCKSTORAGEV2_SNAPSHOTS_URN, uidSnapshot];
    if( [statusSnapshot isEqualToString:IOStackSnapshotStatusDeleting] )
        [self waitResource:urlSnapshot
             withUrlParams:nil
                 insideKey:@"snapshot"
                  forField:nil
              toEqualValue:nil
             orErrorValues:IOStackSnapshotStatusErrorArray
                    thenDo:doAfterWait];
    
    else
        [self waitResource:urlSnapshot
             withUrlParams:nil
                 insideKey:@"snapshot"
                  forField:@"status"
              toEqualValue:statusSnapshot
             orErrorValues:IOStackSnapshotStatusErrorArray
                    thenDo:doAfterWait];
}


#pragma mark - Volume Transfer management
- ( void ) listVolumeTransfersThenDo:( void ( ^ ) ( NSDictionary * dicVolumeTransfers, id idFullResponse ) ) doAfterList
{
    [self listResource:BLOCKSTORAGEV2_VOLUMETRANSFERSDETAIl_URN
            withHeader:nil
          andUrlParams:nil
             insideKey:@"transfers"
                thenDo:^(NSArray * _Nullable arrFound, id _Nullable dataResponse)
     {
         if( doAfterList != nil )
             doAfterList( [IOStackBStorageVolumeTransferV2 parseFromAPIResponse:arrFound], dataResponse );
         
     }];
}

- ( void ) createVolumeTransferForVolumeWithID:( NSString * ) uidVolumeToTransfer
                              withTransferName:( NSString * ) nameVolumeTransfer
                                        thenDo:( void ( ^ ) ( IOStackBStorageVolumeTransferV2 * transferCreated, id dicFullResponse ) ) doAfterCreate
{
    NSMutableDictionary * dicParams = [NSMutableDictionary dictionary];
    
    [dicParams setValue:uidVolumeToTransfer
                 forKey:@"volume_id"];
    
    if( nameVolumeTransfer != nil )
        [dicParams setValue:nameVolumeTransfer
                     forKey:@"name"];
    
    [self createResource:BLOCKSTORAGEV2_VOLUMETRANSFERS_URN
              withHeader:nil
            andUrlParams:@{@"transfer": dicParams }
                  thenDo:^(NSDictionary * _Nullable dicResponseHeaders, id  _Nullable idFullResponse)
     {
         IOStackBStorageVolumeTransferV2 * newVolumeTransfer = [IOStackBStorageVolumeTransferV2 initFromAPIResponse:[idFullResponse objectForKey:@"transfer"]];
         
         if( doAfterCreate != nil )
             doAfterCreate( newVolumeTransfer, idFullResponse );
     }];
}

- ( void ) deleteVolumeTransferWithID:( NSString * ) uidVolumeTransfer
                               thenDo:( void ( ^ ) ( bool isDeleted, id idFullResponse ) ) doAfterDelete
{
    NSString * strVolumeTransferURL = [NSString stringWithFormat:@"%@/%@", BLOCKSTORAGEV2_VOLUMETRANSFERS_URN, uidVolumeTransfer];
    [self deleteResource:strVolumeTransferURL
              withHeader:nil
                  thenDo:^(NSDictionary * _Nullable dicResults, id  _Nullable idFullResponse)
     {
         if( doAfterDelete != nil )
             doAfterDelete( dicResults != nil, idFullResponse );
     }];
}

- ( void ) acceptVolumeTransferForVolumeWithID:( NSString * ) uidVolumeTransfer
                                   withAuthKey:( NSString * ) keyAuthentication
                                        thenDo:( void ( ^ ) ( BOOL isTransferAccepted, id dicFullResponse ) ) doAfterAccept
{
    NSString * strAcceptVolumeTransferURL = [NSString stringWithFormat:@"%@/%@/%@",
                                                                        BLOCKSTORAGEV2_VOLUMETRANSFERS_URN,
                                                                        uidVolumeTransfer,
                                                                        BLOCKSTORAGEV2_VOLUMETRANSFERSACCEPT_URN];
    NSMutableDictionary * dicParams = [NSMutableDictionary dictionary];
    
    [dicParams setValue:keyAuthentication
                 forKey:@"auth_key"];
    
    [self createResource:strAcceptVolumeTransferURL
              withHeader:nil
            andUrlParams:@{@"accept": dicParams }
                  thenDo:^(NSDictionary * _Nullable dicResponseHeaders, id  _Nullable idFullResponse)
     {
         IOStackBStorageVolumeTransferV2 * newVolumeTransfer = [IOStackBStorageVolumeTransferV2 initFromAPIResponse:[idFullResponse objectForKey:@"transfer"]];
         
         if( doAfterAccept != nil )
             doAfterAccept( newVolumeTransfer != nil &&
                                [newVolumeTransfer.uniqueID isEqualToString:uidVolumeTransfer],
                           idFullResponse );
     }];
}


@end
