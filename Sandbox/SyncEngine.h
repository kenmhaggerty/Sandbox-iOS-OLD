//
//  SyncEngine.h
//  Sandbox
//
//  Created by Ken M. Haggerty on 8/7/15.
//  Copyright (c) 2015 MCMDI. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>
#import "User.h"
#import "Message.h"

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

#define NOTIFICATION_SYNCENGINE_CURRENTUSER_DID_CHANGE @"kNotificationSyncEngineCurrentUserDidChange"

@interface SyncEngine : NSObject

// GENERAL //

+ (void)startEngine;

// ACCOUNT //

+ (User *)currentUser;
+ (NSString *)getAccountIdForUsername:(NSString *)username;
+ (BOOL)createAccountWithEmail:(NSString *)email password:(NSString *)password;
+ (BOOL)logInWithEmail:(NSString *)email password:(NSString *)password;
+ (void)logOut;

// MESSAGE //

+ (BOOL)sendMessage:(Message *)message;
+ (void)messageWasRead:(NSString *)messageId;
+ (void)messageWasDeleted:(NSString *)messageId;

@end
