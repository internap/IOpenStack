//
//  IOpenStack.h
//  IOpenStack
//
//  Created by Bruno Morel on 2015-11-25.
//  Copyright © 2015 Internap Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for IOpenStack.
FOUNDATION_EXPORT double IOpenStackVersionNumber;

//! Project version string for IOpenStack.
FOUNDATION_EXPORT const unsigned char IOpenStackVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <IOpenStack/PublicHeader.h>

#import <IOpenStack/IOStackService.h>
#import <IOpenStack/IOStackObject.h>

#import <IOpenStack/IOStackAuth.h>
#import <IOpenStack/IOStackAuthV2.h>
#import <IOpenStack/IOStackAuthV3.h>
#import <IOpenStack/IOStackAuth_INAP.h>
#import <IOpenStack/IOStackAuth_Dream.h>

#import <IOpenStack/IOStackImageObjectV2.h>
#import <IOpenStack/IOStackImageV2.h>

#import <IOpenStack/IOStackBStorageVolumeV2.h>
#import <IOpenStack/IOStackBStorageBackupV2.h>
#import <IOpenStack/IOStackBStorageSnapshotV2.h>
#import <IOpenStack/IOStackBStorageVolumeTransferV2.h>
#import <IOpenStack/IOStackBlockStorageV2.h>

#import <IOpenStack/IOStackOStorageContainerV1.h>
#import <IOpenStack/IOStackOStorageObjectV1.h>
#import <IOpenStack/IOStackObjectStorageV1.h>

#import <IOpenStack/IOStackComputeFlavorV2_1.h>
#import <IOpenStack/IOStackComputeKeypairV2_1.h>
#import <IOpenStack/IOStackComputeSecurityGroupV2_1.h>
#import <IOpenStack/IOStackComputeSecurityGroupRuleV2_1.h>
#import <IOpenStack/IOStackComputeIPAllocationV2_1.h>
#import <IOpenStack/IOStackComputeNetworkV2_1.h>
#import <IOpenStack/IOStackComputeServerV2_1.h>
#import <IOpenStack/IOStackComputeV2_1.h>


#import <IOpenStack/IOStackNetworkV2.h>