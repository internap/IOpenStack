//
//  IOStackAuth.m
//  IOpenStack
//
//  Created by Bruno Morel on 2015-11-26.
//  Copyright © 2015 Internap Inc. All rights reserved.
//

#import "IOStackAuthV2.h"


#define IDENTITYV2_TOKEN_URI              @"v2.0/tokens"
#define IDENTITYV2_TENANT_URN             @"v2.0/tenants"
#define IDENTITYV2_EXTENSION_URN          @"v2.0/extensions"


@implementation IOStackAuthV2

//IOStackIdentity protocol
@synthesize currentTokenID;
@synthesize currentDomain;
@synthesize currentProjectOrTenant;
@synthesize currentProjectOrTenantID;

//local properties accessors
@synthesize currentTokenObject;
@synthesize currentTenantsList;
@synthesize currentServices;


#pragma mark - Property accessor nameProvider readonly
- ( void ) setNameProvider:( NSString * ) nameProvider { return; }


+ ( instancetype ) initWithIdentityURL:( NSString * ) strIdentityRoot
{
    
    return [ [ self alloc ] initWithIdentityURL:strIdentityRoot ];
}

+ ( instancetype ) initWithIdentityURL:( NSString * ) strIdentityRoot
                              andLogin:( NSString * ) strLogin
                           andPassword:( NSString * ) strPassword
                      forDefaultDomain:( NSString * ) strDomain
                    andProjectOrTenant:( NSString * ) strTenant
                                thenDo:( void ( ^ ) ( NSString * strTokenIDResponse, NSDictionary * dicFullResponse ) ) doAfterInit
{
    return [ [ self alloc ] initWithIdentityURL:strIdentityRoot
                                       andLogin:strLogin
                                    andPassword:strPassword
                               forDefaultDomain:strDomain
                             andProjectOrTenant:strTenant
                                         thenDo:doAfterInit];
}

+ ( instancetype ) initWithIdentityURL:( NSString * ) strIdentityRoot
                            andTokenID:( NSString * ) strTokenID
                      forDefaultDomain:( NSString * ) strDomain
                    andProjectOrTenant:( NSString * ) strTenant
                                thenDo:( void ( ^ ) ( NSString * strTokenIDResponse, NSDictionary * dicFullResponse ) ) doAfterInit
{
    return [ [ self alloc ] initWithIdentityURL:strIdentityRoot
                                     andTokenID:strTokenID
                               forDefaultDomain:strDomain
                             andProjectOrTenant:strTenant
                                         thenDo:doAfterInit];
}



#pragma mark - property accessors


#pragma mark - Object init
- ( instancetype ) initWithIdentityURL:( NSString * ) strIdentityRoot
{
    if( self = [super initWithPublicURL:[NSURL URLWithString:strIdentityRoot]
                                andType:IDENTITY_SERVICE
                        andMajorVersion:@2
                        andMinorVersion:@0
                        andProviderName:GENERIC_SERVICENAME] )
    {
        currentDomain = @"Default";
        currentTokenID = nil;

        currentTokenObject = nil;
        currentTenantsList = nil;
        currentServices = nil;
    }
    return self;
}

- ( instancetype ) initWithIdentityURL:( NSString * ) strIdentityRoot
                              andLogin:( NSString * ) strLogin
                           andPassword:( NSString * ) strPassword
                      forDefaultDomain:( NSString * ) strDomain
                    andProjectOrTenant:( NSString * ) strTenant
                                thenDo:( void ( ^ ) ( NSString * strTokenIDResponse, NSDictionary * dicFullResponse ) ) doAfterInit
{
    IOStackAuthV2 * authSelf = [self initWithIdentityURL:strIdentityRoot];
    
    if( strDomain != nil)
        currentDomain = strDomain;
    
    if( strTenant == nil )
        [authSelf authenticateWithLogin:strLogin
                        andPassword:strPassword
                          forDomain:strDomain
                 andProjectOrTenant:strTenant
                             thenDo:^(NSString *strTokenIDResponse, NSDictionary *dicFullResponse) {
                                 [authSelf listProjectsOrTenantsThenDo:nil];
                                 if( doAfterInit != nil )
                                     doAfterInit( strTokenIDResponse, dicFullResponse );
                             }];
    else
        [authSelf authenticateWithLogin:strLogin
                            andPassword:strPassword
                              forDomain:strDomain
                     andProjectOrTenant:strTenant
                                 thenDo:doAfterInit];
    
    return authSelf;
}

- ( instancetype ) initWithIdentityURL:( NSString * ) strIdentityRoot
                              andLogin:( NSString * ) strLogin
                           andPassword:( NSString * ) strPassword
                    forProjectOrTenant:( NSString * ) strTenant
                                thenDo:( void ( ^ ) ( NSString * strTokenIDResponse, NSDictionary * dicFullResponse ) ) doAfterInit
{
    return [self initWithIdentityURL:strIdentityRoot
                            andLogin:strLogin
                         andPassword:strPassword
                    forDefaultDomain:nil
                  andProjectOrTenant:strTenant
                              thenDo:doAfterInit];
}


- ( instancetype ) initWithIdentityURL:( NSString * ) strIdentityRoot
                            andTokenID:( NSString * ) strTokenID
                      forDefaultDomain:( NSString * ) strDomain
                    andProjectOrTenant:( NSString * ) strTenant
                                thenDo:( void ( ^ ) ( NSString * strTokenIDResponse, NSDictionary * dicFullResponse ) ) doAfterInit
{
    IOStackAuthV2 * authSelf = [self initWithIdentityURL:strIdentityRoot];
    
    if( strTenant == nil )
        [authSelf authenticateWithTokenID:strTokenID
                                forDomain:strDomain
                       andProjectOrTenant:strTenant
                                   thenDo:^(NSString *strTokenIDResponse, NSDictionary *dicFullResponse) {
                                       [authSelf listProjectsOrTenantsThenDo:nil];
                                       if( doAfterInit != nil )
                                           doAfterInit( strTokenIDResponse, dicFullResponse );
                                   }];
    else
        [authSelf authenticateWithTokenID:strTokenID
                                forDomain:strDomain
                       andProjectOrTenant:strTenant
                                   thenDo:doAfterInit];
    
    return authSelf;
}


#pragma mark - helper functions
- ( NSDictionary * ) parseServices:( NSArray * ) arrServiceCatalog
{
    NSMutableDictionary * parsedServices = [[NSMutableDictionary alloc] init];
    
    for( id currentService in arrServiceCatalog )
    {
        if( ![currentService isKindOfClass:[NSDictionary class]] )
            break;
        
        if( [currentService valueForKey:@"type"] == nil )
            break;
        
        if( [currentService valueForKey:@"endpoints"] == nil ||
           [[currentService valueForKey:@"endpoints"] isKindOfClass:[NSDictionary class]] )
            break;
 
        
        NSArray * arrEndPoints      = [currentService valueForKey:@"endpoints"];
        NSURL * urlPublic           = nil;
        NSURL * urlInternal         = nil;
        NSURL * urlAdmin            = nil;
        NSString * uidService       = nil;
        NSString * strServiceType   = [currentService valueForKey:@"type"];
        
        for( NSDictionary * dicEndpoints in arrEndPoints )
        {
            if( [dicEndpoints valueForKey:@"id"] == nil )
                uidService = [dicEndpoints valueForKey:@"id"];

            if( [dicEndpoints valueForKey:@"publicURL" ] != nil )
                urlPublic = [NSURL URLWithString:[dicEndpoints valueForKey:@"publicURL" ]];
            
            if( [dicEndpoints valueForKey:@"adminURL" ] != nil )
                urlAdmin = [NSURL URLWithString:[dicEndpoints valueForKey:@"adminURL" ]];
            
            if( [dicEndpoints valueForKey:@"internalURL" ] != nil )
                urlInternal = [NSURL URLWithString:[dicEndpoints valueForKey:@"internalURL" ]];
        }
        
        NSNumber *              nVersionMajor   = @0; // default value
        NSNumber *              nVersionMinor   = @0; // default value
        NSArray<NSString *> *   compURL;
        
        if( urlInternal != nil )
            compURL = [urlInternal pathComponents];
        
        if( urlAdmin != nil )
            compURL = [urlAdmin pathComponents];
        
        if( urlPublic != nil )
            compURL = [urlPublic pathComponents];
        
        if( compURL != nil &&
           [compURL count] >= 2 &&
           [compURL objectAtIndex:1] != nil &&
           [[compURL objectAtIndex:1] characterAtIndex:0] == 'v')
        {
            NSString * fullVersionString = [compURL objectAtIndex:1];
            fullVersionString = [fullVersionString substringFromIndex:1];
            
            NSArray<NSString *> * arrVersionString = [fullVersionString componentsSeparatedByString:@"."];
            nVersionMajor = [NSNumber numberWithInteger:[[arrVersionString objectAtIndex:0] integerValue]];

            if( [arrVersionString count] == 2 )
                nVersionMinor = [NSNumber numberWithInteger:[[arrVersionString objectAtIndex:1] integerValue]];
        }
        
        IOStackService * serviceDetails = [[IOStackService alloc] initWithPublicURL:urlPublic
                                                                              andID:uidService
                                                                            andType:strServiceType
                                                                    andMajorVersion:nVersionMajor
                                                                    andMinorVersion:nVersionMinor
                                                                     andInternalURL:urlInternal
                                                                        andAdminURL:urlAdmin
                                                                    andProviderName:self.nameProvider];

        [parsedServices setObject:serviceDetails
                           forKey:strServiceType];
    }
    
    return parsedServices;
}


#pragma mark - authenticate methods
- ( void ) authenticateWithUrlParams:( NSDictionary * ) dicUrlParams
                              thenDo:( void ( ^ ) ( NSString * strTokenIDResponse, NSDictionary * dicFullResponse ) ) doAfterAuth
{
    
    [self createResource:IDENTITYV2_TOKEN_URI
              withHeader:nil
            andUrlParams:dicUrlParams
                  thenDo:^(NSDictionary * _Nullable dicResponseHeaders, id  _Nullable idFullResponse)
    {
        if( ![idFullResponse isKindOfClass:[NSDictionary class]] &&
           doAfterAuth != nil )
        {
            doAfterAuth( nil, nil );
            return;
        }
        
        NSDictionary * dicResponse     = idFullResponse;
        if( [dicResponse objectForKey:@"error"] != nil &&
            doAfterAuth != nil )
        {
            doAfterAuth( nil, nil );
            return;
        }
        
        if( ![[dicResponse objectForKey:@"access"] isKindOfClass:[NSDictionary class]] &&
           doAfterAuth != nil )
        {
            doAfterAuth( nil, nil );
            return;
        }
        
        NSDictionary * dicAccess       = [idFullResponse objectForKey:@"access"];
        
        currentTokenObject = [dicAccess objectForKey:@"token"];
        if( [currentTokenObject valueForKey:@"id"] == nil &&
           doAfterAuth != nil )
        {
            doAfterAuth( nil, nil );
            return;
        }
        currentTokenID = [currentTokenObject valueForKey:@"id"];
        
        [self setHTTPHeader:@"X-Auth-Token"
                  withValue:currentTokenID];
        
        NSDictionary * dicTenantInfos = [currentTokenObject valueForKey:@"tenant"];
        if( (dicTenantInfos != nil &&
             ![dicTenantInfos isKindOfClass:[NSDictionary class]] ) &&
           doAfterAuth != nil )
        {
            doAfterAuth( nil, nil );
            return;
        }
        
        currentProjectOrTenantID = [dicTenantInfos valueForKey:@"id"];
        
        NSArray * arrServiceCatalog = [dicAccess objectForKey:@"serviceCatalog"];
        if( arrServiceCatalog == nil ||
           ![arrServiceCatalog isKindOfClass:[NSArray class]] ||
           [arrServiceCatalog count] == 0 )
            arrServiceCatalog = nil;
        
        else
            currentServices = [self parseServices:arrServiceCatalog];
        
        if( doAfterAuth != nil )
            doAfterAuth( currentTokenID, dicResponse );
    }];
}

- ( void ) authenticateWithLogin:( NSString * ) strLogin
                     andPassword:( NSString * ) strPassword
                       forDomain:( NSString * ) strDomain
              andProjectOrTenant:( NSString * ) strTenant
                          thenDo:( void ( ^ ) ( NSString * strTokenIDResponse, NSDictionary * dicFullResponse ) ) doAfterAuth
{
    NSDictionary * urlParams = nil;
    
    if( strLogin != nil && strPassword != nil && strTenant != nil )
        urlParams = @{@"auth": @{@"tenantName": strTenant,@"passwordCredentials":@{@"username": strLogin,@"password":strPassword}}};
    
    else if( strLogin != nil && strPassword != nil )
        urlParams = @{@"auth": @{@"passwordCredentials":@{@"username": strLogin,@"password":strPassword}}};
    
    else if( strLogin != nil )
        urlParams = @{@"auth": @{@"passwordCredentials":@{@"username": strLogin}}};
    
    [self authenticateWithUrlParams:urlParams
                             thenDo:doAfterAuth];
}

- ( void ) authenticateWithTokenID:( NSString * ) strTokenID
                         forDomain:( NSString * ) strDomain
                andProjectOrTenant:( NSString * ) strTenant
                            thenDo:( void ( ^ ) ( NSString * strTokenIDResponse, NSDictionary * dicFullResponse ) ) doAfterAuth
{
    NSDictionary * dicUrlParams = nil;
    
    if( strTenant != nil && strTokenID != nil )
        dicUrlParams = @{@"auth": @{@"tenantName": strTenant, @"token":@{@"id": strTokenID}}};
    
    else if( strTokenID != nil )
        dicUrlParams = @{@"auth": @{@"token":@{@"id": strTokenID}}};
    
    else
        [NSException exceptionWithName:@"Method /authenticate bad return"
                                reason:@"No valid Token ID"
                              userInfo:@{@"urlParams": dicUrlParams}];
    
    [self authenticateWithUrlParams:dicUrlParams
                             thenDo:doAfterAuth];
}

- ( void ) authenticateForDomain:( NSString * ) strDomain
              andProjectOrTenant:( NSString * ) strTenant
                          thenDo:( void ( ^ ) ( NSString * strTokenIDResponse, NSDictionary * dicFullResponse ) ) doAfterAuth
{
    [self authenticateWithTokenID:currentTokenID
                        forDomain:strDomain
               andProjectOrTenant:strTenant
                           thenDo:doAfterAuth];
}

- ( void ) authenticateThenDo:( void ( ^ ) ( NSString * strTokenIDResponse, NSDictionary * dicFullResponse ) ) doAfterAuth
{
    [self authenticateForDomain:nil
             andProjectOrTenant:nil
                         thenDo:doAfterAuth];
}


#pragma mark - tenants methods
- ( void ) listProjectsOrTenantsWithTokenID:( NSString * ) strTokenID
                               andUrlParams:( NSDictionary * ) dicUrlParams
                                     thenDo:( void ( ^ ) ( NSArray * arrTenantResponse ) ) doAfterList
{
    //[self setHTTPHeader:@"X-Auth-Token"
    //          withValue:strTokenID];
    //NSLog( @"request serializer params : %@", [managerIdentity.requestSerializer valueForHTTPHeaderField:@"X-Auth-Token"]);
    [self listResource:IDENTITYV2_TENANT_URN
            withHeader:nil
          andUrlParams:dicUrlParams
             insideKey:@"tenants"
                thenDo:^(NSArray * _Nullable arrFound, id  _Nullable dataResponse)
     {
         currentTenantsList = arrFound;
         if( doAfterList != nil )
             doAfterList( currentTenantsList );
     }];
}

- ( void ) listProjectsOrTenantsWithTokenID:( NSString * ) strTokenID
                                  forDomain:( NSString * ) strDomainName
                                       From:( NSString * ) strStartingFromID
                                         To:( NSNumber * ) nLimit
                                     thenDo:( void ( ^ ) ( NSArray * arrTenantResponse ) ) doAfterList
{
    NSDictionary * urlParams = nil;
    
    if( strStartingFromID != nil && nLimit != nil )
        urlParams = @{@"limit":[nLimit stringValue], @"marker": strStartingFromID};
    
    else if( nLimit != nil )
        urlParams = @{@"limit":[nLimit stringValue]};
    
    else if( strStartingFromID != nil )
        urlParams = @{@"marker": strStartingFromID};
    
    if( strTokenID != nil )
        [self listProjectsOrTenantsWithTokenID:strTokenID
                                  andUrlParams:urlParams
                                        thenDo:doAfterList];
    
    else
        [NSException exceptionWithName:@"Method /tenants bad parameter"
                                reason:@"No valid Token ID"
                              userInfo:@{@"urlParams": urlParams}];
}

- ( void ) listProjectsOrTenantsWithLogin:( NSString * ) strLogin
                              andPassword:( NSString * ) strPassword
                                forDomain:( NSString * ) strDomain
                       andProjectOrTenant:( NSString * ) strProjectOrTenant
                                     From:( NSString * ) strStartingFromID
                                       To:( NSNumber * ) nLimit
                                   thenDo:( void ( ^ ) ( NSArray * arrTenantResponse ) ) doAfterList
{
    if( strLogin != nil && strPassword != nil )
        [self authenticateWithLogin:strLogin
                        andPassword:strPassword
                          forDomain:strDomain
                    andProjectOrTenant:strProjectOrTenant
                                thenDo:^(NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse) {
                                    if( strTokenIDResponse != nil )
                                        [self listProjectsOrTenantsWithTokenID:strTokenIDResponse
                                                                     forDomain:strDomain
                                                                          From:strStartingFromID
                                                                            To:nLimit
                                                                        thenDo:doAfterList];
                                }];
    
    else if( currentTokenID != nil )
        [self listProjectsOrTenantsWithTokenID:currentTokenID
                                     forDomain:strDomain
                                          From:strStartingFromID
                                            To:nLimit
                                        thenDo:doAfterList];
    
    else
        [NSException exceptionWithName:@"Method /tenants bad call"
                                reason:@"No Token ID or no login/password given"
                              userInfo:nil];
}

- ( void ) listProjectsOrTenantsFrom:( NSString * ) strStartingFromID
                                  To:( NSNumber * ) nLimit
                              thenDo:( void ( ^ ) ( NSArray * arrTenantResponse ) ) doAfterList
{
    [self listProjectsOrTenantsWithTokenID:currentTokenID
                                 forDomain:nil
                                      From:strStartingFromID
                                        To:nLimit
                                    thenDo:doAfterList];
}

- ( void ) listProjectsOrTenantsThenDo:( void ( ^ ) ( NSArray * arrTenantResponse ) ) doAfterList
{
    [self listProjectsOrTenantsFrom:nil
                                 To:nil
                             thenDo:doAfterList];
}


#pragma mark - Extensions
- ( void ) listExtensionsThenDo:( void ( ^ ) ( NSArray * arrExtensions ) ) doAfterList
{
    [self readResource:IDENTITYV2_EXTENSION_URN
            withHeader:nil
          andUrlParams:nil
             insideKey:@"extensions"
                thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable dataResponse)
    {
        NSArray * arrExtensionsFound = nil;
        if( dicObjectFound != nil &&
            dicObjectFound[ @"values"] != nil )
            arrExtensionsFound = dicObjectFound[ @"values"];
        
        if( doAfterList != nil )
            doAfterList( arrExtensionsFound );
    }];
}

- ( void ) getDetailForExtensionWithAlias:( NSString * ) nameAlias
                                   thenDo:( void ( ^ ) ( NSDictionary * dicExtension ) ) doAfterGetDetail
{
    NSString * urlExtensionAlias =[NSString stringWithFormat:@"%@/%@", IDENTITYV2_EXTENSION_URN, nameAlias];
    [self readResource:urlExtensionAlias
            withHeader:nil
          andUrlParams:nil
             insideKey:@"extension"
                thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable dataResponse)
     {
         if( doAfterGetDetail != nil )
             doAfterGetDetail( dicObjectFound );
     }];
}


@end
