//
//  ParseController.m
//  Sandbox
//
//  Created by Ken M. Haggerty on 8/7/15.
//  Copyright (c) 2015 MCMDI. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "ParseController+PRIVATE.h"
#import "AKDebugger.h"
#import "AKGenerics.h"
#import "CentralDispatch.h"
#import "AKPrivateInfo.h"

#pragma mark - // DEFINITIONS (Private) //

#define PARSE_KEY_INSTALLATIONS @"installations"

@interface ParseController ()
@property (nonatomic, strong) PFInstallation *currentInstallation;
@property (nonatomic, strong) PFUser *currentAccount;

// GENERAL //

- (void)setup;
- (void)teardown;

// CONVENIENCE //

+ (id)sharedController;
+ (PFInstallation *)currentInstallation;

@end

@implementation ParseController

#pragma mark - // SETTERS AND GETTERS //

@synthesize currentInstallation = _currentInstallation;
@synthesize currentAccount = _currentAccount;

- (void)setCurrentInstallation:(PFInstallation *)currentInstallation
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter customCategories:@[AKD_PARSE] message:nil];
    
    if ([AKGenerics object:currentInstallation isEqualToObject:_currentInstallation]) return;
    
    _currentInstallation = currentInstallation;
    
    NSMutableArray *channels = [NSMutableArray arrayWithArray:currentInstallation.channels];
    if (![channels containsObject:PUSHNOTIFICATION_RECIPIENT_GLOBAL])
    {
        [channels addObject:PUSHNOTIFICATION_RECIPIENT_GLOBAL];
    }
    if (![AKGenerics object:channels isEqualToObject:currentInstallation.channels])
    {
        [currentInstallation setChannels:channels];
        NSError *error;
        BOOL success = [currentInstallation save:&error];
        if (error)
        {
            [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeSetter customCategories:@[AKD_PARSE] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
        }
        if (!success)
        {
            [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeSetter customCategories:@[AKD_PARSE] message:[NSString stringWithFormat:@"Could not %@ %@", NSStringFromSelector(@selector(save)), stringFromVariable(currentInstallation)]];
        }
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (currentInstallation) [userInfo setObject:currentInstallation forKey:NOTIFICATION_OBJECT_KEY];
    [CentralDispatch postNotificationName:NOTIFICATION_PARSECONTROLLER_CURRENTINSTALLATION_DID_CHANGE object:nil userInfo:userInfo];
}

- (PFInstallation *)currentInstallation
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_PARSE] message:nil];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [self setCurrentInstallation:currentInstallation];
    return currentInstallation;
}

- (void)setCurrentAccount:(PFUser *)currentAccount
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter customCategories:@[AKD_PARSE] message:nil];
    
    if ([AKGenerics object:currentAccount isEqualToObject:_currentAccount]) return;
    
    NSString *oldAccountId = _currentAccount.objectId;
    NSString *newAccountId = currentAccount.objectId;
    _currentAccount = currentAccount;
    
    if (![AKGenerics object:oldAccountId isEqualToObject:newAccountId])
    {
        PFInstallation *currentInstallation = [ParseController currentInstallation];
        NSMutableArray *channels = [NSMutableArray arrayWithArray:currentInstallation.channels];
        if (oldAccountId && [channels containsObject:oldAccountId])
        {
            [channels removeObject:oldAccountId];
        }
        if (newAccountId && ![channels containsObject:newAccountId])
        {
            [channels addObject:newAccountId];
        }
        if (![AKGenerics object:channels isEqualToObject:currentInstallation.channels])
        {
            [currentInstallation setChannels:channels];
            NSError *error;
            BOOL success = [currentInstallation save:&error];
            if (error)
            {
                [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeSetter customCategories:@[AKD_PARSE] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
            }
            if (!success)
            {
                [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeSetter customCategories:@[AKD_PARSE] message:[NSString stringWithFormat:@"Could not %@ %@", NSStringFromSelector(@selector(save)), stringFromVariable(currentInstallation)]];
            }
        }
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (currentAccount) [userInfo setObject:currentAccount forKey:NOTIFICATION_OBJECT_KEY];
    [CentralDispatch postNotificationName:NOTIFICATION_PARSECONTROLLER_CURRENTACCOUNT_DID_CHANGE object:nil userInfo:userInfo];
}

- (PFUser *)currentAccount
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_PARSE] message:nil];
    
    PFUser *currentAccount = [PFUser currentUser];
    [self setCurrentAccount:currentAccount];
    return currentAccount;
}

#pragma mark - // INITS AND LOADS //

- (id)init
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_PARSE] message:nil];
    
    self = [super init];
    if (!self)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeCritical methodType:AKMethodTypeSetup customCategories:@[AKD_PARSE] message:[NSString stringWithFormat:@"Could not initialize %@", stringFromVariable(self)]];
        return nil;
    }
    
    [self setup];
    return self;
}

- (void)awakeFromNib
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_PARSE ] message:nil];
    
    [super awakeFromNib];
    [self setup];
}

- (void)dealloc
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_PARSE] message:nil];
    
    [self teardown];
}

#pragma mark - // PUBLIC METHODS (Setup) //

+ (void)setupApplication:(UIApplication *)application withLaunchOptions:(NSDictionary *)launchOptions
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_PARSE] message:nil];
    
    [Parse enableLocalDatastore];
    [Parse setApplicationId:[AKPrivateInfo parseApplicationId] clientKey:[AKPrivateInfo parseClientKey]];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    if (application.applicationState != UIApplicationStateBackground)
    {
        // Track an app open here if we launch with a push, unless
        // "content_available" was used to trigger a background push (introduced
        // in iOS 7). In that case, we skip tracking here to avoid double
        // counting the app-open.
        BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
        BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
        BOOL noPushPayload = ![launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (preBackgroundPush || oldPushHandlerOnly || noPushPayload)
        {
            [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        }
    }
}

+ (void)setDeviceTokenFromData:(NSData *)deviceToken
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_PARSE] message:nil];
    
    PFInstallation *currentInstallation = [ParseController currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

#pragma mark - // PUBLIC METHODS (Account) //

+ (BOOL)createAccountWithEmail:(NSString *)email password:(NSString *)password
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator customCategories:@[AKD_ACCOUNTS, AKD_PARSE] message:nil];
    
    PFUser *currentAccount = [PFUser user];
    [currentAccount setUsername:email];
    [currentAccount setPassword:password];
    NSError *error;
    BOOL success = [currentAccount signUp:&error];
    if (error)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeCreator customCategories:@[AKD_ACCOUNTS, AKD_PARSE] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
    }
    if (!success)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeCreator customCategories:@[AKD_PARSE, AKD_ACCOUNTS] message:[NSString stringWithFormat:@"Could not create %@", stringFromVariable(account)]];
        return NO;
    }
    
    [[ParseController sharedController] setCurrentAccount:currentAccount];
    return YES;
}

+ (BOOL)logInWithEmail:(NSString *)email password:(NSString *)password
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:@[AKD_ACCOUNTS, AKD_PARSE] message:nil];
    
    NSError *error;
    PFUser *currentAccount = [PFUser logInWithUsername:email password:password error:&error];
    if (error)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeUnspecified customCategories:@[AKD_ACCOUNTS, AKD_PARSE] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
    }
    if (!currentAccount)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeInfo methodType:AKMethodTypeUnspecified customCategories:@[AKD_ACCOUNTS, AKD_PARSE] message:[NSString stringWithFormat:@"Could not log in %@", email]];
        return NO;
    }
    
    [[ParseController sharedController] setCurrentAccount:currentAccount];
    return YES;
}

+ (void)logOut
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:@[AKD_ACCOUNTS, AKD_PARSE] message:nil];
    
    [PFUser logOut];
    [[ParseController sharedController] setCurrentAccount:nil];
}

#pragma mark - // PUBLIC METHODS (Creators) //

+ (NSString *)createParseObjectWithClass:(NSString *)className info:(NSDictionary *)info
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator customCategories:@[AKD_PARSE] message:nil];
    
    PFObject *object = [PFObject objectWithClassName:className];
    PFRelation *installations = [object relationForKey:PARSE_KEY_INSTALLATIONS];
    [installations addObject:[ParseController currentInstallation]];
    if (info)
    {
        for (id key in [info allKeys])
        {
            [object setObject:[info objectForKey:key] forKey:key];
        }
    }
    NSError *error;
    BOOL success = [object save:&error];
    if (error)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeCreator customCategories:@[AKD_PARSE] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
    }
    if (!success)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeCreator customCategories:@[AKD_PARSE] message:[NSString stringWithFormat:@"Could not %@ %@", NSStringFromSelector(@selector(save)), stringFromVariable(object)]];
        return nil;
    }
    
    return object.objectId;
}

#pragma mark - // PUBLIC METHODS (Getters) //

+ (PFObject *)getObjectWithQuery:(PFQuery *)query
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_PARSE] message:nil];
    
    return [query getFirstObject];
}

#pragma mark - // PUBLIC METHODS (Deletors) //

+ (void)removeCurrentInstallationFromObject:(PFObject *)object
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeDeletor customCategories:@[AKD_PARSE] message:nil];
    
    PFRelation *installations = [object relationForKey:PARSE_KEY_INSTALLATIONS];
    [installations removeObject:[ParseController currentInstallation]];
    [object saveEventually];
}

#pragma mark - // PUBLIC METHODS (Push Notifications) //

+ (BOOL)shouldProcessPushNotificationWithData:(NSDictionary *)notificationPayload
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeValidator customCategories:@[AKD_PUSH_NOTIFICATIONS] message:nil];
    
    NSString *installationId = [notificationPayload objectForKey:PUSHNOTIFICATION_KEY_INSTALLATIONID];
    if ([installationId isEqualToString:[ParseController currentInstallation].objectId]) return NO;
    
    return YES;
}

+ (void)pushNotificationWithData:(NSDictionary *)data recipients:(NSArray *)recipients
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator customCategories:@[AKD_PUSH_NOTIFICATIONS, AKD_PARSE] message:nil];
    
    PFPush *push = [[PFPush alloc] init];
    NSMutableDictionary *mutableData = [NSMutableDictionary dictionaryWithDictionary:data];
    [mutableData setObject:[ParseController currentInstallation].objectId forKey:PUSHNOTIFICATION_KEY_INSTALLATIONID];
    [push setData:mutableData];
    [push setChannels:recipients];
    NSError *error;
    BOOL success = [push sendPush:&error];
    if (error)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeCreator customCategories:@[AKD_PARSE] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
    }
    if (!success)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeCreator customCategories:@[AKD_PARSE] message:[NSString stringWithFormat:@"Could not send push notification"]];
    }
}

+ (NSDictionary *)translatePushNotification:(NSDictionary *)pushNotification
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:@[AKD_PARSE, AKD_PUSH_NOTIFICATIONS] message:nil];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:[pushNotification objectForKey:PUSHNOTIFICATION_KEY_TYPE] forKey:PUSHNOTIFICATION_KEY_TYPE];
    [dictionary setObject:[pushNotification objectForKey:PUSHNOTIFICATION_KEY_MESSAGEID] forKey:PUSHNOTIFICATION_KEY_MESSAGEID];
    [dictionary setObject:[pushNotification objectForKey:PUSHNOTIFICATION_KEY_SENDER] forKey:PUSHNOTIFICATION_KEY_SENDER];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSz"];
    [dictionary setObject:[dateFormat dateFromString:[[pushNotification objectForKey:PUSHNOTIFICATION_KEY_SENDDATE] objectForKey:@"iso"]] forKey:PUSHNOTIFICATION_KEY_SENDDATE];
    [dictionary setObject:[[pushNotification objectForKey:@"aps"] objectForKey:@"alert"] forKey:PUSHNOTIFICATION_KEY_TEXT];
    return dictionary;
}

#pragma mark - // PUBLIC METHODS (Metrics) //

+ (void)trackAppOpenedWithRemoteNotificationPayload:(NSDictionary *)userInfo
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:@[AKD_PARSE, AKD_PUSH_NOTIFICATIONS] message:nil];
    
    [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
}

#pragma mark - // CATEGORY METHODS (Private) //

+ (PFUser *)currentAccount
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_ACCOUNTS, AKD_PARSE] message:nil];
    
    return [[ParseController sharedController] currentAccount];
}

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS (General) //

- (void)setup
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_PARSE] message:nil];
}

- (void)teardown
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_PARSE] message:nil];
}

#pragma mark - // PRIVATE METHODS (Convenience) //

+ (id)sharedController
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_PARSE] message:nil];
    
    static dispatch_once_t once;
    static ParseController *sharedController;
    dispatch_once(&once, ^{
        sharedController = [[ParseController alloc] init];
    });
    return sharedController;
}

+ (PFInstallation *)currentInstallation
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_PARSE] message:nil];
    
    return [[ParseController sharedController] currentInstallation];
}

@end