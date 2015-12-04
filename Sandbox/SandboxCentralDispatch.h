//
//  SandboxCentralDispatch.h
//  Sandbox
//
//  Created by Ken M. Haggerty on 8/7/15.
//  Copyright (c) 2015 MCMDI. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>
#import "User.h"

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

#define NOTIFICATION_CURRENTUSER_DID_CHANGE @"kNotificationCurrentUserDidChange"
#define NOTIFICATION_CURRENTUSERNAME_DID_CHANGE @"kNotificationCurrentUsernameDidChange"
#define NOTIFICATION_MESSAGE_WAS_CREATED @"kNotificationMessageWasCreated"

@interface SandboxCentralDispatch : NSObject

// ACCOUNT //

+ (User *)currentUser;
+ (NSString *)currentUsername;

// LOGIN //

+ (void)presentLogin;
+ (void)dismissLogin;
+ (void)presentLogout;
+ (void)dismissLogout;

// PUSH NOTIFICATIONS //

+ (void)processRemoteNotification:(NSDictionary *)userInfo;

@end
