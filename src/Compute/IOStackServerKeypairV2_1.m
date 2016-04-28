//
//  IOStackServerKeypair.m
//  IOpenStack
//
//  Created by Bruno Morel on 2016-02-05.
//  Copyright © 2016 Internap Inc. All rights reserved.
//

#import "IOStackServerKeypairV2_1.h"

@implementation IOStackServerKeypairV2_1


@synthesize fingerprint;
@synthesize name;
@synthesize publicKey;


+ ( NSDictionary * ) parseFromAPIResponse:( NSArray * ) arrAPIResponseData
{
    NSMutableDictionary * parsedKeypairs = [[NSMutableDictionary alloc] init];
    
    for( id currentKeypair in arrAPIResponseData )
    {
        if( ![currentKeypair isKindOfClass:[NSDictionary class]] )
            break;
        
        if( [currentKeypair valueForKey:@"keypair"] == nil ||
            ![[currentKeypair valueForKey:@"keypair"] isKindOfClass:[NSDictionary class]] )
            break;
        
        IOStackServerKeypairV2_1 * keypair = [[IOStackServerKeypairV2_1 alloc] initFromAPIResponse:[currentKeypair valueForKey:@"keypair"]];
        
        [parsedKeypairs setObject:keypair
                           forKey:keypair.uniqueID];
    }
    
    return parsedKeypairs;
}

+ ( id ) initFromAPIResponse:( NSDictionary * ) dicAPIResponse
{
    return [ [self alloc] initFromAPIResponse:dicAPIResponse ];
}


- ( instancetype ) initFromAPIResponse:( NSDictionary * ) dicAPIResponse
{
    if( self = [super init] )
    {
        self.objectType     = IOStackObjectTypeKeypair;
        self.uniqueID       = dicAPIResponse[ @"name" ];
        fingerprint         = dicAPIResponse[ @"fingerprint" ];
        name                = self.uniqueID;
        publicKey           = dicAPIResponse[ @"public_key" ];
        
    }
    return self;
}


@end
