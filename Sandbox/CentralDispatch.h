//
//  CentralDispatch.h
//  Sandbox
//
//  Created by Ken M. Haggerty on 8/7/15.
//  Copyright (c) 2015 MCMDI. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

#define NOTIFICATION_CURRENTUSER_DID_CHANGE @"kNotificationCurrentUserDidChange"
#define NOTIFICATION_CURRENTUSERNAME_DID_CHANGE @"kNotificationCurrentUsernameDidChange"
#define NOTIFICATION_MESSAGE_WAS_CREATED @"kNotificationMessageWasCreated"

@interface CentralDispatch : NSObject

// ACCOUNT //

+ (NSString *)currentUser;
+ (NSString *)currentUsername;

// LOGIN //

+ (void)presentLogin;
+ (void)dismissLogin;
+ (void)presentLogout;
+ (void)dismissLogout;

// NOTIFICATION CENTER //

+ (void)postNotificationName:(NSString *)notificationName object:(id)object userInfo:(NSDictionary *)userInfo;

// PUSH NOTIFICATIONS //

+ (void)processRemoteNotification:(NSDictionary *)userInfo;

@end