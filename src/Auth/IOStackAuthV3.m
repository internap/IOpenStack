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
#define IDENTITYV3_CREDENTIALS_URN      @"v3/credentials"
#define IDENTITYV3_DOMAIN_URN           @"v3/domains"
#define IDENTITYV3_GROUP_URN            @"v3/groups"
#define IDENTITYV3_POLICIES_URN         @"v3/policies"
#define IDENTITYV3_REGIONS_URN          @"v3/regions"
#define IDENTITYV3_USERS_URN            @"v3/users"
#define IDENTITYV3_SERVICES_URN         @"v3/services"
#define IDENTITYV3_ENDPOINTS_URN        @"v3/endpoints"
#define IDENTITYV3_GROUPUSER_URN        @"users"
#define IDENTITYV3_USERPASSWORD_URN     @"passwords"
#define IDENTITYV3_USERGROUPS_URN       @"groups"
#define IDENTITYV3_USERPROJECTS_URN     @"projects"
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
        
        NSDictionary * dicTenantInfos = nil;
        if( [currentTokenObject valueForKey:@"project"] != nil )
            dicTenantInfos = [currentTokenObject valueForKey:@"project"];
        
        if( currentProjectOrTenantID == nil &&
           ( dicTenantInfos == nil ||
             ![dicTenantInfos isKindOfClass:[NSDictionary class]]) &&
            doAfterAuth != nil )
        {
            doAfterAuth( nil, nil );
            return;
        }
        
        if(  currentProjectOrTenantID == nil &&
            [dicTenantInfos valueForKey:@"id"] == nil &&
            doAfterAuth != nil )
        {
            doAfterAuth( nil, nil );
            return;
        }
        
        if( dicTenantInfos != nil && [dicTenantInfos valueForKey:@"id"] )
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

- ( void ) getTokenDomainName:( NSString * ) strTokenID
                       thenDo:( void ( ^ ) ( NSString * strDomainOfToken ) ) doAfterGet
{
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
}


#pragma mark - Token details
- ( void ) getdetailsForTokenWithID:( NSString * ) strTokenIDToCheck
                             thenDo:( void ( ^ ) ( NSDictionary * strTokenDetails ) ) doAfterGetDetails
{
    [self readResource:IDENTITYV3_TOKEN_URI
            withHeader:@{@"X-Subject-Token" : strTokenIDToCheck}
          andUrlParams:nil
             insideKey:@"token"
                thenDo:^(NSDictionary * dicObjectFound, id  _Nullable dataResponse)
    {
        if( doAfterGetDetails != nil )
            doAfterGetDetails( dicObjectFound );
    }];
}

- ( void ) checkTokenWithID:( NSString * ) strTokenIDToCheck
                     thenDo:( void ( ^ ) ( BOOL isValid ) ) doAfterCheck
{
    [self metadataResource:IDENTITYV3_TOKEN_URI
                withHeader:@{@"X-Subject-Token" : strTokenIDToCheck}
              andUrlParams:nil
                    thenDo:^(NSDictionary * _Nullable headerValues, id  _Nullable dataResponse)
    {
        if( doAfterCheck != nil )
            doAfterCheck( ( ( dataResponse == nil ) ||
                           ( dataResponse[ @"response" ] == nil ) ||
                           ( [dataResponse[ @"response" ] isEqualToString:@""] ) ) &&
                            ( ( headerValues != nil ) && ( [headerValues[@"X-Subject-Token"] isEqualToString:strTokenIDToCheck] ) ) );
    }];
}

- ( void ) deleteTokenWithID:( NSString * ) strTokenIDToCheck
                      thenDo:( void ( ^ ) ( BOOL isDeleted ) ) doAfterCheck
{
    [self deleteResource:IDENTITYV3_TOKEN_URI
              withHeader:@{@"X-Subject-Token" : strTokenIDToCheck}
                  thenDo:^(NSDictionary * _Nullable dicResults, id  _Nullable idFullResponse)
    {
         if( doAfterCheck != nil )
             doAfterCheck( ( idFullResponse == nil ) ||
                            ( idFullResponse[ @"response" ] == nil ) ||
                            ( [idFullResponse[ @"response" ] isEqualToString:@""] ) );
     }];
}


#pragma mark - Credentials management
- ( void ) listCredentialsThenDo:( void ( ^ ) ( NSArray * arrCredential, id idFullResponse ) ) doAfterList
{
    [self listResource:IDENTITYV3_CREDENTIALS_URN
            withHeader:nil
          andUrlParams:nil
             insideKey:@"credentials"
                thenDo:^(NSArray * _Nullable arrFound, id _Nullable dataResponse)
     {
         if( doAfterList != nil )
             doAfterList( arrFound, dataResponse );
         
     }];
}

- ( void ) createCredentialWithBlob:( NSString * ) jsonBlob
                       andProjectID:( NSString * ) uidProject
                            andType:( NSString * ) strType
                          andUserID:( NSString * ) uidUser
                             thenDo:( void ( ^ ) ( NSDictionary * credentialCreated, id dicFullResponse ) ) doAfterCreate
{
    NSMutableDictionary * mdicCredentialParam = [NSMutableDictionary dictionaryWithObject:jsonBlob
                                                                                   forKey:@"blob"];
    if( uidProject != nil )
        mdicCredentialParam[ @"project_id" ] = uidProject;

    if( strType != nil )
        mdicCredentialParam[ @"type" ] = strType;

    if( uidUser != nil )
        mdicCredentialParam[ @"user_id" ] = uidUser;

    [self createResource:IDENTITYV3_CREDENTIALS_URN
              withHeader:nil
            andUrlParams:@{ @"credential" : mdicCredentialParam }
                  thenDo:^(NSDictionary * _Nullable dicResponseHeaders, id  _Nullable idFullResponse)
     {
         NSDictionary * finalCredential = idFullResponse;
         if( idFullResponse != nil )
             finalCredential = idFullResponse[ @"credential" ];
         
         if( doAfterCreate != nil )
             doAfterCreate( finalCredential, idFullResponse );
     }];
}

- ( void ) getdetailForCredentialWithID:( NSString * ) uidCredential
                                 thenDo:( void ( ^ ) ( NSDictionary * dicDomain ) ) doAfterGetDetail
{
    NSString * urlCredential =[NSString stringWithFormat:@"%@/%@", IDENTITYV3_CREDENTIALS_URN, uidCredential];
    [self readResource:urlCredential
            withHeader:nil
          andUrlParams:nil
             insideKey:@"credential"
                thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable dataResponse)
     {
         if( doAfterGetDetail != nil )
             doAfterGetDetail( dicObjectFound );
     }];
}

- ( void ) updateCredentialWithID:( NSString * ) uidCredential
                          newBlob:( NSString * ) jsonBlob
                     newProjectID:( NSString * ) uidProject
                          newType:( NSString * ) strType
                        newUserID:( NSString * ) uidUser
                       thenDo:( void ( ^ ) ( NSDictionary * credentialUpdated, id dicFullResponse ) ) doAfterUpdate
{
    NSString * urlCredential =[NSString stringWithFormat:@"%@/%@", IDENTITYV3_CREDENTIALS_URN, uidCredential];
    NSMutableDictionary * mdicCredentialParam = [NSMutableDictionary dictionary];
    
    if( jsonBlob != nil )
        mdicCredentialParam[ @"blob" ] = jsonBlob;
    
    if( uidProject != nil )
        mdicCredentialParam[ @"project_id" ] = uidProject;
    
    if( strType != nil )
        mdicCredentialParam[ @"type" ] = strType;
    
    if( uidUser != nil )
        mdicCredentialParam[ @"user_id" ] = uidUser;
    
    [self updateResource:urlCredential
              withHeader:nil
            andUrlParams:@{ @"credential" : mdicCredentialParam }
                  thenDo:^(NSDictionary * _Nullable dicResponseHeader, id  _Nullable idFullResponse)
     {
         NSDictionary * finalCredential = idFullResponse;
         if( idFullResponse != nil )
             finalCredential = idFullResponse[ @"credential" ];
         
         if( doAfterUpdate != nil )
             doAfterUpdate( finalCredential, idFullResponse );
     }];
}

- ( void ) deleteCredentialWithID:( NSString * ) uidCredential
                           thenDo:( void ( ^ ) ( bool isDeleted, id idFullResponse ) ) doAfterDelete
{
    NSString * urlCredential =[NSString stringWithFormat:@"%@/%@", IDENTITYV3_CREDENTIALS_URN, uidCredential];
    [self deleteResource:urlCredential
              withHeader:nil
                  thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable idFullResponse)
     {
         if( doAfterDelete != nil )
             doAfterDelete( ( idFullResponse == nil ) ||
                           ( idFullResponse[ @"response" ] == nil ) ||
                           ( [idFullResponse[ @"response" ] isEqualToString:@""] ), idFullResponse );
     }];
}


#pragma mark - Domain management
- ( void ) listDomainsThenDo:( void ( ^ ) ( NSArray * arrDomains, id idFullResponse ) ) doAfterList
{
    [self listResource:IDENTITYV3_DOMAIN_URN
            withHeader:nil
          andUrlParams:nil
             insideKey:@"domains"
                thenDo:^(NSArray * _Nullable arrFound, id _Nullable dataResponse)
     {
         if( doAfterList != nil )
             doAfterList( arrFound, dataResponse );
         
     }];
}

- ( void ) createDomainWithName:( NSString * ) nameDomain
                 andDescription:( NSString * ) strDescription
                      isEnabled:( BOOL ) isEnabled
                         thenDo:( void ( ^ ) ( NSDictionary * domainCreated, id dicFullResponse ) ) doAfterCreate
{
    NSMutableDictionary * mdicDomainParam = [NSMutableDictionary dictionaryWithObject:nameDomain
                                                                               forKey:@"name"];
    if( strDescription != nil )
        mdicDomainParam[ @"description" ] = strDescription;
    
    mdicDomainParam[ @"enabled" ] = [NSNumber numberWithBool:YES];
    
    if( !isEnabled )
        mdicDomainParam[ @"enabled" ] = [NSNumber numberWithBool:NO];
    
    [self createResource:IDENTITYV3_DOMAIN_URN
              withHeader:nil
            andUrlParams:@{ @"domain" : mdicDomainParam }
                  thenDo:^(NSDictionary * _Nullable dicResponseHeaders, id  _Nullable idFullResponse)
     {
         NSDictionary * finalDomain = idFullResponse;
         if( idFullResponse != nil )
             finalDomain = idFullResponse[ @"domain" ];
         
         if( doAfterCreate != nil )
             doAfterCreate( finalDomain, idFullResponse );
     }];
}

- ( void ) getdetailForDomainWithID:( NSString * ) uidDomain
                             thenDo:( void ( ^ ) ( NSDictionary * dicDomain ) ) doAfterGetDetail
{
    NSString * urlDomain =[NSString stringWithFormat:@"%@/%@", IDENTITYV3_DOMAIN_URN, uidDomain];
    [self readResource:urlDomain
            withHeader:nil
          andUrlParams:nil
             insideKey:@"domain"
                thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable dataResponse)
     {
         if( doAfterGetDetail != nil )
             doAfterGetDetail( dicObjectFound );
     }];
}

- ( void ) updateDomainWithID:( NSString * ) uidDomain
                      newName:( NSString * ) nameDomain
               newDescription:( NSString * ) strDescription
                    isEnabled:( BOOL ) isEnabled
                       thenDo:( void ( ^ ) ( NSDictionary * domainUpdated, id dicFullResponse ) ) doAfterUpdate
{
    NSString * urlDomain =[NSString stringWithFormat:@"%@/%@", IDENTITYV3_DOMAIN_URN, uidDomain];
    NSMutableDictionary * mdicDomainParam = [NSMutableDictionary dictionary];
    
    if( nameDomain != nil )
        mdicDomainParam[ @"name" ] = nameDomain;

    if( strDescription != nil )
        mdicDomainParam[ @"description" ] = strDescription;
    
    mdicDomainParam[ @"enabled" ] = [NSNumber numberWithBool:YES];
    
    if( !isEnabled )
        mdicDomainParam[ @"enabled" ] = [NSNumber numberWithBool:NO];
    
    [self updateResource:urlDomain
              withHeader:nil
            andUrlParams:@{ @"domain" : mdicDomainParam }
                  thenDo:^(NSDictionary * _Nullable dicResponseHeader, id  _Nullable idFullResponse)
     {
         NSDictionary * finalDomain = idFullResponse;
         if( idFullResponse != nil )
             finalDomain = idFullResponse[ @"domain" ];
         
         if( doAfterUpdate != nil )
             doAfterUpdate( finalDomain, idFullResponse );
     }];
}

- ( void ) deleteDomainWithID:( NSString * ) uidDomain
                       thenDo:( void ( ^ ) ( bool isDeleted, id idFullResponse ) ) doAfterDelete
{
    NSString * urlDomain =[NSString stringWithFormat:@"%@/%@", IDENTITYV3_DOMAIN_URN, uidDomain];
    [self deleteResource:urlDomain
              withHeader:nil
                  thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable idFullResponse)
     {
         if( doAfterDelete != nil )
             doAfterDelete( ( idFullResponse == nil ) ||
                           ( idFullResponse[ @"response" ] == nil ) ||
                           ( [idFullResponse[ @"response" ] isEqualToString:@""] ), idFullResponse );
     }];
}


#pragma mark - Groups management
- ( void ) listGroupsThenDo:( void ( ^ ) ( NSArray * arrGroups, id idFullResponse ) ) doAfterList
{
    [self listResource:IDENTITYV3_GROUP_URN
            withHeader:nil
          andUrlParams:nil
             insideKey:@"groups"
                thenDo:^(NSArray * _Nullable arrFound, id _Nullable dataResponse)
     {
         if( doAfterList != nil )
             doAfterList( arrFound, dataResponse );
         
     }];
}

- ( void ) createGroupWithName:( NSString * ) nameGroup
                andDescription:( NSString * ) strDescription
              andOwnerDomainID:( NSString * ) uidOwnerDomain
                         thenDo:( void ( ^ ) ( NSDictionary * groupCreated, id dicFullResponse ) ) doAfterCreate
{
    NSMutableDictionary * mdicGroupParam = [NSMutableDictionary dictionaryWithObject:nameGroup
                                                                               forKey:@"name"];
    if( strDescription != nil )
        mdicGroupParam[ @"description" ] = strDescription;
    
    if( uidOwnerDomain != nil )
        mdicGroupParam[ @"domain_id" ] = uidOwnerDomain;
    
    [self createResource:IDENTITYV3_GROUP_URN
              withHeader:nil
            andUrlParams:@{ @"group" : mdicGroupParam }
                  thenDo:^(NSDictionary * _Nullable dicResponseHeaders, id  _Nullable idFullResponse)
     {
         NSDictionary * finalGroup = idFullResponse;
         if( idFullResponse != nil )
             finalGroup = idFullResponse[ @"group" ];
         
         if( doAfterCreate != nil )
             doAfterCreate( finalGroup, idFullResponse );
     }];
}

- ( void ) getdetailForGroupWithID:( NSString * ) uidGroup
                             thenDo:( void ( ^ ) ( NSDictionary * dicGroup ) ) doAfterGetDetail
{
    NSString * urlGroup =[NSString stringWithFormat:@"%@/%@", IDENTITYV3_GROUP_URN, uidGroup];
    [self readResource:urlGroup
            withHeader:nil
          andUrlParams:nil
             insideKey:@"group"
                thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable dataResponse)
     {
         if( doAfterGetDetail != nil )
             doAfterGetDetail( dicObjectFound );
     }];
}

- ( void ) updateGroupWithID:( NSString * ) uidGroup
                     newName:( NSString * ) nameGroup
              newDescription:( NSString * ) strDescription
            newOwnerDomainID:( NSString * ) uidOwnerDomain
                       thenDo:( void ( ^ ) ( NSDictionary * groupUpdated, id dicFullResponse ) ) doAfterUpdate
{
    NSString * urlGroup =[NSString stringWithFormat:@"%@/%@", IDENTITYV3_GROUP_URN, uidGroup];
    NSMutableDictionary * mdicGroupParam = [NSMutableDictionary dictionary];
    
    if( nameGroup != nil )
        mdicGroupParam[ @"name" ] = nameGroup;
    
    if( strDescription != nil )
        mdicGroupParam[ @"description" ] = strDescription;
    
    if( uidOwnerDomain != nil )
        mdicGroupParam[ @"domain_id" ] = uidOwnerDomain;
    
    [self updateResource:urlGroup
              withHeader:nil
            andUrlParams:@{ @"group" : mdicGroupParam }
                  thenDo:^(NSDictionary * _Nullable dicResponseHeader, id  _Nullable idFullResponse)
     {
         NSDictionary * finalGroup = idFullResponse;
         if( idFullResponse != nil )
             finalGroup = idFullResponse[ @"group" ];
         
         if( doAfterUpdate != nil )
             doAfterUpdate( finalGroup, idFullResponse );
     }];
}

- ( void ) deleteGroupWithID:( NSString * ) uidGroup
                       thenDo:( void ( ^ ) ( bool isDeleted, id idFullResponse ) ) doAfterDelete
{
    NSString * urlGroup =[NSString stringWithFormat:@"%@/%@", IDENTITYV3_GROUP_URN, uidGroup];
    [self deleteResource:urlGroup
              withHeader:nil
                  thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable idFullResponse)
     {
         if( doAfterDelete != nil )
             doAfterDelete( ( idFullResponse == nil ) ||
                           ( idFullResponse[ @"response" ] == nil ) ||
                           ( [idFullResponse[ @"response" ] isEqualToString:@""] ), idFullResponse );
     }];
}

- ( void ) listUsersInGroupWithID:( NSString * ) uidGroup
                           thenDo:( void ( ^ ) ( NSArray * arrUsers, id idFullResponse ) ) doAfterList
{
    NSString * urlGroupUsers =[NSString stringWithFormat:@"%@/%@/%@", IDENTITYV3_GROUP_URN, uidGroup, IDENTITYV3_GROUPUSER_URN];
    [self listResource:urlGroupUsers
            withHeader:nil
          andUrlParams:nil
             insideKey:@"users"
                thenDo:^(NSArray * _Nullable arrFound, id _Nullable dataResponse)
     {
         if( doAfterList != nil )
             doAfterList( arrFound, dataResponse );
     }];
}

- ( void ) addUserWithID:( NSString * ) uidUser
           toGroupWithID:( NSString * ) uidGroup
                  thenDo:( void ( ^ ) ( BOOL isAdded, id dicFullResponse ) ) doAfterAdd
{
    NSString * urlUserInGroup =[NSString stringWithFormat:@"%@/%@/%@/%@", IDENTITYV3_GROUP_URN, uidGroup, IDENTITYV3_GROUPUSER_URN, uidUser];
    
    [self replaceResource:urlUserInGroup
               withHeader:nil
             andUrlParams:nil
                  thenDo:^(NSDictionary * _Nullable dicResponseHeaders, id  _Nullable idFullResponse)
     {
         if( doAfterAdd != nil )
             doAfterAdd( ( idFullResponse == nil ) ||
                           ( idFullResponse[ @"response" ] == nil ) ||
                           ( [idFullResponse[ @"response" ] isEqualToString:@""] ), idFullResponse );
     }];
}

- ( void ) checkUserWithID:( NSString * ) uidUser
      belongsToGroupWithID:( NSString * ) uidGroup
                    thenDo:( void ( ^ ) ( BOOL isInGroup ) ) doAfterCheck
{
    NSString * urlUserInGroup =[NSString stringWithFormat:@"%@/%@/%@/%@", IDENTITYV3_GROUP_URN, uidGroup, IDENTITYV3_GROUPUSER_URN, uidUser];
    [self metadataResource:urlUserInGroup
                withHeader:nil
              andUrlParams:nil
                    thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable dataResponse)
     {
         if( doAfterCheck != nil )
             doAfterCheck( ( ( dataResponse == nil ) ||
                            ( dataResponse[ @"response" ] == nil ) ||
                            ( [dataResponse[ @"response" ] isEqualToString:@""] ) ) );
     }];
}

- ( void ) deleteUserWithID:( NSString * ) uidUser
            fromGroupWithID:( NSString * ) uidGroup
                     thenDo:( void ( ^ ) ( bool isDeleted, id idFullResponse ) ) doAfterDelete
{
    NSString * urlUserInGroup =[NSString stringWithFormat:@"%@/%@/%@/%@", IDENTITYV3_GROUP_URN, uidGroup, IDENTITYV3_GROUPUSER_URN, uidUser];
    [self deleteResource:urlUserInGroup
              withHeader:nil
                  thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable idFullResponse)
     {
         if( doAfterDelete != nil )
             doAfterDelete( ( idFullResponse == nil ) ||
                           ( idFullResponse[ @"response" ] == nil ) ||
                           ( [idFullResponse[ @"response" ] isEqualToString:@""] ), idFullResponse );
     }];
}


#pragma mark - Policies management
- ( void ) listPoliciesThenDo:( void ( ^ ) ( NSArray * arrPolicies, id idFullResponse ) ) doAfterList
{
    [self listResource:IDENTITYV3_POLICIES_URN
            withHeader:nil
          andUrlParams:nil
             insideKey:@"policies"
                thenDo:^(NSArray * _Nullable arrFound, id _Nullable dataResponse)
     {
         if( doAfterList != nil )
             doAfterList( arrFound, dataResponse );
         
     }];
}

- ( void ) createPolicyWithBlob:( NSString * ) strBlob
                        andType:( NSString * ) mimeType
                   andProjectID:( NSString * ) uidProject
                 andOwnerUserID:( NSString * ) uidOwner
                         thenDo:( void ( ^ ) ( NSDictionary * policyCreated, id dicFullResponse ) ) doAfterCreate
{
    NSMutableDictionary * mdicPolicyParam = [NSMutableDictionary dictionaryWithObject:strBlob
                                                                               forKey:@"blob"];
    if( mimeType != nil )
        mdicPolicyParam[ @"type" ] = mimeType;

    if( uidProject != nil )
        mdicPolicyParam[ @"project_id" ] = uidProject;
    
    if( uidOwner != nil )
        mdicPolicyParam[ @"user_id" ] = uidOwner;
    
    
    [self createResource:IDENTITYV3_POLICIES_URN
              withHeader:nil
            andUrlParams:@{ @"policy" : mdicPolicyParam }
                  thenDo:^(NSDictionary * _Nullable dicResponseHeaders, id  _Nullable idFullResponse)
     {
         NSDictionary * finalPolicy = idFullResponse;
         if( idFullResponse != nil )
             finalPolicy = idFullResponse[ @"policy" ];
         
         if( doAfterCreate != nil )
             doAfterCreate( finalPolicy, idFullResponse );
     }];
}

- ( void ) getdetailForPolicyWithID:( NSString * ) uidPolicy
                             thenDo:( void ( ^ ) ( NSDictionary * dicPolicy ) ) doAfterGetDetail
{
    NSString * urlPolicy =[NSString stringWithFormat:@"%@/%@", IDENTITYV3_POLICIES_URN, uidPolicy];
    [self readResource:urlPolicy
            withHeader:nil
          andUrlParams:nil
             insideKey:@"policy"
                thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable dataResponse)
     {
         if( doAfterGetDetail != nil )
             doAfterGetDetail( dicObjectFound );
     }];
}

- ( void ) updatePolicyWithID:( NSString * ) uidPolicy
                      newBlob:( NSString * ) strBlob
                      newType:( NSString * ) mimeType
                 newProjectID:( NSString * ) uidProject
               newOwnerUserID:( NSString * ) uidOwner
                       thenDo:( void ( ^ ) ( NSDictionary * policyUpdated, id dicFullResponse ) ) doAfterUpdate
{
    NSString * urlPolicy =[NSString stringWithFormat:@"%@/%@", IDENTITYV3_POLICIES_URN, uidPolicy];
    NSMutableDictionary * mdicPolicyParam = [NSMutableDictionary dictionary];

    if( strBlob != nil )
        mdicPolicyParam[ @"blob" ] = strBlob;
    
    if( mimeType != nil )
        mdicPolicyParam[ @"type" ] = mimeType;
    
    if( uidProject != nil )
        mdicPolicyParam[ @"project_id" ] = uidProject;
    
    if( uidOwner != nil )
        mdicPolicyParam[ @"user_id" ] = uidOwner;
    
    
    [self updateResource:urlPolicy
              withHeader:nil
            andUrlParams:@{ @"policy" : mdicPolicyParam }
                  thenDo:^(NSDictionary * _Nullable dicResponseHeader, id  _Nullable idFullResponse)
     {
         NSDictionary * finalPolicy = idFullResponse;
         if( idFullResponse != nil )
             finalPolicy = idFullResponse[ @"policy" ];
         
         if( doAfterUpdate != nil )
             doAfterUpdate( finalPolicy, idFullResponse );
     }];
}

- ( void ) deletePolicyWithID:( NSString * ) uidPolicy
                       thenDo:( void ( ^ ) ( bool isDeleted, id idFullResponse ) ) doAfterDelete
{
    NSString * urlPolicy =[NSString stringWithFormat:@"%@/%@", IDENTITYV3_POLICIES_URN, uidPolicy];
    [self deleteResource:urlPolicy
              withHeader:nil
                  thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable idFullResponse)
     {
         if( doAfterDelete != nil )
             doAfterDelete( ( idFullResponse == nil ) ||
                           ( idFullResponse[ @"response" ] == nil ) ||
                           ( [idFullResponse[ @"response" ] isEqualToString:@""] ), idFullResponse );
     }];
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
                                   thenDo:^(NSArray * _Nullable arrProjectResponse)
    {
        if( arrProjectResponse != nil )
            doAfterList( arrProjectResponse );
        
        else
            [self authenticateWithTokenID:strTokenID
                                forDomain:strDomainName
                       andProjectOrTenant:nil
                                   thenDo:^(NSString * _Nullable strTokenIDResponse, NSDictionary * _Nullable dicFullResponse)
             {
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
                       andProjectOrTenant:( NSString * ) strProjectOrTenant
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
                                 else if( doAfterList != nil )
                                     doAfterList( nil );
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

- ( void ) createProjectOrTenantWithName:( NSString * ) nameProjectOrTenant
                          andDescription:( NSString * ) strDescription
                             andDomainID:( NSString * ) uidDomain
              andParentProjectOrTenantID:( NSString * ) uidParentProjectOrTenant
                                isDomain:( BOOL ) isAlsoDomain
                               isEnabled:( BOOL ) isEnabled
                                  thenDo:( void ( ^ ) ( NSDictionary * createdProjectOrTenant, id dicFullResponse ) ) doAfterCreate
{
    NSMutableDictionary * mdicProjectOrTenantParam = [NSMutableDictionary dictionaryWithObject:nameProjectOrTenant
                                                                               forKey:@"name"];
    if( strDescription != nil )
        mdicProjectOrTenantParam[ @"description" ] = strDescription;
    
    if( uidDomain != nil )
        mdicProjectOrTenantParam[ @"domain_id" ] = uidDomain;
    
    if( uidParentProjectOrTenant != nil )
        mdicProjectOrTenantParam[ @"parent_id" ] = uidParentProjectOrTenant;
    
    mdicProjectOrTenantParam[ @"enabled" ] = [NSNumber numberWithBool:NO];
    if( isEnabled )
        mdicProjectOrTenantParam[ @"enabled" ] = [NSNumber numberWithBool:YES];
    
    
    mdicProjectOrTenantParam[ @"is_domain" ] = [NSNumber numberWithBool:NO];
    if( isAlsoDomain )
        mdicProjectOrTenantParam[ @"is_domain" ] = [NSNumber numberWithBool:YES];
    
    [self createResource:IDENTITYV3_PROJECT_URN
              withHeader:nil
            andUrlParams:@{ @"project" : mdicProjectOrTenantParam }
                  thenDo:^(NSDictionary * _Nullable dicResponseHeaders, id  _Nullable idFullResponse)
     {
         NSDictionary * finalProjectOrTenant = idFullResponse;
         if( idFullResponse != nil )
             finalProjectOrTenant = idFullResponse[ @"project" ];
         
         if( doAfterCreate != nil )
             doAfterCreate( finalProjectOrTenant, idFullResponse );
     }];
}

- ( void ) getdetailForProjectOrTenantWithID:( NSString * ) uidProjectOrTenant
                                      thenDo:( void ( ^ ) ( NSDictionary * dicProjectOrTenant ) ) doAfterGetDetail
{
    NSString * urlProjectOrTenant =[NSString stringWithFormat:@"%@/%@", IDENTITYV3_PROJECT_URN, uidProjectOrTenant];
    [self readResource:urlProjectOrTenant
            withHeader:nil
          andUrlParams:nil
             insideKey:@"project"
                thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable dataResponse)
     {
         if( doAfterGetDetail != nil )
             doAfterGetDetail( dicObjectFound );
     }];
}

- ( void ) updateProjectOrTenantWithID:( NSString * ) uidProjectOrTenant
                               newName:( NSString * ) nameProjectOrTenant
                        newDescription:( NSString * ) strDescription
                           newDomainID:( NSString * ) uidDomain
                              isDomain:( BOOL ) isAlsoDomain
                             isEnabled:( BOOL ) isEnabled
                       thenDo:( void ( ^ ) ( NSDictionary * updatedProjectOrTenant, id dicFullResponse ) ) doAfterUpdate
{
    NSString * urlProjectOrTenant =[NSString stringWithFormat:@"%@/%@", IDENTITYV3_PROJECT_URN, uidProjectOrTenant];
    NSMutableDictionary * mdicProjectOrTenantParam = [NSMutableDictionary dictionary];
    
    if( nameProjectOrTenant != nil )
        mdicProjectOrTenantParam[ @"name" ] = nameProjectOrTenant;
    
    if( strDescription != nil )
        mdicProjectOrTenantParam[ @"description" ] = strDescription;
    
    if( uidDomain != nil )
        mdicProjectOrTenantParam[ @"domain_id" ] = uidDomain;
        
    mdicProjectOrTenantParam[ @"enabled" ] = [NSNumber numberWithBool:NO];
    if( isEnabled )
        mdicProjectOrTenantParam[ @"enabled" ] = [NSNumber numberWithBool:YES];
    
    
    mdicProjectOrTenantParam[ @"is_domain" ] = [NSNumber numberWithBool:NO];
    if( isAlsoDomain )
        mdicProjectOrTenantParam[ @"is_domain" ] = [NSNumber numberWithBool:YES];
    
    [self updateResource:urlProjectOrTenant
              withHeader:nil
            andUrlParams:@{ @"project" : mdicProjectOrTenantParam }
                  thenDo:^(NSDictionary * _Nullable dicResponseHeader, id  _Nullable idFullResponse)
     {
         NSDictionary * finalProjectOrTenant = idFullResponse;
         if( idFullResponse != nil )
             finalProjectOrTenant = idFullResponse[ @"project" ];
         
         if( doAfterUpdate != nil )
             doAfterUpdate( finalProjectOrTenant, idFullResponse );
     }];
}

- ( void ) deleteProjectOrTenantWithID:( NSString * ) uidProjectOrTenant
                       thenDo:( void ( ^ ) ( bool isDeleted, id idFullResponse ) ) doAfterDelete
{
    NSString * urlProjectOrTenant =[NSString stringWithFormat:@"%@/%@", IDENTITYV3_PROJECT_URN, uidProjectOrTenant];
    [self deleteResource:urlProjectOrTenant
              withHeader:nil
                  thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable idFullResponse)
     {
         if( doAfterDelete != nil )
             doAfterDelete( ( idFullResponse == nil ) ||
                           ( idFullResponse[ @"response" ] == nil ) ||
                           ( [idFullResponse[ @"response" ] isEqualToString:@""] ), idFullResponse );
     }];
}


#pragma mark - Regions management
- ( void ) listRegionsThenDo:( void ( ^ ) ( NSArray * arrRegions, id idFullResponse ) ) doAfterList
{
    [self listResource:IDENTITYV3_REGIONS_URN
            withHeader:nil
          andUrlParams:nil
             insideKey:@"regions"
                thenDo:^(NSArray * _Nullable arrFound, id _Nullable dataResponse)
     {
         if( doAfterList != nil )
             doAfterList( arrFound, dataResponse );
         
     }];
}

- ( void ) createRegionWithDescription:( NSString * ) strDescription
                           andForcedID:( NSString * ) strRegionForcedID
                     andParentRegionID:( NSString * ) uidParentRegion
                         thenDo:( void ( ^ ) ( NSDictionary * createdRegion, id dicFullResponse ) ) doAfterCreate
{
    NSMutableDictionary * mdicRegionParam = [NSMutableDictionary dictionary];
    
    if( strDescription != nil )
        mdicRegionParam[ @"description" ] = strDescription;
    
    if( strRegionForcedID != nil )
        mdicRegionParam[ @"id" ] = strRegionForcedID;
    
    if( uidParentRegion != nil )
        mdicRegionParam[ @"parent_region_id" ] = uidParentRegion;
    
    if( [mdicRegionParam count] > 0)
        [self createResource:IDENTITYV3_REGIONS_URN
                  withHeader:nil
                andUrlParams:@{ @"region" : mdicRegionParam }
                      thenDo:^(NSDictionary * _Nullable dicResponseHeaders, id  _Nullable idFullResponse)
         {
             NSDictionary * finalRegion = idFullResponse;
             if( idFullResponse != nil )
                 finalRegion = idFullResponse[ @"region" ];
             
             if( doAfterCreate != nil )
                 doAfterCreate( finalRegion, idFullResponse );
         }];
}

- ( void ) getdetailForRegionWithID:( NSString * ) uidRegion
                             thenDo:( void ( ^ ) ( NSDictionary * dicRegion ) ) doAfterGetDetail
{
    NSString * urlRegion =[NSString stringWithFormat:@"%@/%@", IDENTITYV3_REGIONS_URN, uidRegion];
    [self readResource:urlRegion
            withHeader:nil
          andUrlParams:nil
             insideKey:@"region"
                thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable dataResponse)
     {
         if( doAfterGetDetail != nil )
             doAfterGetDetail( dicObjectFound );
     }];
}

- ( void ) updateRegionWithID:( NSString * ) uidRegion
               newDescription:( NSString * ) strDescription
            newParentRegionID:( NSString * ) uidParentRegion
                       thenDo:( void ( ^ ) ( NSDictionary * updatedRegion, id dicFullResponse ) ) doAfterUpdate
{
    NSString * urlRegion =[NSString stringWithFormat:@"%@/%@", IDENTITYV3_REGIONS_URN, uidRegion];
    NSMutableDictionary * mdicRegionParam = [NSMutableDictionary dictionary];
    
    if( strDescription != nil )
        mdicRegionParam[ @"description" ] = strDescription;
    
    if( uidParentRegion != nil )
        mdicRegionParam[ @"parent_region_id" ] = uidParentRegion;
    
    [self updateResource:urlRegion
              withHeader:nil
            andUrlParams:@{ @"region" : mdicRegionParam }
                  thenDo:^(NSDictionary * _Nullable dicResponseHeader, id  _Nullable idFullResponse)
     {
         NSDictionary * finalRegion = idFullResponse;
         if( idFullResponse != nil )
             finalRegion = idFullResponse[ @"region" ];
         
         if( doAfterUpdate != nil )
             doAfterUpdate( finalRegion, idFullResponse );
     }];
}

- ( void ) deleteRegionWithID:( NSString * ) uidRegion
                       thenDo:( void ( ^ ) ( bool isDeleted, id idFullResponse ) ) doAfterDelete
{
    NSString * urlRegion =[NSString stringWithFormat:@"%@/%@", IDENTITYV3_REGIONS_URN, uidRegion];
    [self deleteResource:urlRegion
              withHeader:nil
                  thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable idFullResponse)
     {
         if( doAfterDelete != nil )
             doAfterDelete( ( idFullResponse == nil ) ||
                           ( idFullResponse[ @"response" ] == nil ) ||
                           ( [idFullResponse[ @"response" ] isEqualToString:@""] ), idFullResponse );
     }];
}

#pragma mark - Services and endpoints management
- ( void ) listServicesThenDo:( void ( ^ ) ( NSArray * arrServices, id idFullResponse ) ) doAfterList
{
    [self listResource:IDENTITYV3_SERVICES_URN
            withHeader:nil
          andUrlParams:nil
             insideKey:@"services"
                thenDo:^(NSArray * _Nullable arrFound, id _Nullable dataResponse)
     {
         if( doAfterList != nil )
             doAfterList( arrFound, dataResponse );
         
     }];
}

- ( void ) createServiceWithType:( NSString * ) strServiceType
                         andName:( NSString * ) nameService
                  andDescription:( NSString * ) strDescription
              andForcedServiceID:( NSString * ) uidForced
                       isEnabled:( BOOL ) isEnabled
                          thenDo:( void ( ^ ) ( NSDictionary * createdService, id dicFullResponse ) ) doAfterCreate
{
    NSMutableDictionary * mdicServiceParam = [NSMutableDictionary dictionaryWithObject:strServiceType
                                                                                forKey:@"type"];
    
    if( nameService != nil )
        mdicServiceParam[ @"name" ] = nameService;

    if( strDescription != nil )
        mdicServiceParam[ @"description" ] = strDescription;
    
    if( uidForced != nil )
        mdicServiceParam[ @"service_id" ] = uidForced;
    
    mdicServiceParam[ @"enabled" ] = [NSNumber numberWithBool:NO];
    if( isEnabled )
        mdicServiceParam[ @"enabled" ] = [NSNumber numberWithBool:YES];
    
    
    [self createResource:IDENTITYV3_SERVICES_URN
              withHeader:nil
            andUrlParams:@{ @"service" : mdicServiceParam }
                  thenDo:^(NSDictionary * _Nullable dicResponseHeaders, id  _Nullable idFullResponse)
     {
         NSDictionary * finalService = idFullResponse;
         if( idFullResponse != nil )
             finalService = idFullResponse[ @"service" ];
         
         if( doAfterCreate != nil )
             doAfterCreate( finalService, idFullResponse );
     }];
}

- ( void ) getdetailForServiceWithID:( NSString * ) uidService
                             thenDo:( void ( ^ ) ( NSDictionary * dicService ) ) doAfterGetDetail
{
    NSString * urlService =[NSString stringWithFormat:@"%@/%@", IDENTITYV3_SERVICES_URN, uidService];
    [self readResource:urlService
            withHeader:nil
          andUrlParams:nil
             insideKey:@"service"
                thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable dataResponse)
     {
         if( doAfterGetDetail != nil )
             doAfterGetDetail( dicObjectFound );
     }];
}

- ( void ) updateServiceWithID:( NSString * ) uidService
                       newType:( NSString * ) strServiceType
                       newName:( NSString * ) nameService
                newDescription:( NSString * ) strDescription
                     isEnabled:( BOOL ) isEnabled
                       thenDo:( void ( ^ ) ( NSDictionary * updatedService, id dicFullResponse ) ) doAfterUpdate
{
    NSString * urlService =[NSString stringWithFormat:@"%@/%@", IDENTITYV3_SERVICES_URN, uidService];
    NSMutableDictionary * mdicServiceParam = [NSMutableDictionary dictionary];
    
    if( strServiceType != nil )
        mdicServiceParam[ @"type" ] = strServiceType;
    
    if( nameService != nil )
        mdicServiceParam[ @"name" ] = nameService;
    
    if( strDescription != nil )
        mdicServiceParam[ @"description" ] = strDescription;
    
    mdicServiceParam[ @"enabled" ] = [NSNumber numberWithBool:NO];
    if( isEnabled )
        mdicServiceParam[ @"enabled" ] = [NSNumber numberWithBool:YES];
    
    [self updateResource:urlService
              withHeader:nil
            andUrlParams:@{ @"service" : mdicServiceParam }
                  thenDo:^(NSDictionary * _Nullable dicResponseHeader, id  _Nullable idFullResponse)
     {
         NSDictionary * finalService = idFullResponse;
         if( idFullResponse != nil )
             finalService = idFullResponse[ @"service" ];
         
         if( doAfterUpdate != nil )
             doAfterUpdate( finalService, idFullResponse );
     }];
}

- ( void ) deleteServiceWithID:( NSString * ) uidService
                       thenDo:( void ( ^ ) ( bool isDeleted, id idFullResponse ) ) doAfterDelete
{
    NSString * urlService =[NSString stringWithFormat:@"%@/%@", IDENTITYV3_SERVICES_URN, uidService];
    [self deleteResource:urlService
              withHeader:nil
                  thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable idFullResponse)
     {
         if( doAfterDelete != nil )
             doAfterDelete( ( idFullResponse == nil ) ||
                           ( idFullResponse[ @"response" ] == nil ) ||
                           ( [idFullResponse[ @"response" ] isEqualToString:@""] ), idFullResponse );
     }];
}

- ( void ) listEndpointsWithInterface:( NSString * ) strInterfaceToFilterBy
                         andServiceID:( NSString * ) uidServiceToFilterBy
                               thenDo:( void ( ^ ) ( NSArray * arrEndpoints, id idFullResponse ) ) doAfterList
{
    NSString * urlEndpoints =[NSString stringWithFormat:@"%@", IDENTITYV3_ENDPOINTS_URN];
    NSURLComponents * queryString = [NSURLComponents componentsWithString:IDENTITYV3_ENDPOINTS_URN];
    NSMutableArray * arrQueryItems = [NSMutableArray array];
    
    if( strInterfaceToFilterBy != nil )
        [arrQueryItems addObject:[NSURLQueryItem queryItemWithName:@"interface"
                                                             value:strInterfaceToFilterBy]];
    
    if( uidServiceToFilterBy != nil )
        [arrQueryItems addObject:[NSURLQueryItem queryItemWithName:@"service_id"
                                                             value:uidServiceToFilterBy]];
    
    if( [arrQueryItems count ] > 0)
    {
        [queryString setQueryItems:arrQueryItems];
        urlEndpoints = [[queryString URL] absoluteString];
    }
    
    [self listResource:urlEndpoints
            withHeader:nil
          andUrlParams:nil
             insideKey:@"endpoints"
                thenDo:^(NSArray * _Nullable arrFound, id _Nullable dataResponse)
     {
         if( doAfterList != nil )
             doAfterList( arrFound, dataResponse );
     }];
}

- ( void ) createEndpointWithName:( NSString * ) nameEndpoint
                     andInterface:( NSString * ) strInterface
                           andURL:( NSString * ) urlEndpoint
                     andServiceID:( NSString * ) uidService
                      andRegionID:( NSString * ) uidRegion
                        isEnabled:( BOOL ) isEnabled
                           thenDo:( void ( ^ ) ( NSDictionary * createdEndpoint, id dicFullResponse ) ) doAfterCreate
{
    NSMutableDictionary * mdicEndpointParam = [NSMutableDictionary dictionaryWithObject:nameEndpoint
                                                                                 forKey:@"name"];
    
    if( strInterface != nil )
        mdicEndpointParam[ @"interface" ] = strInterface;
    
    if( urlEndpoint != nil )
        mdicEndpointParam[ @"url" ] = urlEndpoint;
    
    if( uidService != nil )
        mdicEndpointParam[ @"service_id" ] = uidService;
    
    if( uidRegion != nil )
        mdicEndpointParam[ @"region_id" ] = uidRegion;
    
    mdicEndpointParam[ @"enabled" ] = [NSNumber numberWithBool:NO];
    if( isEnabled )
        mdicEndpointParam[ @"enabled" ] = [NSNumber numberWithBool:YES];
    
    
    [self createResource:IDENTITYV3_ENDPOINTS_URN
              withHeader:nil
            andUrlParams:@{ @"endpoint" : mdicEndpointParam }
                  thenDo:^(NSDictionary * _Nullable dicResponseHeaders, id  _Nullable idFullResponse)
     {
         NSDictionary * finalService = idFullResponse;
         if( idFullResponse != nil )
             finalService = idFullResponse[ @"endpoint" ];
         
         if( doAfterCreate != nil )
             doAfterCreate( finalService, idFullResponse );
     }];
}

- ( void ) getdetailForEndpointWithID:( NSString * ) uidEndpoint
                               thenDo:( void ( ^ ) ( NSDictionary * dicService ) ) doAfterGetDetail
{
    NSString * urlEndpoint = [NSString stringWithFormat:@"%@/%@", IDENTITYV3_ENDPOINTS_URN, uidEndpoint];
    [self readResource:urlEndpoint
            withHeader:nil
          andUrlParams:nil
             insideKey:@"endpoint"
                thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable dataResponse)
     {
         if( doAfterGetDetail != nil )
             doAfterGetDetail( dicObjectFound );
     }];
}

- ( void ) updateEndpointWithID:( NSString * ) uidEndpoint
                        newName:( NSString * ) nameEndpoint
                   newInterface:( NSString * ) strInterface
                         newURL:( NSString * ) urlEndpoint
                   newServiceID:( NSString * ) uidService
                    newRegionID:( NSString * ) uidRegion
                      isEnabled:( BOOL ) isEnabled
                        thenDo:( void ( ^ ) ( NSDictionary * updatedEndpoint, id dicFullResponse ) ) doAfterUpdate
{
    NSString * urlEndpointResource =[NSString stringWithFormat:@"%@/%@", IDENTITYV3_ENDPOINTS_URN, uidEndpoint];
    NSMutableDictionary * mdicEndpointParam = [NSMutableDictionary dictionary];
    
    if( nameEndpoint != nil )
        mdicEndpointParam[ @"name" ] = nameEndpoint;

    if( strInterface != nil )
        mdicEndpointParam[ @"interface" ] = strInterface;
    
    if( urlEndpoint != nil )
        mdicEndpointParam[ @"url" ] = urlEndpoint;
    
    if( uidService != nil )
        mdicEndpointParam[ @"service_id" ] = uidService;
    
    if( uidRegion != nil )
        mdicEndpointParam[ @"region_id" ] = uidRegion;
    
    mdicEndpointParam[ @"enabled" ] = [NSNumber numberWithBool:NO];
    if( isEnabled )
        mdicEndpointParam[ @"enabled" ] = [NSNumber numberWithBool:YES];
    
    [self updateResource:urlEndpointResource
              withHeader:nil
            andUrlParams:@{ @"endpoint" : mdicEndpointParam }
                  thenDo:^(NSDictionary * _Nullable dicResponseHeader, id  _Nullable idFullResponse)
     {
         NSDictionary * finalService = idFullResponse;
         if( idFullResponse != nil )
             finalService = idFullResponse[ @"endpoint" ];
         
         if( doAfterUpdate != nil )
             doAfterUpdate( finalService, idFullResponse );
     }];
}

- ( void ) deleteEndpointWithID:( NSString * ) uidEndpoint
                         thenDo:( void ( ^ ) ( bool isDeleted, id idFullResponse ) ) doAfterDelete
{
    NSString * urlEndpoint =[NSString stringWithFormat:@"%@/%@", IDENTITYV3_ENDPOINTS_URN, uidEndpoint];
    [self deleteResource:urlEndpoint
              withHeader:nil
                  thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable idFullResponse)
     {
         if( doAfterDelete != nil )
             doAfterDelete( ( idFullResponse == nil ) ||
                           ( idFullResponse[ @"response" ] == nil ) ||
                           ( [idFullResponse[ @"response" ] isEqualToString:@""] ), idFullResponse );
     }];
}


#pragma mark - Users management
- ( void ) listUsersThenDo:( void ( ^ ) ( NSArray * arrUsers, id idFullResponse ) ) doAfterList
{
    [self listResource:IDENTITYV3_USERS_URN
            withHeader:nil
          andUrlParams:nil
             insideKey:@"users"
                thenDo:^(NSArray * _Nullable arrFound, id _Nullable dataResponse)
     {
         if( doAfterList != nil )
             doAfterList( arrFound, dataResponse );
         
     }];
}

- ( void ) createUserWithName:( NSString * ) nameUser
                  andPassword:( NSString * ) strPassword
               andDescription:( NSString * ) strDescription
                     andEmail:( NSString * ) strEmail
          andDefaultProjectID:( NSString * ) uidDefaultProjectOrTenant
                  andDomainID:( NSString * ) uidDomain
                    isEnabled:( BOOL ) isEnabled
                        thenDo:( void ( ^ ) ( NSDictionary * createdUser, id dicFullResponse ) ) doAfterCreate
{
    NSMutableDictionary * mdicUserParam = [NSMutableDictionary dictionaryWithObject:nameUser
                                                                              forKey:@"name"];
    if( strPassword != nil )
        mdicUserParam[ @"password" ] = strPassword;
    
    if( strDescription != nil )
        mdicUserParam[ @"description" ] = strDescription;

    if( strEmail != nil )
        mdicUserParam[ @"email" ] = strEmail;

    if( uidDefaultProjectOrTenant != nil )
        mdicUserParam[ @"default_project_id" ] = uidDefaultProjectOrTenant;

    if( uidDomain != nil )
        mdicUserParam[ @"domain_id" ] = uidDomain;
    
    mdicUserParam[ @"enabled" ] = [NSNumber numberWithBool:NO];
    if( isEnabled )
        mdicUserParam[ @"enabled" ] = [NSNumber numberWithBool:YES];
    
    [self createResource:IDENTITYV3_USERS_URN
              withHeader:nil
            andUrlParams:@{ @"user" : mdicUserParam }
                  thenDo:^(NSDictionary * _Nullable dicResponseHeaders, id  _Nullable idFullResponse)
     {
         NSDictionary * finalUser = idFullResponse;
         if( idFullResponse != nil )
             finalUser = idFullResponse[ @"user" ];
         
         if( doAfterCreate != nil )
             doAfterCreate( finalUser, idFullResponse );
     }];
}

- ( void ) getdetailForUserWithID:( NSString * ) uidUser
                            thenDo:( void ( ^ ) ( NSDictionary * dicUser ) ) doAfterGetDetail
{
    NSString * urlUser =[NSString stringWithFormat:@"%@/%@", IDENTITYV3_USERS_URN, uidUser];
    [self readResource:urlUser
            withHeader:nil
          andUrlParams:nil
             insideKey:@"user"
                thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable dataResponse)
     {
         if( doAfterGetDetail != nil )
             doAfterGetDetail( dicObjectFound );
     }];
}

- ( void ) updateUserWithID:( NSString * ) uidUser
                    newName:( NSString * ) nameUser
                newPassword:( NSString * ) strPassword
             newDescription:( NSString * ) strDescription
                   newEmail:( NSString * ) strEmail
        newDefaultProjectID:( NSString * ) uidDefaultProjectOrTenant
                newDomainID:( NSString * ) uidDomain
                  isEnabled:( BOOL ) isEnabled
                      thenDo:( void ( ^ ) ( NSDictionary * updatedUser, id dicFullResponse ) ) doAfterUpdate
{
    NSString * urlUser =[NSString stringWithFormat:@"%@/%@", IDENTITYV3_USERS_URN, uidUser];
    NSMutableDictionary * mdicUserParam = [NSMutableDictionary dictionary];
    
    if( nameUser != nil )
        mdicUserParam[ @"name" ] = nameUser;
    
    if( strPassword != nil )
        mdicUserParam[ @"password" ] = strPassword;
    
    if( strDescription != nil )
        mdicUserParam[ @"description" ] = strDescription;
    
    if( strEmail != nil )
        mdicUserParam[ @"email" ] = strEmail;
    
    if( uidDefaultProjectOrTenant != nil )
        mdicUserParam[ @"default_project_id" ] = uidDefaultProjectOrTenant;
    
    if( uidDomain != nil )
        mdicUserParam[ @"domain_id" ] = uidDomain;
    
    mdicUserParam[ @"enabled" ] = [NSNumber numberWithBool:NO];
    if( isEnabled )
        mdicUserParam[ @"enabled" ] = [NSNumber numberWithBool:YES];
    
    [self updateResource:urlUser
              withHeader:nil
            andUrlParams:@{ @"user" : mdicUserParam }
                  thenDo:^(NSDictionary * _Nullable dicResponseHeader, id  _Nullable idFullResponse)
     {
         NSDictionary * finalUser = idFullResponse;
         if( idFullResponse != nil )
             finalUser = idFullResponse[ @"user" ];
         
         if( doAfterUpdate != nil )
             doAfterUpdate( finalUser, idFullResponse );
     }];
}

- ( void ) deleteUserWithID:( NSString * ) uidUser
                      thenDo:( void ( ^ ) ( bool isDeleted, id idFullResponse ) ) doAfterDelete
{
    NSString * urlUser =[NSString stringWithFormat:@"%@/%@", IDENTITYV3_USERS_URN, uidUser];
    [self deleteResource:urlUser
              withHeader:nil
                  thenDo:^(NSDictionary * _Nullable dicObjectFound, id  _Nullable idFullResponse)
     {
         if( doAfterDelete != nil )
             doAfterDelete( ( idFullResponse == nil ) ||
                           ( idFullResponse[ @"response" ] == nil ) ||
                           ( [idFullResponse[ @"response" ] isEqualToString:@""] ), idFullResponse );
     }];
}


- ( void ) changeUserWithID:( NSString * ) uidUser
             andOldPassword:( NSString * ) strOldPassword
            withNewPassword:( NSString * ) strNewPassword
                     thenDo:( void ( ^ ) ( BOOL isAdded, id dicFullResponse ) ) doAfterChange
{
    NSString * urlPasswordForUser =[NSString stringWithFormat:@"%@/%@/%@", IDENTITYV3_USERS_URN, uidUser, IDENTITYV3_USERPASSWORD_URN];
    
    [self replaceResource:urlPasswordForUser
               withHeader:nil
             andUrlParams:nil
                   thenDo:^(NSDictionary * _Nullable dicResponseHeaders, id  _Nullable idFullResponse)
     {
         if( doAfterChange != nil )
             doAfterChange( ( idFullResponse == nil ) ||
                           ( idFullResponse[ @"response" ] == nil ) ||
                           ( [idFullResponse[ @"response" ] isEqualToString:@""] ), idFullResponse );
     }];
}

- ( void ) listGroupsForUserWithID:( NSString * ) uidUser
                            thenDo:( void ( ^ ) ( NSArray * arrGroups, id idFullResponse ) ) doAfterList
{
    NSString * urlGroupForUser =[NSString stringWithFormat:@"%@/%@/%@", IDENTITYV3_USERS_URN, uidUser, IDENTITYV3_USERGROUPS_URN];
    [self listResource:urlGroupForUser
            withHeader:nil
          andUrlParams:nil
             insideKey:@"groups"
                thenDo:^(NSArray * _Nullable arrFound, id _Nullable dataResponse)
     {
         if( doAfterList != nil )
             doAfterList( arrFound, dataResponse );
     }];
}

- ( void ) listProjectsForUserWithID:( NSString * ) uidUser
                              thenDo:( void ( ^ ) ( NSArray * arrProjects, id idFullResponse ) ) doAfterList
{
    NSString * urlGroupForUser =[NSString stringWithFormat:@"%@/%@/%@", IDENTITYV3_USERS_URN, uidUser, IDENTITYV3_USERPROJECTS_URN];
    [self listResource:urlGroupForUser
            withHeader:nil
          andUrlParams:nil
             insideKey:@"projects"
                thenDo:^(NSArray * _Nullable arrFound, id _Nullable dataResponse)
     {
         if( doAfterList != nil )
             doAfterList( arrFound, dataResponse );
     }];
}


@end
