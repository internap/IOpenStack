//
//  IOStackBlockStorageV2.m
//  IOpenStack
//
//  Created by Bruno Morel on 2016-03-29.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import "IOStackBlockStorageV2.h"


#define BLOCKSTORAGEV2_SERVICE_URI                              @"v2/"
#define BLOCKSTORAGEV2_LIMITS_URN                               @"limits"
#define BLOCKSTORAGEV2_VOLUMES_URN                              @"volumes"
#define BLOCKSTORAGEV2_VOLUMESDETAIL_URN                        @"volumes/detail"
#define BLOCKSTORAGEV2_VOLUMEMETADATA_URN                       @"metadata"
#define BLOCKSTORAGEV2_VOLUMETYPES_URN                          @"types"
#define BLOCKSTORAGEV2_VOLUMETYPESACTION_URN                    @"action"
#define BLOCKSTORAGEV2_VOLUMETYPESACCESS_URN                    @"os-volume-type-access"
#define BLOCKSTORAGEV2_VOLUMEACTION_URN                         @"action"
#define BLOCKSTORAGEV2_BACKUPS_URN                              @"backups"
#define BLOCKSTORAGEV2_BACKUPSDETAIl_URN                        @"backups/detail"
#define BLOCKSTORAGEV2_BACKUPSACTION_URN                        @"action"
#define BLOCKSTORAGEV2_BACKUPSRESTORE_URN                       @"restore"
#define BLOCKSTORAGEV2_CAPABILITIES_URN                         @"capabilities"
#define BLOCKSTORAGEV2_QUOTAS_URN                               @"os-quota-sets"
#define BLOCKSTORAGEV2_QUOTASDEFAULTS_URN                       @"defaults"
#define BLOCKSTORAGEV2_QUOTASDETAIL_URN                         @"detail"
#define BLOCKSTORAGEV2_SNAPSHOTS_URN                            @"snapshots"
#define BLOCKSTORAGEV2_SNAPSHOTSDETAIl_URN                      @"snapshots/detail"
#define BLOCKSTORAGEV2_SNAPSHOTSMETADATA_URN                    @"metadata"
#define BLOCKSTORAGEV2_SNAPSHOTSACTION_URN                      @"action"
#define BLOCKSTORAGEV2_BACKENDSTORAGEPOOLS_URN                  @"scheduler-stats/get_pools"
#define BLOCKSTORAGEV2_VOLUMETRANSFERS_URN                      @"os-volume-transfer"
#define BLOCKSTORAGEV2_VOLUMETRANSFERSDETAIl_URN                @"os-volume-transfer/detail"
#define BLOCKSTORAGEV2_VOLUMETRANSFERSACCEPT_URN                @"accept"
#define BLOCKSTORAGEV2_CONSISTENCYGROUPS_URN                    @"consistencygroups"
#define BLOCKSTORAGEV2_CONSISTENCYGROUPSDETAIL_URN              @"consistencygroups/detail"
#define BLOCKSTORAGEV2_CONSISTENCYGROUPSCREATE_URN              @"consistencygroups/create_from_src"
#define BLOCKSTORAGEV2_CONSISTENCYGROUPSUPDATE_URN              @"update"
#define BLOCKSTORAGEV2_CONSISTENCYGROUPSSNAPSHOTS_URN           @"cgsnapshots"
#define BLOCKSTORAGEV2_CONSISTENCYGROUPSSNAPSHOTSDETAIL_URN     @"cgsnapshots/detail"


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

#pragma mark - Limits management
- ( void ) listLimitsThenDo:( void ( ^ ) ( NSDictionary * dicLimits ) ) doAfterList
{
    [self readResource:BLOCKSTORAGEV2_LIMITS_URN
            withHeader:nil
          andUrlParams:nil
             insideKey:@"limits"
                thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable dataResponse)
     {
         if( doAfterList != nil )
             doAfterList( dicObjectFound );
     }];
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
                             thenDo:^( bool isWithStatus, id dicObjectValues )
              {
                  IOStackBStorageVolumeV2 * updatednewVolume = [IOStackBStorageVolumeV2 initFromAPIGETResponse:dicObjectValues];
                  if( isWithStatus )
                      [updatednewVolume setAvailable:YES];
                  
                  if( doAfterCreate != nil )
                  {
                      if( isWithStatus )
                          doAfterCreate( updatednewVolume, idFullResponse );
                      
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

- ( void ) getdetailForVolumeWithID:( NSString * ) uidVolume
                             thenDo:( void ( ^ ) ( IOStackBStorageVolumeV2 * volDetails ) ) doAfterGetDetail
{
    NSString * urlVolume = [NSString stringWithFormat:@"%@/%@", BLOCKSTORAGEV2_VOLUMES_URN, uidVolume];
    
    [self readResource:urlVolume
            withHeader:nil
          andUrlParams:nil
             insideKey:@"volume"
                thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable dataResponse)
     {
         if( doAfterGetDetail != nil )
             doAfterGetDetail( [IOStackBStorageVolumeV2 initFromAPIGETResponse:dicObjectFound] );
     }];
}

- ( void ) updateVolumeWithID:( NSString * ) uidVolume
                      newName:( NSString * ) nameUser
               newDescription:( NSString * ) strDescription
                    newMetadata:( NSDictionary * ) dicMetadata
                       thenDo:( void ( ^ ) ( IOStackBStorageVolumeV2 * updatedUser, id dicFullResponse ) ) doAfterUpdate
{
    NSString * urlVolume = [NSString stringWithFormat:@"%@/%@", BLOCKSTORAGEV2_VOLUMES_URN, uidVolume];
    NSMutableDictionary * mdicVolumeParam = [NSMutableDictionary dictionary];
    
    if( nameUser != nil )
        mdicVolumeParam[ @"name" ] = nameUser;
    
    if( strDescription != nil )
        mdicVolumeParam[ @"description" ] = strDescription;
    
    if( dicMetadata != nil )
        mdicVolumeParam[ @"metadata" ] = dicMetadata;
    
    [self replaceResource:urlVolume
               withHeader:nil
             andUrlParams:@{ @"volume" : mdicVolumeParam }
                   thenDo:^(NSDictionary * _Nullable dicResponseHeader, id  _Nullable idFullResponse)
     {
         NSDictionary * finalVolume = idFullResponse;
         if( idFullResponse != nil )
             finalVolume = idFullResponse[ @"volume" ];
         
         if( doAfterUpdate != nil )
             doAfterUpdate( [IOStackBStorageVolumeV2 initFromAPIGETResponse:finalVolume], idFullResponse );
     }];
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
                            thenDo:^(bool isWithStatus, id dicObjectValues)
             {
                 if( doAfterDelete != nil )
                     doAfterDelete( isWithStatus, idFullResponse );
             }];
        else if( doAfterDelete != nil )
            doAfterDelete( ( idFullResponse == nil ) ||
                          ( idFullResponse[ @"response" ] == nil ) ||
                          ( [idFullResponse[ @"response" ] isEqualToString:@""] ), idFullResponse );
    }];
}


#pragma mark - Refresh Volume status info loop mechanism
- ( void ) waitVolumeWithID:( NSString * ) uidVolume
                  forStatus:( NSString * ) statusVolume
                     thenDo:( void ( ^ ) ( bool isWithStatus, id dicObjectValues ) ) doAfterWait
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

#pragma mark - Volume type management
- ( void ) listVolumeTypesThenDo:( void ( ^ ) ( NSArray * arrVolumeTypes, id idFullResponse ) ) doAfterList
{
    NSString * urlVolumeTypes = [NSString stringWithFormat:@"%@", BLOCKSTORAGEV2_VOLUMETYPES_URN];
    
    [self listResource:urlVolumeTypes
            withHeader:nil
          andUrlParams:nil
             insideKey:@"volume_types"
                thenDo:^(NSArray * _Nullable arrFound, id _Nullable dataResponse)
     {
         if( doAfterList != nil )
             doAfterList( arrFound, dataResponse );
     }];
}

- ( void ) createVolumeTypeWithName:( NSString * ) nameVolumeType
                     andDescription:( NSString * ) strDescription
                      andExtraSpecs:( NSDictionary * ) dicExtraSpecs
                           isPublic:( BOOL ) isPublic
                             thenDo:( void ( ^ ) ( NSDictionary * createdVolumeType, id dicFullResponse ) ) doAfterCreate
{
    NSString * urlVolumeType = [NSString stringWithFormat:@"%@", BLOCKSTORAGEV2_VOLUMETYPES_URN];
    NSMutableDictionary * mdicVolumeTypeParams = [NSMutableDictionary dictionaryWithObject:nameVolumeType
                                                                               forKey:@"name"];
    
    if( strDescription != nil )
        mdicVolumeTypeParams[ @"description" ] = strDescription;
    
    if( dicExtraSpecs != nil )
        mdicVolumeTypeParams[ @"extra_specs" ] = dicExtraSpecs;
    
    mdicVolumeTypeParams[ @"os-volume-type-access:is_public" ] = [NSNumber numberWithBool:isPublic];
    
    [self createResource:urlVolumeType
              withHeader:nil
            andUrlParams:@{ @"volume_type" : mdicVolumeTypeParams }
                  thenDo:^(NSDictionary * _Nullable dicResponseHeaders, id  _Nullable idFullResponse)
     {
         if( doAfterCreate != nil )
             doAfterCreate( idFullResponse, idFullResponse );
     }];
}

- ( void ) getdetailForVolumeTypeWithID:( NSString * ) uidVolumeType
                                 thenDo:( void ( ^ ) ( NSDictionary * dicVolumeType ) ) doAfterGetDetail
{
    NSString * urlVolumeType = [NSString stringWithFormat:@"%@/%@", BLOCKSTORAGEV2_VOLUMETYPES_URN, uidVolumeType];
    
    [self readResource:urlVolumeType
            withHeader:nil
          andUrlParams:nil
                thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable dataResponse)
     {
         if( doAfterGetDetail != nil )
             doAfterGetDetail( dicObjectFound );
     }];
}

- ( void ) updateVolumeTypeWithID:( NSString * ) uidVolumeType
                          newName:( NSString * ) nameVolumeType
                   newDescription:( NSString * ) strDescription
                    newExtraSpecs:( NSDictionary * ) dicExtraSpecs
                         isPublic:( BOOL ) isPublic
                           thenDo:( void ( ^ ) ( NSDictionary * updatedVolumeType, id dicFullResponse ) ) doAfterUpdate
{
    NSString * urlVolumeType = [NSString stringWithFormat:@"%@/%@", BLOCKSTORAGEV2_VOLUMETYPES_URN, uidVolumeType];
    NSMutableDictionary * mdicVolumeTypeParams = [NSMutableDictionary dictionary];
    
    if( nameVolumeType != nil )
        mdicVolumeTypeParams[ @"name" ] = nameVolumeType;
    
    if( strDescription != nil )
        mdicVolumeTypeParams[ @"description" ] = strDescription;
    
    if( dicExtraSpecs != nil )
        mdicVolumeTypeParams[ @"extra_specs" ] = dicExtraSpecs;
    
    mdicVolumeTypeParams[ @"is_public" ] = [NSNumber numberWithBool:isPublic];
    
    [self replaceResource:urlVolumeType
               withHeader:nil
             andUrlParams:@{ @"volume_type" : mdicVolumeTypeParams }
                   thenDo:^(NSDictionary * _Nullable dicResponseHeader, id  _Nullable idFullResponse)
     {
         if( doAfterUpdate != nil )
             doAfterUpdate( idFullResponse, idFullResponse );
     }];
}

- ( void ) deleteVolumeTypeWithID:( NSString * ) uidVolumeType
                           thenDo:( void ( ^ ) ( bool isDeleted, id idFullResponse ) ) doAfterDelete
{
    NSString * urlVolumeType = [NSString stringWithFormat:@"%@/%@", BLOCKSTORAGEV2_VOLUMETYPES_URN, uidVolumeType];
    
    [self deleteResource:urlVolumeType
              withHeader:nil
                  thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable idFullResponse)
     {
         if( doAfterDelete != nil )
             doAfterDelete( ( idFullResponse == nil ) ||
                           ( idFullResponse[ @"response" ] == nil ) ||
                           ( [idFullResponse[ @"response" ] isEqualToString:@""] ), idFullResponse );
     }];
}

- ( void ) listProjectWithAccessToVolumeTypeWithID:( NSString * ) uidVolumeType
                                            thenDo:( void ( ^ ) ( NSDictionary * dicMetadata, id idFullResponse ) ) doAfterList
{
    NSString * urlVolumeTypeAccess = [NSString stringWithFormat:@"%@/%@/%@", BLOCKSTORAGEV2_VOLUMETYPES_URN, uidVolumeType, BLOCKSTORAGEV2_VOLUMETYPESACCESS_URN ];
    
    [self readResource:urlVolumeTypeAccess
            withHeader:nil
          andUrlParams:nil
             insideKey:@"volume_type_access"
                thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable dataResponse)
     {
         if( doAfterList != nil )
             doAfterList( dicObjectFound, dataResponse );
     }];
}

- ( void ) createAccessToVolumeTypeWithID:( NSString * ) uidVolumeType
                             forProjectID:( NSString * ) uidProjectOrTenant
                                   thenDo:( void ( ^ ) ( BOOL isCreated, id dicFullResponse ) ) doAfterCreate
{
    NSString * urlVolumeTypeAccess = [NSString stringWithFormat:@"%@/%@/%@", BLOCKSTORAGEV2_VOLUMETYPES_URN, uidVolumeType, BLOCKSTORAGEV2_VOLUMETYPESACTION_URN ];
    
    [self createResource:urlVolumeTypeAccess
              withHeader:nil
            andUrlParams:@{ @"addProjectAccess" : @{ @"project" : uidProjectOrTenant} }
                  thenDo:^(NSDictionary * _Nullable dicResults, id _Nullable idFullResponse)
    {
        if( doAfterCreate != nil )
            doAfterCreate( ( idFullResponse == nil ) ||
                          ( idFullResponse[ @"response" ] == nil ) ||
                          ( [idFullResponse[ @"response" ] isEqualToString:@""] ), idFullResponse );
    }];
}

- ( void ) deleteAccessToVolumeTypeWithID:( NSString * ) uidVolumeType
                             forProjectID:( NSString * ) uidProjectOrTenant
                                   thenDo:( void ( ^ ) ( BOOL isCreated, id dicFullResponse ) ) doAfterCreate
{
    NSString * urlVolumeTypeAccess = [NSString stringWithFormat:@"%@/%@/%@", BLOCKSTORAGEV2_VOLUMETYPES_URN, uidVolumeType, BLOCKSTORAGEV2_VOLUMETYPESACTION_URN ];
    
    [self createResource:urlVolumeTypeAccess
              withHeader:nil
            andUrlParams:@{ @"removeProjectAccess" : @{ @"project" : uidProjectOrTenant} }
                  thenDo:^(NSDictionary * _Nullable dicResults, id _Nullable idFullResponse)
     {
         if( doAfterCreate != nil )
             doAfterCreate( ( idFullResponse == nil ) ||
                           ( idFullResponse[ @"response" ] == nil ) ||
                           ( [idFullResponse[ @"response" ] isEqualToString:@""] ), idFullResponse );
     }];
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
                            thenDo:^(bool isWithStatus, id dicObjectValues )
             {
                 if( doAfterUpdate != nil )
                     doAfterUpdate( isWithStatus, dicObjectValues );
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
                            thenDo:^( bool isWithStatus, id dicObjectValues )
             {
                 IOStackBStorageBackupV2 * updatedBackup = [IOStackBStorageBackupV2 initFromAPIGETResponse:dicObjectValues];
                 if( isWithStatus )
                     [updatedBackup setAvailable:YES];
                 
                 if( doAfterCreate != nil )
                 {
                     if( isWithStatus )
                         doAfterCreate( updatedBackup, idFullResponse );
                     
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
                            thenDo:^(bool isWithStatus, id dicObjectValues )
             {
                 if( doAfterDelete != nil )
                     doAfterDelete( isWithStatus, dicObjectValues );
             }];
        
        else if( doAfterDelete != nil )
            doAfterDelete( ( idFullResponse == nil ) ||
                          ( idFullResponse[ @"response" ] == nil ) ||
                          ( [idFullResponse[ @"response" ] isEqualToString:@""] ), idFullResponse );
    }];
}

- ( void ) restoreBackupWithID:( NSString * ) uidBackup
                ofVolumeWithID:( NSString * ) uidVolume
                        orName:( NSString * ) nameVolume
          waitUntilIsAvailable:( BOOL ) bWaitAvailable
                        thenDo:( void ( ^ ) ( IOStackBStorageVolumeV2 * volumeRestored ) ) doAfterCreate
{
    NSString * urlBackupRestore = [NSString stringWithFormat:@"%@/%@/%@", BLOCKSTORAGEV2_BACKUPS_URN, uidBackup, BLOCKSTORAGEV2_BACKUPSRESTORE_URN];
    NSMutableDictionary * mdicParams = [NSMutableDictionary dictionary];
    
    if( uidVolume != nil )
        [mdicParams setValue:uidVolume forKey:@"volume_id"];

    if( nameVolume != nil )
        [mdicParams setValue:nameVolume forKey:@"name"];
    
    [self createResource:urlBackupRestore
              withHeader:nil
            andUrlParams:@{ @"restore" : mdicParams }
                  thenDo:^(NSDictionary * _Nullable dicResponseHeaders, id  _Nullable idFullResponse)
     {
         NSString * uidRestoredVolumeID = nil;
         if( idFullResponse != nil &&
            idFullResponse[ @"restore" ] != nil &&
            idFullResponse[ @"restore" ][ @"volume_id" ] )
             uidRestoredVolumeID = idFullResponse[ @"restore" ][ @"volume_id" ];
         
         if( bWaitAvailable )
             [self waitVolumeWithID:uidRestoredVolumeID
                          forStatus:IOStackVolumeStatusAvailable
                             thenDo:^(bool isWithStatus, id dicObjectValues )
              {
                  IOStackBStorageVolumeV2 * restoredVolume = [IOStackBStorageVolumeV2 initFromAPIGETResponse:dicObjectValues];
                  if( isWithStatus &&
                        doAfterCreate != nil )
                      doAfterCreate( restoredVolume );
              }];
         
         else
             [self getdetailForVolumeWithID:uidRestoredVolumeID
                                     thenDo:^(IOStackBStorageVolumeV2 * volDetails)
             {
                 if( doAfterCreate )
                     doAfterCreate( volDetails );
             }];
     }];
}

- ( void ) forcedeleteBackupWithID:( NSString * ) uidBackup
                            thenDo:( void ( ^ ) ( BOOL isForceDeleted ) ) doAfterForceDelete
{
    NSString * urlBackupRestore = [NSString stringWithFormat:@"%@/%@/%@", BLOCKSTORAGEV2_BACKUPS_URN, uidBackup, BLOCKSTORAGEV2_BACKUPSACTION_URN];
    
    [self createResource:urlBackupRestore
              withHeader:nil
            andUrlParams:@{ @"os-force_delete" : [NSNull null] }
                  thenDo:^(NSDictionary * _Nullable dicResponseHeaders, id  _Nullable idFullResponse)
     {
            if( doAfterForceDelete != nil )
                doAfterForceDelete( ( idFullResponse == nil ) ||
                                   ( idFullResponse[ @"response" ] == nil ) ||
                                   ( [idFullResponse[ @"response" ] isEqualToString:@""] ) );
     }];
}

#pragma mark - Refresh Backup status info loop mechanism
- ( void ) waitBackupWithID:( NSString * ) uidBackup
                  forStatus:( NSString * ) statusBackup
                     thenDo:( void ( ^ ) ( bool isWithStatus, id dicObjectValues ) ) doAfterWait
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
- ( void ) listCapabilitiesForStorageWithHost:( NSString * ) nameHost
                                       thenDo:( void ( ^ ) ( NSDictionary * dicCapabilities ) ) doAfterList
{
    NSString * urlStorageHost = [NSString stringWithFormat:@"%@/%@", BLOCKSTORAGEV2_CAPABILITIES_URN, nameHost];
    
    [self readResource:urlStorageHost
            withHeader:nil
          andUrlParams:nil
                thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable dataResponse)
    {
        if( doAfterList != nil )
            doAfterList( dicObjectFound );
    }];
}


#pragma mark - Quota sets management
- ( void ) listQuotasForProjectOrTenantWithID:( NSString * ) uidProjectOrTenant
                                       thenDo:( void ( ^ ) ( NSDictionary * dicQuotas ) ) doAfterList
{
    NSString * urlProjectOrTenantQuotas =[NSString stringWithFormat:@"%@/%@", BLOCKSTORAGEV2_QUOTAS_URN, uidProjectOrTenant];
    [self readResource:urlProjectOrTenantQuotas
            withHeader:nil
          andUrlParams:nil
             insideKey:@"quota_set"
                thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable dataResponse)
     {
         if( doAfterList != nil )
             doAfterList( dicObjectFound );
     }];
}

- ( void ) updateQuotaForProjectOrTenantWithID:( NSString * ) uidProjectOrTenant
                             newTotalSizeQuota:( NSNumber * ) numMaxTotalGBytes
                               newVolumesQuota:( NSNumber * ) numMaxVolumes
                             newPerVolumeQuota:( NSNumber * ) numMaxPerVolumeGBytes
                                newBackupQuota:( NSNumber * ) numMaxBackups
                       newBackupTotalSizeQuota:( NSNumber * ) numMaxBackupTotalSizeGBytes
                              newSnapshotQuota:( NSNumber * ) numMaxSnapshots
                                        thenDo:( void ( ^ ) ( NSDictionary * updatedQuota ) ) doAfterUpdate
{
    NSString * urlProjectOrTenantQuotas =[NSString stringWithFormat:@"%@/%@", BLOCKSTORAGEV2_QUOTAS_URN, uidProjectOrTenant];
    NSMutableDictionary * mdicQuotaParam = [NSMutableDictionary dictionary];

    if( numMaxTotalGBytes != nil )
        mdicQuotaParam[ @"gigabytes" ] = numMaxTotalGBytes;
    
    if( numMaxVolumes != nil )
        mdicQuotaParam[ @"volumes" ] = numMaxVolumes;
    
    if( numMaxPerVolumeGBytes != nil )
        mdicQuotaParam[ @"per_volume_gigabytes" ] = numMaxPerVolumeGBytes;
    
    if( numMaxBackups != nil )
        mdicQuotaParam[ @"backups" ] = numMaxBackups;
    
    if( numMaxBackupTotalSizeGBytes != nil )
        mdicQuotaParam[ @"backup_gigabytes" ] = numMaxBackupTotalSizeGBytes;
    
    if( numMaxSnapshots != nil )
        mdicQuotaParam[ @"snapshots" ] = numMaxSnapshots;
    
    [self replaceResource:urlProjectOrTenantQuotas
               withHeader:nil
             andUrlParams:@{ @"quota_set" : mdicQuotaParam }
                   thenDo:^(NSDictionary * _Nullable dicResponseHeader, id  _Nullable idFullResponse)
     {
         NSDictionary * finalQuota = idFullResponse;
         if( idFullResponse != nil )
             finalQuota = idFullResponse[ @"quota_set" ];
         
         if( doAfterUpdate != nil )
             doAfterUpdate( finalQuota );
     }];
}

- ( void ) deleteQuotaForProjectOrTenantWithID:( NSString * ) uidProjectOrTenant
                                        thenDo:( void ( ^ ) ( bool isDeleted, id idFullResponse ) ) doAfterDelete
{
    NSString * urlProjectOrTenantQuotas =[NSString stringWithFormat:@"%@/%@", BLOCKSTORAGEV2_QUOTAS_URN, uidProjectOrTenant];
    [self deleteResource:urlProjectOrTenantQuotas
              withHeader:nil
                  thenDo:^(NSDictionary * _Nullable dicResults, id  _Nullable idFullResponse)
     {
         if( doAfterDelete != nil )
             doAfterDelete( ( idFullResponse == nil ) ||
                           ( idFullResponse[ @"response" ] == nil ) ||
                           ( [idFullResponse[ @"response" ] isEqualToString:@""] ), idFullResponse );
     }];
}

- ( void ) getdetailDefaultQuotasThenDo:( void ( ^ ) ( NSDictionary * dicQuota ) ) doAfterGetDetail
{
    NSString * urlProjectOrTenantQuotaDefaults =[NSString stringWithFormat:@"%@/%@", BLOCKSTORAGEV2_QUOTAS_URN, BLOCKSTORAGEV2_QUOTASDEFAULTS_URN];
    
    [self readResource:urlProjectOrTenantQuotaDefaults
            withHeader:nil
          andUrlParams:nil
                thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable dataResponse)
     {
         NSDictionary * finalQuota = dataResponse;
         if( dataResponse != nil )
             finalQuota = dataResponse[ @"quota_set" ];
         
         if( doAfterGetDetail != nil )
             doAfterGetDetail( finalQuota );
     }];
}

- ( void ) listQuotasForUserWithID:( NSString * ) uidUser
          andProjectOrTenantWithID:( NSString * ) uidProjectOrTenant
                                       thenDo:( void ( ^ ) ( NSDictionary * dicQuotas ) ) doAfterList
{
    NSString * urlUserQuotas =[NSString stringWithFormat:@"%@/%@/%@", BLOCKSTORAGEV2_QUOTAS_URN, uidProjectOrTenant, uidUser];
    [self readResource:urlUserQuotas
            withHeader:nil
          andUrlParams:nil
             insideKey:@"quota_set"
                thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable dataResponse)
     {
         if( doAfterList != nil )
             doAfterList( dicObjectFound );
     }];
}

- ( void ) updateQuotaForUserWithID:( NSString * ) uidUser
           andProjectOrTenantWithID:( NSString * ) uidProjectOrTenant
                  newTotalSizeQuota:( NSNumber * ) numMaxTotalGBytes
                    newVolumesQuota:( NSNumber * ) numMaxVolumes
                  newPerVolumeQuota:( NSNumber * ) numMaxPerVolumeGBytes
                     newBackupQuota:( NSNumber * ) numMaxBackups
            newBackupTotalSizeQuota:( NSNumber * ) numMaxBackupTotalSizeGBytes
                   newSnapshotQuota:( NSNumber * ) numMaxSnapshots
                             thenDo:( void ( ^ ) ( NSDictionary * updatedQuota ) ) doAfterUpdate
{
    NSString * urlUserQuotas =[NSString stringWithFormat:@"%@/%@/%@", BLOCKSTORAGEV2_QUOTAS_URN, uidProjectOrTenant, uidUser];
    NSMutableDictionary * mdicQuotaParam = [NSMutableDictionary dictionary];
    
    if( numMaxTotalGBytes != nil )
        mdicQuotaParam[ @"gigabytes" ] = numMaxTotalGBytes;
    
    if( numMaxVolumes != nil )
        mdicQuotaParam[ @"volumes" ] = numMaxVolumes;
    
    if( numMaxPerVolumeGBytes != nil )
        mdicQuotaParam[ @"per_volume_gigabytes" ] = numMaxPerVolumeGBytes;
    
    if( numMaxBackups != nil )
        mdicQuotaParam[ @"backups" ] = numMaxBackups;
    
    if( numMaxBackupTotalSizeGBytes != nil )
        mdicQuotaParam[ @"backup_gigabytes" ] = numMaxBackupTotalSizeGBytes;
    
    if( numMaxSnapshots != nil )
        mdicQuotaParam[ @"snapshots" ] = numMaxSnapshots;
    
    [self replaceResource:urlUserQuotas
               withHeader:nil
             andUrlParams:@{ @"quota_set" : mdicQuotaParam }
                   thenDo:^(NSDictionary * _Nullable dicResponseHeader, id  _Nullable idFullResponse)
     {
         NSDictionary * finalQuota = idFullResponse;
         if( idFullResponse != nil )
             finalQuota = idFullResponse[ @"quota_set" ];
         
         if( doAfterUpdate != nil )
             doAfterUpdate( finalQuota );
     }];
}

- ( void ) deleteQuotaForUserWithID:( NSString * ) uidUser
           andProjectOrTenantWithID:( NSString * ) uidProjectOrTenant
                             thenDo:( void ( ^ ) ( bool isDeleted, id idFullResponse ) ) doAfterDelete
{
    NSString * urlUserQuotas =[NSString stringWithFormat:@"%@/%@/%@", BLOCKSTORAGEV2_QUOTAS_URN, uidProjectOrTenant, uidUser];
    [self deleteResource:urlUserQuotas
              withHeader:nil
                  thenDo:^(NSDictionary * _Nullable dicResults, id  _Nullable idFullResponse)
     {
         if( doAfterDelete != nil )
             doAfterDelete( ( idFullResponse == nil ) ||
                           ( idFullResponse[ @"response" ] == nil ) ||
                           ( [idFullResponse[ @"response" ] isEqualToString:@""] ), idFullResponse );
     }];
}

- ( void ) getdetailQuotasForUserWithID:( NSString * ) uidUser
               andProjectOrTenantWithID:( NSString * ) uidProjectOrTenant
                                 thenDo:( void ( ^ ) ( NSDictionary * dicQuota ) ) doAfterGetDetail
{
    NSString * urlUserQuotasDetail =[NSString stringWithFormat:@"%@/%@/%@/%@", BLOCKSTORAGEV2_QUOTAS_URN, uidProjectOrTenant, BLOCKSTORAGEV2_QUOTASDETAIL_URN, uidUser];
    
    [self readResource:urlUserQuotasDetail
            withHeader:nil
          andUrlParams:nil
                thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable dataResponse)
     {
         if( doAfterGetDetail != nil )
             doAfterGetDetail( dicObjectFound );
     }];
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
                             thenDo:^( bool isWithStatus, id dicObjectValues )
              {
                  IOStackBStorageSnapshotV2 * updatedSnapshot = [IOStackBStorageSnapshotV2 initFromAPIGETResponse:dicObjectValues];
                  if( isWithStatus )
                      [updatedSnapshot setAvailable:YES];
                  
                  if( doAfterCreate != nil )
                  {
                      if( isWithStatus )
                          doAfterCreate( updatedSnapshot, idFullResponse );
                      
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

- ( void ) getdetailForSnapshotWithID:( NSString * ) uidSnapshot
                               thenDo:( void ( ^ ) ( NSDictionary * dicSnapshot ) ) doAfterGetDetail
{
    NSString * urlSnapshot =[NSString stringWithFormat:@"%@/%@", BLOCKSTORAGEV2_SNAPSHOTS_URN, uidSnapshot];
    
    [self readResource:urlSnapshot
            withHeader:nil
          andUrlParams:nil
             insideKey:@"snapshot"
                thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable dataResponse)
     {
         if( doAfterGetDetail != nil )
             doAfterGetDetail( dicObjectFound );
     }];
}

- ( void ) updateQuotaForSnapshotWithID:( NSString * ) uidSnapshot
                                newName:( NSString * ) nameSnapshot
                         newDescription:( NSString * ) strDescription
                                 thenDo:( void ( ^ ) ( NSDictionary * updatedSnapshot ) ) doAfterUpdate
{
    NSString * urlSnapshot=[NSString stringWithFormat:@"%@/%@", BLOCKSTORAGEV2_SNAPSHOTS_URN, uidSnapshot];
    NSMutableDictionary * mdicSnapshotParam = [NSMutableDictionary dictionary];
    
    if( nameSnapshot != nil )
        mdicSnapshotParam[ @"name" ] = nameSnapshot;
    
    if( strDescription != nil )
        mdicSnapshotParam[ @"description" ] = strDescription;
    
    [self replaceResource:urlSnapshot
               withHeader:nil
             andUrlParams:@{ @"snapshot" : mdicSnapshotParam }
                   thenDo:^(NSDictionary * _Nullable dicResponseHeader, id  _Nullable idFullResponse)
     {
         NSDictionary * finalQuota = idFullResponse;
         if( idFullResponse != nil )
             finalQuota = idFullResponse[ @"snapshot" ];
         
         if( doAfterUpdate != nil )
             doAfterUpdate( finalQuota );
     }];
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
                             thenDo:^(bool isWithStatus, id dicObjectValues)
              {
                  if( doAfterDelete != nil )
                      doAfterDelete( isWithStatus, dicObjectValues );
              }];
         
         else if( doAfterDelete != nil )
             doAfterDelete( ( idFullResponse == nil ) ||
                           ( idFullResponse[ @"response" ] == nil ) ||
                           ( [idFullResponse[ @"response" ] isEqualToString:@""] ), idFullResponse );
     }];
}

- ( void ) listMetadataForSnapshotWithID:( NSString * ) uidSnapshot
                                  thenDo:( void ( ^ ) ( NSDictionary * dicSnapshot ) ) doAfterGetDetail
{
    NSString * urlSnapshotMetadata =[NSString stringWithFormat:@"%@/%@/%@", BLOCKSTORAGEV2_SNAPSHOTS_URN, uidSnapshot, BLOCKSTORAGEV2_SNAPSHOTSMETADATA_URN];
    
    [self readResource:urlSnapshotMetadata
            withHeader:nil
          andUrlParams:nil
             insideKey:@"metadata"
                thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable dataResponse)
     {
         if( doAfterGetDetail != nil )
             doAfterGetDetail( dicObjectFound );
     }];
}

- ( void ) updateMetadataForSnapshotWithID:( NSString * ) uidSnapshot
                               andMetadata:( NSDictionary * ) dicMetadata
                                    thenDo:( void ( ^ ) ( BOOL isUpdated ) ) doAfterUpdate
{
    NSString * urlSnapshotMetadata =[NSString stringWithFormat:@"%@/%@/%@", BLOCKSTORAGEV2_SNAPSHOTS_URN, uidSnapshot, BLOCKSTORAGEV2_SNAPSHOTSMETADATA_URN];
    
    [self replaceResource:urlSnapshotMetadata
               withHeader:nil
             andUrlParams:nil
                   thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable dataResponse)
     {
         if( doAfterUpdate != nil )
             doAfterUpdate( dicObjectFound != nil );
     }];
}


#pragma mark - Refresh Snapshot status info loop mechanism
- ( void ) waitSnapshotWithID:( NSString * ) uidSnapshot
                    forStatus:( NSString * ) statusSnapshot
                       thenDo:( void ( ^ ) ( bool isWithStatus, id dicObjectValues ) ) doAfterWait
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


#pragma mark - Back end storage pool management
- ( void ) listStoragePoolsThenDo:( void ( ^ ) ( NSArray * arrStoragePools ) ) doAfterList
{
    NSString * urlStoragePools =[NSString stringWithFormat:@"%@", BLOCKSTORAGEV2_BACKENDSTORAGEPOOLS_URN];
    
    [self listResource:urlStoragePools
            withHeader:nil
          andUrlParams:nil
             insideKey:@"pools"
                thenDo:^(NSArray * arrFound, id dataResponse)
     {
         if( doAfterList != nil )
             doAfterList( arrFound );
     }];
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
             doAfterDelete( ( idFullResponse == nil ) ||
                           ( idFullResponse[ @"response" ] == nil ) ||
                           ( [idFullResponse[ @"response" ] isEqualToString:@""] ), idFullResponse );
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


#pragma mark - Consistency groups management
- ( void ) listConsistencyGroupsThenDo:( void ( ^ ) ( NSArray * arrConsistencyGroups, id idFullResponse ) ) doAfterList
{
    NSString * urlConsistencyGroups = [NSString stringWithFormat:@"%@", BLOCKSTORAGEV2_CONSISTENCYGROUPSDETAIL_URN];
    
    [self listResource:urlConsistencyGroups
            withHeader:nil
          andUrlParams:nil
             insideKey:@"consistencygroups"
                thenDo:^(NSArray * _Nullable arrFound, id _Nullable dataResponse)
     {
         if( doAfterList != nil )
             doAfterList( arrFound, dataResponse );
     }];
}

- ( void ) createConsistencyGroupWithName:( NSString * ) nameConsistencyGroup
                           andDescription:( NSString * ) strDescription
                           andVolumeTypes:( NSArray<NSString *> * ) arrVolumeTypes
                                forUserID:( NSString * ) uidUser
                             andProjectID:( NSString * ) uidProject
                                andStatus:( NSString * ) statusConsistencyGroup
                       inAvailabilityZone:( NSString * ) strAvailabilityZone
                                   thenDo:( void ( ^ ) ( NSDictionary * createdConsistencyGroup, id dicFullResponse ) ) doAfterCreate
{
    NSString * urlConsistencyGroup = [NSString stringWithFormat:@"%@", BLOCKSTORAGEV2_CONSISTENCYGROUPS_URN];
    NSMutableDictionary * mdicCgroupParam = [NSMutableDictionary dictionaryWithObject:nameConsistencyGroup
                                                                                 forKey:@"name"];
    
    if( strDescription != nil )
        mdicCgroupParam[ @"description" ] = strDescription;
    
    if( arrVolumeTypes != nil )
        mdicCgroupParam[ @"volume_types" ] = arrVolumeTypes;
    
    if( uidUser != nil )
        mdicCgroupParam[ @"user_id" ] = uidUser;
    
    if( uidProject != nil )
        mdicCgroupParam[ @"project_id" ] = uidProject;
    
    if( statusConsistencyGroup != nil )
        mdicCgroupParam[ @"status" ] = statusConsistencyGroup;
    
    if( strAvailabilityZone != nil )
        mdicCgroupParam[ @"availability_zone" ] = strAvailabilityZone;
    
    [self createResource:urlConsistencyGroup
              withHeader:nil
            andUrlParams:@{ @"consistencygroup" : mdicCgroupParam }
                  thenDo:^(NSDictionary * _Nullable dicResponseHeaders, id  _Nullable idFullResponse)
     {
         if( doAfterCreate != nil )
             doAfterCreate( idFullResponse, idFullResponse );
     }];
}

- ( void ) createConsistencyGroupWithName:( NSString * ) nameConsistencyGroup
                           andDescription:( NSString * ) strDescription
                     fromConsistencyGroup:( NSString * ) uidConsistencyGroupFrom
                            andCGSnapshot:( NSString * ) uidConsistencyGroupSnapFrom
                                forUserID:( NSString * ) uidUser
                             andProjectID:( NSString * ) uidProject
                                andStatus:( NSString * ) statusConsistencyGroup
                                   thenDo:( void ( ^ ) ( NSDictionary * createdConsistencyGroup, id dicFullResponse ) ) doAfterCreate
{
    NSString * urlConsistencyGroup = [NSString stringWithFormat:@"%@", BLOCKSTORAGEV2_CONSISTENCYGROUPSCREATE_URN];
    NSMutableDictionary * mdicCgroupParam = [NSMutableDictionary dictionaryWithObject:nameConsistencyGroup
                                                                               forKey:@"name"];
    
    if( strDescription != nil )
        mdicCgroupParam[ @"description" ] = strDescription;
    
    if( uidConsistencyGroupFrom != nil )
        mdicCgroupParam[ @"source_cgid" ] = uidConsistencyGroupFrom;
    
    if( uidConsistencyGroupSnapFrom != nil )
        mdicCgroupParam[ @"cgsnapshot_id" ] = uidConsistencyGroupSnapFrom;
    
    if( uidUser != nil )
        mdicCgroupParam[ @"user_id" ] = uidUser;
    
    if( uidProject != nil )
        mdicCgroupParam[ @"project_id" ] = uidProject;
    
    if( statusConsistencyGroup != nil )
        mdicCgroupParam[ @"status" ] = statusConsistencyGroup;
    
    [self createResource:urlConsistencyGroup
              withHeader:nil
            andUrlParams:@{ @"consistencygroup" : mdicCgroupParam }
                  thenDo:^(NSDictionary * _Nullable dicResponseHeaders, id  _Nullable idFullResponse)
     {
         if( doAfterCreate != nil )
             doAfterCreate( idFullResponse, idFullResponse );
     }];
}

- ( void ) getdetailForConsistencyGroupWithID:( NSString * ) uidConsistencyGroup
                                       thenDo:( void ( ^ ) ( NSDictionary * dicConsistencyGroup ) ) doAfterGetDetail
{
    NSString * urlConsistencyGroup = [NSString stringWithFormat:@"%@/%@", BLOCKSTORAGEV2_CONSISTENCYGROUPS_URN, uidConsistencyGroup];
    
    [self readResource:urlConsistencyGroup
            withHeader:nil
          andUrlParams:nil
                thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable dataResponse)
     {
         if( doAfterGetDetail != nil )
             doAfterGetDetail( dicObjectFound );
     }];
}

- ( void ) updateConsistencyGroupWithID:( NSString * ) uidConsistencyGroup
                                newName:( NSString * ) nameConsistencyGroup
                         newDescription:( NSString * ) strDescription
                             addVolumes:( NSArray<NSString *> * ) arrVolumeIDsToAdd
                          removeVolumes:( NSArray<NSString *> * ) arrVolumeIDsToRemove
                                 thenDo:( void ( ^ ) ( NSDictionary * updatedConsistencyGroup, id dicFullResponse ) ) doAfterUpdate
{
    NSString * urlConsistencyGroup = [NSString stringWithFormat:@"%@/%@/%@", BLOCKSTORAGEV2_CONSISTENCYGROUPS_URN, uidConsistencyGroup, BLOCKSTORAGEV2_CONSISTENCYGROUPSUPDATE_URN];
    NSMutableDictionary * mdicCgroupParam = [NSMutableDictionary dictionary];
    
    if( nameConsistencyGroup != nil )
        mdicCgroupParam[ @"name" ] = nameConsistencyGroup;
    
    if( strDescription != nil )
        mdicCgroupParam[ @"description" ] = strDescription;
    
    if( arrVolumeIDsToAdd != nil )
        mdicCgroupParam[ @"add_volumes" ] = arrVolumeIDsToAdd;
    
    if( arrVolumeIDsToRemove != nil )
        mdicCgroupParam[ @"remove_volumes" ] = arrVolumeIDsToRemove;
    
    [self replaceResource:urlConsistencyGroup
               withHeader:nil
             andUrlParams:@{ @"consistencygroup" : mdicCgroupParam }
                   thenDo:^(NSDictionary * _Nullable dicResponseHeader, id  _Nullable idFullResponse)
     {
         if( doAfterUpdate != nil )
             doAfterUpdate( idFullResponse, idFullResponse );
     }];
}

- ( void ) deleteConsistencyGroupWithID:( NSString * ) uidConsistencyGroup
                                 thenDo:( void ( ^ ) ( bool isDeleted, id idFullResponse ) ) doAfterDelete
{
    NSString * urlConsistencyGroup = [NSString stringWithFormat:@"%@/%@", BLOCKSTORAGEV2_CONSISTENCYGROUPS_URN, uidConsistencyGroup];
    
    [self deleteResource:urlConsistencyGroup
              withHeader:nil
                  thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable idFullResponse)
     {
         if( doAfterDelete != nil )
             doAfterDelete( ( idFullResponse == nil ) ||
                           ( idFullResponse[ @"response" ] == nil ) ||
                           ( [idFullResponse[ @"response" ] isEqualToString:@""] ), idFullResponse );
     }];
}


#pragma mark - Consistency groups snapshots management
- ( void ) listConsistencyGroupsSnapshotsThenDo:( void ( ^ ) ( NSArray * arrConsistencyGroups, id idFullResponse ) ) doAfterList
{
    NSString * urlcGSnapshots = [NSString stringWithFormat:@"%@", BLOCKSTORAGEV2_CONSISTENCYGROUPSSNAPSHOTSDETAIL_URN];
    
    [self listResource:urlcGSnapshots
            withHeader:nil
          andUrlParams:nil
             insideKey:@"cgsnapshots"
                thenDo:^(NSArray * _Nullable arrFound, id _Nullable dataResponse)
     {
         if( doAfterList != nil )
             doAfterList( arrFound, dataResponse );
     }];
}

- ( void ) createConsistencyGroupSnapshotWithCGroupID:( NSString * ) uidConsistencyGroup
                                              andName:( NSString * ) nameConsistencyGroup
                                       andDescription:( NSString * ) strDescription
                                            forUserID:( NSString * ) uidUser
                                         andProjectID:( NSString * ) uidProject
                                            andStatus:( NSString * ) statusConsistencyGroupSnapshot
                                               thenDo:( void ( ^ ) ( NSDictionary * createdConsistencyGroupSnapshot, id dicFullResponse ) ) doAfterCreate
{
    NSString * urlcGSnapshot = [NSString stringWithFormat:@"%@", BLOCKSTORAGEV2_CONSISTENCYGROUPSSNAPSHOTS_URN];
    NSMutableDictionary * mdicCgroupParam = [NSMutableDictionary dictionaryWithObject:uidConsistencyGroup
                                                                               forKey:@"consistencygroup_id"];
    
    if( nameConsistencyGroup != nil )
        mdicCgroupParam[ @"name" ] = nameConsistencyGroup;
    
    if( strDescription != nil )
        mdicCgroupParam[ @"description" ] = strDescription;
    
    if( uidUser != nil )
        mdicCgroupParam[ @"user_id" ] = uidUser;
    
    if( uidProject != nil )
        mdicCgroupParam[ @"project_id" ] = uidProject;
    
    if( statusConsistencyGroupSnapshot != nil )
        mdicCgroupParam[ @"status" ] = statusConsistencyGroupSnapshot;
    
    [self createResource:urlcGSnapshot
              withHeader:nil
            andUrlParams:@{ @"cgsnapshot" : mdicCgroupParam }
                  thenDo:^(NSDictionary * _Nullable dicResponseHeaders, id  _Nullable idFullResponse)
     {
         if( doAfterCreate != nil )
             doAfterCreate( idFullResponse, idFullResponse );
     }];
}


- ( void ) getdetailForConsistencyGroupSnapshotWithID:( NSString * ) uidConsistencyGroupSnapshot
                                               thenDo:( void ( ^ ) ( NSDictionary * dicConsistencyGroup ) ) doAfterGetDetail
{
    NSString * urlcGSnapshot = [NSString stringWithFormat:@"%@/%@", BLOCKSTORAGEV2_CONSISTENCYGROUPSSNAPSHOTS_URN, uidConsistencyGroupSnapshot];
    
    [self readResource:urlcGSnapshot
            withHeader:nil
          andUrlParams:nil
                thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable dataResponse)
     {
         if( doAfterGetDetail != nil )
             doAfterGetDetail( dicObjectFound );
     }];
}

- ( void ) deleteConsistencyGroupSnapshotWithID:( NSString * ) uidConsistencyGroupSnapshot
                                         thenDo:( void ( ^ ) ( bool isDeleted, id idFullResponse ) ) doAfterDelete
{
    NSString * urlcGSnapshot = [NSString stringWithFormat:@"%@/%@", BLOCKSTORAGEV2_CONSISTENCYGROUPSSNAPSHOTS_URN, uidConsistencyGroupSnapshot];
    
    [self deleteResource:urlcGSnapshot
              withHeader:nil
                  thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable idFullResponse)
     {
         if( doAfterDelete != nil )
             doAfterDelete( ( idFullResponse == nil ) ||
                           ( idFullResponse[ @"response" ] == nil ) ||
                           ( [idFullResponse[ @"response" ] isEqualToString:@""] ), idFullResponse );
     }];
}


@end
