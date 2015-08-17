//
//  ParseController.h
//  Sandbox
//
//  Created by Ken M. Haggerty on 8/7/15.
//  Copyright (c) 2015 MCMDI. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

#define NOTIFICATION_PARSECONTROLLER_CURRENTINSTALLATION_DID_CHANGE @"kNotificationParseControllerCurrentInstallationDidChange"
#define NOTIFICATION_PARSECONTROLLER_CURRENTACCOUNT_DID_CHANGE @"kNotificationParseControllerCurrentAccountDidChange"

#define PUSHNOTIFICATION_KEY_INSTALLATIONID @"installationId"
#define PUSHNOTIFICATION_KEY_TYPE @"pushType"
#define PUSHNOTIFICATION_TYPE_READRECEIPT @"readReceipt"
#define PUSHNOTIFICATION_TYPE_NEWMESSAGE @"newMessage"
#define PUSHNOTIFICATION_KEY_MESSAGEID @"messageId"
#define PUSHNOTIFICATION_KEY_SENDER @"sender"
#define PUSHNOTIFICATION_KEY_TEXT @"text"
#define PUSHNOTIFICATION_KEY_SENDDATE @"sendDate"
#define PUSHNOTIFICATION_RECIPIENT_GLOBAL @"global"

@interface ParseController : NSObject

// SETUP //

+ (void)setupApplication:(UIApplication *)application withLaunchOptions:(NSDictionary *)launchOptions;
+ (void)setDeviceTokenFromData:(NSData *)deviceToken;

// ACCOUNT //

+ (NSString *)getAccountIdForUsername:(NSString *)username;
+ (BOOL)createAccountWithEmail:(NSString *)email password:(NSString *)password;
+ (BOOL)logInWithEmail:(NSString *)email password:(NSString *)password;
+ (void)logOut;

// CREATORS //

+ (NSString *)createParseObjectWithClass:(NSString *)className info:(NSDictionary *)info;

// GETTERS //

+ (PFObject *)getObjectWithQuery:(PFQuery *)query;

// EDITORS //

+ (void)messageWasRead:(NSString *)messageId;

// DELETORS //

+ (void)removeCurrentInstallationFromObject:(PFObject *)object;

// PUSH NOTIFICATIONS //

+ (BOOL)shouldProcessPushNotificationWithData:(NSDictionary *)notificationPayload;
+ (void)pushNotificationWithData:(NSDictionary *)data recipients:(NSArray *)recipients;
+ (NSDictionary *)translatePushNotification:(NSDictionary *)pushNotification;

// METRICS //

+ (void)trackAppOpenedWithRemoteNotificationPayload:(NSDictionary *)userInfo;

@end