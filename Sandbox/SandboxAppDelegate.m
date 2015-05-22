//
//  SandboxAppDelegate.m
//  Sandbox
//
//  Created by Ken Haggerty on 5/2/12.
//  Copyright (c) 2012 MCMDI. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "SandboxAppDelegate.h"
#import "AKDebugger.h"
#import "SandboxPrivateInfo.h"
#import <Parse/Parse.h>
#import "DataManager.h"

#pragma mark - // DEFINITIONS (Private) //

@interface SandboxAppDelegate ()
+ (void)processRemoteNotification:(NSDictionary *)userInfo;
@end

@implementation SandboxAppDelegate

#pragma mark - // SETTERS AND GETTERS //

@synthesize window = _window;

#pragma mark - // INITS AND LOADS //

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:nil message:nil];
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:nil message:nil];
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:nil message:nil];
    
    [Parse enableLocalDatastore];
    [Parse setApplicationId:[SandboxPrivateInfo parseApplicationId] clientKey:[SandboxPrivateInfo parseClientKey]];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    if (application.applicationState != UIApplicationStateBackground)
    {
        // Track an app open here if we launch with a push, unless
        // "content_available" was used to trigger a background push (introduced
        // in iOS 7). In that case, we skip tracking here to avoid double
        // counting the app-open.
        BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
        BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
        BOOL noPushPayload = ![launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
            [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        }
    }
    
    NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notificationPayload) [SandboxAppDelegate processRemoteNotification:notificationPayload];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:nil message:nil];
    
    if (application.applicationState == UIApplicationStateInactive)
    {
        // The application was just brought from the background to the foreground,
        // so we consider the app as having been "opened by a push notification."
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
    
    [SandboxAppDelegate processRemoteNotification:userInfo];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:nil message:nil];
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:nil message:nil];
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:nil message:nil];
    
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - // PUBLIC FUNCTIONS //

#pragma mark - // DELEGATED FUNCTIONS (Parse) //

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:nil message:nil];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

#pragma mark - // PRIVATE FUNCTIONS //

+ (void)processRemoteNotification:(NSDictionary *)userInfo
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator customCategories:nil message:nil];
    
    NSString *installationId = [userInfo objectForKey:@"installationId"];
    if ([installationId isEqualToString:[[PFInstallation currentInstallation] objectId]]) return;
    
    NSString *pushType = [userInfo objectForKey:@"pushType"];
    NSString *messageId = [userInfo objectForKey:NSStringFromSelector(@selector(messageId))];
    if ([pushType isEqualToString:@"messageRead"])
    {
        Message *message = [DataManager getMessageWithId:messageId];
        if (message) [DataManager userDidReadMessage:message andBroadcast:NO];
    }
    else if ([pushType isEqualToString:@"newMessage"])
    {
        NSString *sender = [userInfo objectForKey:NSStringFromSelector(@selector(sender))];
        NSString *recipient = [DataManager currentUser];
        NSString *text = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
        NSString *jsonDate = [[userInfo objectForKey:NSStringFromSelector(@selector(sendDate))] objectForKey:@"iso"];
        NSDate *sendDate;
        if (jsonDate)
        {
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSz"];
            sendDate = [dateFormat dateFromString:jsonDate];
        }
        if (sender && recipient && text && sendDate && messageId)
        {
            [DataManager createMessageWithText:text fromUser:sender toUser:[DataManager currentUser] onDate:sendDate withId:messageId andBroadcast:NO];
        }
    }
}

@end