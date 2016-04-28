//
//  IOStackAuthV3.m
//  IOpenStack
//
//  Created by Bruno Morel on 2015-12-07.
//  Copyright © 2015 Internap Inc. All rights reserved.
//

#import "IOStackAuthV3.h"


#define IDENTITYV3_TOKEN_URI            @"v3/auth/tokens"
#define IDENTITYV3_PROJECT_URN          @"v3/projects"
#define IDENTITYV3_DEFAULT_DOMAIN       @"Default"


@implementation IOStackAuthV3


//IOStackIdentity protocol
@synthesize currentTokenID;
@synthesize currentDomain;
@synthesize currentProjectOrTenant;
@synthesize currentProjectOrTenantID;

//local properties accessors
@synthesize currentTokenObject;
@synthesize currentProjectsList;
@synthesize currentServices;
@synthesize currentDomainID;


+ ( instancetype ) initWithIdentityURL:( NSString * ) strIdentityRoot
{
    return [ [ self alloc ] initWithIdentityURL:strIdentityRoot ];
}

+ ( instancetype ) initWithIdentityURL:( NSString * ) strIdentityRoot
                              andLogin:( NSString * ) strLogin
                           andPassword:( NSString * ) strPassword
                      forDefaultDomain:( NSString * ) strDomain
                    andProjectOrTenant:( NSString * ) strProjectOrTenant
                                thenDo:( void ( ^ ) ( NSString * strTokenIDResponse, NSDictionary * dicFullResponse ) ) doAfterInit
{
    return [ [ self alloc ] initWithIdentityURL:strIdentityRoot
                                       andLogin:strLogin
                                    andPassword:strPassword
                               forDefaultDomain:strDomain
                             andProjectOrTenant:strProjectOrTenant
                                         thenDo:doAfterInit];
}

+ ( instancetype ) initWithIdentityURL:( NSString * ) strIdentityRoot
                            andTokenID:( NSString * ) strTokenID
                      forDefaultDomain:( NSString * ) strDomain
                    andProjectOrTenant:( NSString * ) strProjectOrTenant
                                thenDo:( void ( ^ ) ( NSString * strTokenIDResponse, NSDictionary * dicFullResponse ) ) doAfterInit
{
    return [ [ self alloc ] initWithIdentityURL:strIdentityRoot
                                     andTokenID:strTokenID
                               forDefaultDomain:strDomain
                             andProjectOrTenant:strProjectOrTenant
                                         thenDo:doAfterInit];
}


#pragma mark - Object init

- ( instancetype ) initWithIdentityURL:( NSString * ) strIdentityRoot
{
    if( self = [super initWithPublicURL:[NSURL URLWithString:strIdentityRoot]
                                andType:IDENTITY_SERVICE
                        andMajorVersion:@3
                        andMinorVersion:@0
                        andProviderName:GENERIC_SERVICENAME] )
    {
        currentDomain = IDENTITYV3_DEFAULT_DOMAIN;
        currentTokenID = nil;
        currentProjectOrTenant = nil;
        
        
        currentTokenObject  = nil;
        currentProjectsList = nil;
        currentServices     = nil;
    }
    return self;
}

- ( instancetype ) initWithIdentityURL:( NSString * ) strIdentityRoot
                      forDefaultDomain:( NSString * ) strDomain
{
    IOStackAuthV3 * authSelf = [self initWithIdentityURL:strIdentityRoot];
    
    currentDomain = strDomain;
    
    return authSelf;
}

- ( instancetype ) initWithIdentityURL:( NSString * ) strIdentityRoot
                              andLogin:( NSString * ) strLogin
                           andPassword:( NSString * ) strPassword
                      forDefaultDomain:( NSString * ) strDomain
                    andProjectOrTenant:( NSString * ) strProjectOrTenant
                                thenDo:( void ( ^ ) ( NSString * strTokenIDResponse, NSDictionary * dicFullResponse ) ) doAfterInit
{
    IOStackAuthV3 * authSelf = [self initWithIdentityURL:strIdentityRoot
                                        forDefaultDomain:strDomain];
    
    [authSelf authenticateWithLogin:strLogin
                        andPassword:strPassword
                          forDomain:strDomain
                 andProjectOrTenant:strProjectOrTenant
                             thenDo:doAfterInit];
    
    return authSelf;
}

- ( instancetype ) initWithIdentityURL:( NSString * ) strIdentityRoot
                            andTokenID:( NSString * ) strTokenID
                      forDefaultDomain:( NSString * ) strDomain
                    andProjectOrTenant:( NSString * ) strProjectOrTenant
                                thenDo:( void ( ^ ) ( NSString * strTokenIDResponse, NSDictionary * dicFullResponse ) ) doAfterInit
{
    IOStackAuthV3 * authSelf = [self initWithIdentityURL:strIdentityRoot];
    
    [authSelf authenticateWithTokenID:strTokenID
                            forDomain:strDomain
                   andProjectOrTenant:strProjectOrTenant
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
        
        if( [currentService valueForKey:@"id"] == nil )
            break;
        
        NSURL * urlPublic       = nil;
        NSURL * urlInternal     = nil;
        NSURL * urlAdmin        = nil;
        NSString * uidService   = nil;
        NSString * strServiceType   = [currentService valueForKey:@"type"];
        
        uidService = [currentService valueForKey:@"id"];
        
        NSArray * arrEndPoints = [currentService valueForKey:@"endpoints"];
        for( NSDictionary * dicEndpoints in arrEndPoints )
        {
            if( [dicEndpoints valueForKey:@"interface" ] == nil )
                break;

            if( [[dicEndpoints valueForKey:@"interface"] isEqualToString:@"public"] )
                urlPublic = [NSURL URLWithString:[dicEndpoints valueForKey:@"url" ]];
                
            else if( [[dicEndpoints valueForKey:@"interface"] isEqualToString:@"admin"] )
                urlAdmin = [NSURL URLWithString:[dicEndpoints valueForKey:@"url" ]];
            
            else if( [[dicEndpoints valueForKey:@"interface"] isEqualToString:@"internal"] )
                urlInternal = [NSURL URLWithString:[dicEndpoints valueForKey:@"url" ]];
        }
        
        NSNumber *              nVersionMajor   = @1; // default value
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
    [self createResource:IDENTITYV3_TOKEN_URI
              withHeader:nil
            andUrlParams:dicUrlParams
                  thenDo:^(NSDictionary * _Nullable dicResponseHeaders, id  _Nullable idFullResponse)
    {
        currentTokenID = [dicResponseHeaders valueForKey:@"X-Subject-Token"];
        
        [self setHTTPHeader:@"X-Auth-Token"
                  withValue:currentTokenID];
        
        if( ![idFullResponse isKindOfClass:[NSDictionary class]] &&
            doAfterAuth != nil )
        {
            doAfterAuth( nil, nil );
            return;
        }
        
        NSDictionary * dicResponse     = idFullResponse;
        if( ![[dicResponse objectForKey:@"token"] isKindOfClass:[NSDictionary class]] &&
           doAfterAuth != nil )
        {
            doAfterAuth( nil, nil );
            return;
        }
        
        currentTokenObject       = [dicResponse objectForKey:@"token"];
        
        NSDictionary * dicTenantInfos = [currentTokenObject valueForKey:@"project"];
        if( ( dicTenantInfos == nil ||
             ![dicTenantInfos isKindOfClass:[NSDictionary class]]) &&
            doAfterAuth != nil )
        {
            doAfterAuth( nil, nil );
            return;
        }
        
        if( [dicTenantInfos valueForKey:@"id"] == nil &&
            doAfterAuth != nil )
        {
            doAfterAuth( nil, nil );
            return;
        }
        
        currentProjectOrTenantID = [dicTenantInfos valueForKey:@"id"];
        
        if( ![[currentTokenObject objectForKey:@"catalog"] isKindOfClass:[NSArray class]] &&
            doAfterAuth != nil )
        {
            doAfterAuth( nil, nil );
            return;
        }
        
        NSArray * arrServiceCatalog = [currentTokenObject objectForKey:@"catalog"];
        if( arrServiceCatalog == nil ||
           ![arrServiceCatalog isKindOfClass:[NSArray class]] ||
           [arrServiceCatalog count] == 0 )
            arrServiceCatalog = nil;
        
        else
            currentServices = [self parseServices:arrServiceCatalog];
        
        if( [[currentTokenObject objectForKey:@"user"] isKindOfClass:[NSDictionary class]] )
        {
            NSDictionary * dicUserDatas = [currentTokenObject objectForKey:@"user"];
            NSDictionary * dicUserDomainDatas = [dicUserDatas objectForKey:@"domain"];
            if( dicUserDomainDatas != nil )
                currentDomainID = [dicUserDomainDatas objectForKey:@"id"];
        }
        
        if( currentServices == nil ||
           [currentServices count] == 0 )
            currentServices = nil;
        
        if( doAfterAuth != nil )
            doAfterAuth( currentTokenID, dicResponse );
    }];
    
}

- ( void ) authenticateWithLogin:( NSString * ) strLogin
                     andPassword:( NSString * ) strPassword
                       forDomain:( NSString * ) strDomainName
              andProjectOrTenant:( NSString * ) strProjectOrTenant
                          thenDo:( void ( ^ ) ( NSString * strTokenIDResponse, NSDictionary * dicFullResponse ) ) doAfterAuth
{
    NSDictionary * dicParams = nil;
    
    if( strDomainName != nil && currentDomain != strDomainName )
        currentDomain = strDomainName;
    
    if( strProjectOrTenant != nil )
        currentProjectOrTenant = strProjectOrTenant;
    
    if( strLogin != nil && strPassword != nil && currentProjectOrTenant != nil )
        dicParams = @{@"auth": @{ @"identity": @{
                                          @"methods" : @[ @"password" ],
                                          @"password": @{ @"user" : @{
                                                                  @"name": strLogin,
                                                                  @"domain": @{ @"name": currentDomain },
                                                                  @"password":strPassword } } },
                                  @"scope" : @{
                                          @"project" : @{
                                                  @"name" : currentProjectOrTenant,
                                                  @"domain": @{ @"name": currentDomain } } } } };
    
    else if( strLogin != nil && strPassword != nil && currentProjectOrTenant == nil )
        dicParams = @{@"auth": @{ @"identity":
                                      @{@"methods" : @[ @"password" ],
                                        @"password": @{ @"user" : @{
                                                                @"name": strLogin,
                                                                @"domain": @{ @"name": currentDomain },
                                                                @"password":strPassword } } },
                                      @"scope" : @"unscoped" } };
    
    else if( strLogin != nil )
        dicParams = @{@"auth": @{ @"identity":
                                      @{@"methods" : @[ @"password" ],
                                        @"password": @{ @"user" : @{
                                                                @"name": strLogin,
                                                                @"domain": @{ @"name": currentDomain } } } },
                                  @"scope" : @"unscoped" } };
    
    [self authenticateWithUrlParams:dicParams
                             thenDo:doAfterAuth];
}

- ( void ) authenticateWithTokenID:( NSString * ) strTokenID
                         forDomain:( NSString * ) strDomainName
                andProjectOrTenant:( NSString * ) strProjectOrTenant
                            thenDo:( void ( ^ ) ( NSString * strTokenIDResponse, NSDictionary * dicFullResponse ) ) doAfterAuth
{
    if( strDomainName != nil && currentDomain != strDomainName )
        currentDomain = strDomainName;
    
    if( strProjectOrTenant != nil )
        currentProjectOrTenant = strProjectOrTenant;
    
    if( strTokenID != nil && currentDomain != nil && currentProjectOrTenant != nil )
        [self authenticateWithUrlParams:@{@"auth": @{
                                                  @"identity": @{
                                                          @"methods" : @[ @"token" ],
                                                          @"token": @{ @"id": strTokenID } },
                                                  @"scope" : @{
                                                          @"project" : @{
                                                                  @"name" : currentProjectOrTenant,
                                                                  @"domain": @{ @"name": currentDomain } } } } }
                                 thenDo:doAfterAuth];
    
    else if( strTokenID != nil && strDomainName == nil && currentProjectOrTenant != nil )
        [self authenticateWithUrlParams:@{@"auth": @{
                                                  @"identity": @{
                                                          @"methods" : @[ @"token" ],
                                                          @"token": @{ @"id": strTokenID } },
                                                  @"scope" : @{
                                                          @"project" : @{
                                                                  @"name" : currentProjectOrTenant,
                                                                  @"domain": @{ @"name": currentDomain } } } } }
                                 thenDo:^(NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse) {
                                     if( strTokenIDResponse == nil)
                                         [self getTokenDomainName:strTokenID
                                                           thenDo:^( NSString * strDomainOfToken ) {
                                                               if( strDomainOfToken != nil )
                                                                   [self authenticateWithUrlParams:@{@"auth": @{  @"identity": @{ @"methods" : @[ @"token" ], @"token": @{ @"id": strTokenID } },
                                                                                                                  @"scope" : @{@"project" : @{ @"name" : currentProjectOrTenant, @"domain": @{ @"name": strDomainOfToken } } } } }
                                                                                        thenDo:doAfterAuth];
                                                               else
                                                                   [self authenticateWithUrlParams:@{@"auth": @{@"token": @{@"id": strTokenID}, @"scope" : @"unscoped" } }
                                                                                            thenDo:doAfterAuth];
                                                       }];
                                     else
                                         doAfterAuth( strTokenIDResponse, dicFullResponse );
                                 }];
    
    else if ( strTokenID != nil )
        [self authenticateWithUrlParams:@{@"auth": @{@"token": @{@"id": strTokenID}, @"scope" : @"unscoped" } }
                                 thenDo:doAfterAuth];
    
    else
        [NSException exceptionWithName:@"Method /auth/tokens bad response"
                                reason:@"No valid Token ID"
                              userInfo:@{@"tokenID": strTokenID}];
}

- ( void ) authenticateForDomain:( NSString * ) strDomainName
              andProjectOrTenant:( NSString * ) strProjectOrTenant
                          thenDo:( void ( ^ ) ( NSString * strTokenIDResponse, NSDictionary * dicFullResponse ) ) doAfterAuth
{
    [self authenticateWithTokenID:currentTokenID
                        forDomain:strDomainName
               andProjectOrTenant:strProjectOrTenant
                           thenDo:doAfterAuth];
}

- ( void ) authenticateThenDo:( void ( ^ ) ( NSString * strTokenIDResponse, NSDictionary * dicFullResponse ) ) doAfterAuth
{    
    [self authenticateForDomain:nil
             andProjectOrTenant:nil
                         thenDo:doAfterAuth];
}


#pragma mark - Token details
- ( void ) getTokenDomainName:( NSString * ) strTokenID
                       thenDo:( void ( ^ ) ( NSString * strDomainOfToken ) ) doAfterGet
{
    /*TODO remove if not necessary
    [managerIdentity.requestSerializer setValue:strTokenID
                             forHTTPHeaderField:@"X-Auth-Token"];
    [managerIdentity.requestSerializer setValue:strTokenID
                             forHTTPHeaderField:@"X-Subject-Token"];
     */
    [self readResource:IDENTITYV3_TOKEN_URI
            withHeader:nil
          andUrlParams:nil
             insideKey:@"token"
                thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable dataResponse)
    {
        if( ![[dicObjectFound objectForKey:@"user"] isKindOfClass:[NSDictionary class]] &&
                doAfterGet != nil )
        {
            doAfterGet( nil );
            return;
        }

        NSDictionary * dicUser       = [dicObjectFound objectForKey:@"user"];
        
        if( ![[dicUser objectForKey:@"domain"] isKindOfClass:[NSDictionary class]] &&
           doAfterGet != nil )
        {
            doAfterGet( nil );
            return;
        }
        
        NSDictionary * dicDomain = [dicUser objectForKey:@"domain"];
        
        if( ![[dicDomain objectForKey:@"name"] isKindOfClass:[NSString class]] &&
           doAfterGet != nil )
        {
            doAfterGet( nil );
            return;
        }

        NSString * strDomainName = [dicDomain objectForKey:@"name"];
        
        if( doAfterGet != nil )
            doAfterGet( strDomainName );
    }];
     
    
    /*
    [self serviceGET:IDENTITYV3_TOKEN_URI
          withParams:nil
    onServiceSuccess:^(NSString * uidServiceTask, id responseObject, NSDictionary * dicResponseHeaders) {
        if( ![responseObject isKindOfClass:[NSDictionary class]] )
            [NSException exceptionWithName:@"Method GET /auth/tokens bad return"
                                    reason:@"response object is not a NSDictionnary"
                                  userInfo:@{@"tokenID": strTokenID, @"returnedValue": responseObject}];
        NSDictionary * dicResponse     = responseObject;
        
        if( ![[dicResponse objectForKey:@"token"] isKindOfClass:[NSDictionary class]] )
            [NSException exceptionWithName:@"Method GET /auth/tokens bad return"
                                    reason:@"'token' object is not a NSDictionnary"
                                  userInfo:@{@"tokenID": strTokenID, @"returnedValue": responseObject}];
        NSDictionary * dicToken       = [dicResponse objectForKey:@"token"];
        
        if( ![[dicToken objectForKey:@"user"] isKindOfClass:[NSDictionary class]] )
            [NSException exceptionWithName:@"Method GET /auth/tokens bad return"
                                    reason:@"'token.user' object is not a NSDictionnary"
                                  userInfo:@{@"tokenID": strTokenID, @"returnedValue": responseObject}];
        NSDictionary * dicUser       = [dicToken objectForKey:@"user"];
        
        if( ![[dicUser objectForKey:@"domain"] isKindOfClass:[NSDictionary class]] )
            [NSException exceptionWithName:@"Method GET /auth/tokens bad return"
                                    reason:@"'token.user.domain' object is not a NSDictionnary"
                                  userInfo:@{@"tokenID": strTokenID, @"returnedValue": responseObject}];
        NSDictionary * dicDomain = [dicUser objectForKey:@"domain"];
        
        if( ![[dicDomain objectForKey:@"name"] isKindOfClass:[NSString class]] )
            [NSException exceptionWithName:@"Method GET /auth/tokens bad return"
                                    reason:@"'token.user.domain.name' object is not a NSDictionnary"
                                  userInfo:@{@"tokenID": strTokenID, @"returnedValue": responseObject}];
        NSString * strDomainName = [dicDomain objectForKey:@"name"];
        
        if( doAfterGet != nil )
            doAfterGet( strDomainName );
    }
    onServiceFailure:^(NSString * uidServiceTask, NSError * error, NSUInteger nHTTPStatus ) {
        NSLog( @"token not valid : %@ - task %@", error, uidServiceTask );
        
        if( doAfterGet != nil )
            doAfterGet( nil );
    }];
     */
}


#pragma mark - Project list methods
- ( void ) listProjectsOrTenantsWithTokenID:( NSString * ) strTokenID
                               andUrlParams:( NSDictionary * ) dicUrlParams
                                     thenDo:( void ( ^ ) ( NSArray * arrProjectResponse ) ) doAfterList
{
    [self listResource:IDENTITYV3_PROJECT_URN
            withHeader:nil
          andUrlParams:dicUrlParams
             insideKey:@"projects"
                thenDo:^(NSArray * _Nullable arrFound, id  _Nullable dataResponse)
    {
        currentProjectsList = arrFound;
        if( doAfterList != nil )
            doAfterList( arrFound );
    }];
}

- ( void ) listProjectsOrTenantsWithTokenID:( NSString * ) strTokenID
                                  forDomain:( NSString * ) strDomainName
                                       From:( NSString * ) strStartingFromID
                                         To:( NSNumber * ) nLimit
                                     thenDo:( void ( ^ ) ( NSArray * arrProjectResponse ) ) doAfterList
{
    NSDictionary * dicUrlParams = nil;
    
    if( strDomainName != nil && strStartingFromID != nil )
        dicUrlParams = @{@"domain_id":strDomainName, @"parent_id": strStartingFromID};
    
    else if( strDomainName != nil )
        dicUrlParams = @{@"domain_id":strDomainName};
    
    else if( strStartingFromID != nil )
        dicUrlParams = @{@"parent_id": strStartingFromID};
    
   [self listProjectsOrTenantsWithTokenID:strTokenID
                             andUrlParams:dicUrlParams
                                   thenDo:^(NSArray * _Nullable arrProjectResponse) {
                                       if( arrProjectResponse != nil )
                                           doAfterList( arrProjectResponse );
                              
                                       else
                                           [self authenticateWithTokenID:strTokenID
                                                               forDomain:strDomainName
                                                      andProjectOrTenant:nil
                                                                  thenDo:^(NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse) {
                                                                      if( strTokenIDResponse != nil && strTokenIDResponse != strTokenID )
                                                                          [self listProjectsOrTenantsWithTokenID:strTokenIDResponse
                                                                                                    andUrlParams:dicUrlParams
                                                                                                          thenDo:doAfterList];
                                                                      else
                                                                      {
                                                                          NSLog( @"Unauthorized for domain : %@", strDomainName );
                                                                          if( doAfterList != nil )
                                                                              doAfterList( nil );
                                                                      }
                                                                  }];
                          }];
}

- ( void ) listProjectsOrTenantsWithLogin:( NSString * ) strLogin
                              andPassword:( NSString * ) strPassword
                                forDomain:( NSString * ) strDomainName
                                     From:( NSString * ) strStartingFromID
                                       To:( NSNumber * ) nLimit
                                   thenDo:( void ( ^ ) ( NSArray * arrProjectResponse ) ) doAfterList
{
    if( strLogin != nil && strPassword != nil )
        [self authenticateWithLogin:strLogin
                        andPassword:strPassword
                          forDomain:strDomainName
                 andProjectOrTenant:nil
                             thenDo:^(NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse) {
                                 if( strTokenIDResponse != nil )
                                     [self listProjectsOrTenantsWithTokenID:strTokenIDResponse
                                                                  forDomain:strDomainName
                                                                       From:strStartingFromID
                                                                         To:nLimit
                                                                     thenDo:doAfterList];
                             }];
    
    else if( currentTokenID != nil )
        [self listProjectsOrTenantsWithTokenID:currentTokenID
                                     forDomain:strDomainName
                                          From:strStartingFromID
                                            To:nLimit
                                        thenDo:doAfterList];
    
    else
        [NSException exceptionWithName:@"Method /Projects bad call"
                                reason:@"No Token ID and no login/password given"
                              userInfo:nil];
}

- ( void ) listProjectsOrTenantsFrom:( NSString * ) strStartingFromID
                                  To:( NSNumber * ) nLimit
                              thenDo:( void ( ^ ) ( NSArray * arrProjectResponse ) ) doAfterList
{
    [self listProjectsOrTenantsWithTokenID:currentTokenID
                                 forDomain:nil
                                      From:strStartingFromID
                                        To:nLimit
                                    thenDo:doAfterList];
}

- ( void ) listProjectsOrTenantsThenDo:( void ( ^ ) ( NSArray * arrProjectResponse ) ) doAfterList
{
    [self listProjectsOrTenantsFrom:nil
                                 To:nil
                             thenDo:doAfterList];
}



@end