//
//  SandboxCentralDispatch.m
//  Sandbox
//
//  Created by Ken M. Haggerty on 8/7/15.
//  Copyright (c) 2015 MCMDI. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "SandboxCentralDispatch+PRIVATE.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#import "LoginManager+Delegate.h"
#import "SyncEngine+Delegate.h"
#import "RootViewController.h"

#pragma mark - // DEFINITIONS (Private) //

@interface SandboxCentralDispatch ()
@property (nonatomic, strong) id <AccountDelegate> accountDelegate;
@property (nonatomic, strong) id <PushNotificationDelegate> pushNotificationDelegate;
@property (nonatomic, strong) id <LoginControllerDelegate> loginControllerDelegate;

// GENERAL //

- (void)setup;
- (void)teardown;

// CONVENIENCE //

+ (id)sharedDispatch;

@end

@implementation SandboxCentralDispatch

#pragma mark - // SETTERS AND GETTERS //

@synthesize accountDelegate = _accountDelegate;
@synthesize pushNotificationDelegate = _pushNotificationDelegate;
@synthesize loginControllerDelegate = _loginControllerDelegate;

- (id <AccountDelegate>)accountDelegate
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_ACCOUNTS] message:nil];
    
    if (_accountDelegate) return _accountDelegate;
    
    [self setAccountDelegate:[LoginManager delegateForCentralDispatch]];
    return _accountDelegate;
}

- (id <PushNotificationDelegate>)pushNotificationDelegate
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_PUSH_NOTIFICATIONS] message:nil];
    
    if (_pushNotificationDelegate) return _pushNotificationDelegate;
    
    [self setPushNotificationDelegate:[SyncEngine delegateForCentralDispatch]];
    return _pushNotificationDelegate;
}

#pragma mark - // INITS AND LOADS //

- (id)init
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    self = [super init];
    if (!self)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeCritical methodType:AKMethodTypeSetup tags:nil message:[NSString stringWithFormat:@"Could not instantiate %@", stringFromVariable(self)]];
        return nil;
    }
    
    [self setup];
    return self;
}

- (void)awakeFromNib
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    [super awakeFromNib];
    [self setup];
}

- (void)dealloc
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    [self teardown];
}

#pragma mark - // PUBLIC METHODS (Account) //

+ (User *)currentUser
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_ACCOUNTS] message:nil];
    
    return [[[SandboxCentralDispatch sharedDispatch] accountDelegate] currentUser];
}

+ (NSString *)currentUsername
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_ACCOUNTS] message:nil];
    
    return [[[SandboxCentralDispatch sharedDispatch] accountDelegate] currentUsername];
}

#pragma mark - // PUBLIC METHODS (Login) //

+ (void)presentLogin
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI, AKD_ACCOUNTS] message:nil];
    
    [[[SandboxCentralDispatch sharedDispatch] loginControllerDelegate] presentLogin];
}

+ (void)dismissLogin
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI, AKD_ACCOUNTS] message:nil];
    
    [[[SandboxCentralDispatch sharedDispatch] loginControllerDelegate] dismissLogin];
}

+ (void)presentLogout
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI, AKD_ACCOUNTS] message:nil];
    
    [[[SandboxCentralDispatch sharedDispatch] loginControllerDelegate] presentLogout];
}

+ (void)dismissLogout
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_UI, AKD_ACCOUNTS] message:nil];
    
    [[[SandboxCentralDispatch sharedDispatch] loginControllerDelegate] dismissLogout];
}

#pragma mark - // PUBLIC METHODS (Push Notifications) //

+ (void)processRemoteNotification:(NSDictionary *)userInfo
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_PUSH_NOTIFICATIONS] message:nil];
    
    [[[SandboxCentralDispatch sharedDispatch] pushNotificationDelegate] processRemoteNotification:userInfo];
}

#pragma mark - // CATEGORY METHODS (Private) //

+ (void)setAccountDelegate:(id<AccountDelegate>)delegate
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_ACCOUNTS] message:nil];
    
    [[SandboxCentralDispatch sharedDispatch] setAccountDelegate:delegate];
}

+ (void)setLoginControllerDelegate:(id<LoginControllerDelegate>)delegate
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_UI] message:nil];
    
    [[SandboxCentralDispatch sharedDispatch] setLoginControllerDelegate:delegate];
}

+ (void)setPushNotificationDelegate:(id<PushNotificationDelegate>)delegate
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_PUSH_NOTIFICATIONS] message:nil];
    
    [[SandboxCentralDispatch sharedDispatch] setPushNotificationDelegate:delegate];
}

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS (General) //

- (void)setup
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
}

- (void)teardown
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
}

#pragma mark - // PRIVATE METHODS (Convenience) //

+ (id)sharedDispatch
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    static dispatch_once_t once;
    static SandboxCentralDispatch *sharedDispatch;
    dispatch_once(&once, ^{
        sharedDispatch = [[SandboxCentralDispatch alloc] init];
    });
    return sharedDispatch;
}

@end