//
//  CentralDispatch+PRIVATE.h
//  Sandbox
//
//  Created by Ken M. Haggerty on 8/9/15.
//  Copyright (c) 2015 MCMDI. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import "CentralDispatch.h"

#pragma mark - // PROTOCOLS //

@protocol CentralDispatchDelegate <NSObject>
@optional
+ (id)delegateForCentralDispatch;
@end

@protocol AccountDelegate <CentralDispatchDelegate>
- (NSString *)currentUser;
- (NSString *)currentUsername;
@end

@protocol LoginControllerDelegate <CentralDispatchDelegate>
- (void)presentLogin;
- (void)dismissLogin;
- (void)presentLogout;
- (void)dismissLogout;
@end

@protocol PushNotificationDelegate <CentralDispatchDelegate>
- (void)processRemoteNotification:(NSDictionary *)userInfo;
@end

#pragma mark - // DEFINITIONS (Public) //

@interface CentralDispatch (PRIVATE)
+ (void)setAccountDelegate:(id <AccountDelegate>)delegate;
+ (void)setLoginControllerDelegate:(id <LoginControllerDelegate>)delegate;
+ (void)setPushNotificationDelegate:(id <PushNotificationDelegate>)delegate;
@end