//
//  LoginManager.m
//  Sandbox
//
//  Created by Ken M. Haggerty on 8/7/15.
//  Copyright (c) 2015 MCMDI. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "LoginManager+Delegate.h"
#import "AKDebugger.h"
#import "AKGenerics.h"
#import "SyncEngine.h"
#import "CentralDispatch.h"

#pragma mark - // DEFINITIONS (Private) //

@interface LoginManager ()
@property (nonatomic, strong) NSString *currentUser;

// GENERAL //

- (void)setup;
- (void)teardown;

// CONVENIENCE //

+ (id)sharedManager;

// OBSERVERS //

- (void)addObserversToSyncEngine;
- (void)removeObserversFromSyncEngine;

// RESPONDERS //

- (void)currentUserDidChange:(NSNotification *)notification;

@end

@implementation LoginManager

#pragma mark - // SETTERS AND GETTERS //

@synthesize currentUser = _currentUser;

- (void)setCurrentUser:(NSString *)currentUser
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter customCategories:@[AKD_ACCOUNTS] message:nil];
    
    if ([AKGenerics object:currentUser isEqualToObject:_currentUser]) return;
    
    _currentUser = currentUser;
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (currentUser) [userInfo setObject:currentUser forKey:NOTIFICATION_OBJECT_KEY];
    [CentralDispatch postNotificationName:NOTIFICATION_CURRENTUSER_DID_CHANGE object:nil userInfo:userInfo];
}

#pragma mark - // INITS AND LOADS //

- (id)init
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_ACCOUNTS] message:nil];
    
    self = [super init];
    if (!self)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeCritical methodType:AKMethodTypeSetup customCategories:@[AKD_ACCOUNTS] message:[NSString stringWithFormat:@"Could not instantiate %@", stringFromVariable(self)]];
        return nil;
    }
    
    [self setup];
    return self;
}

- (void)awakeFromNib
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_ACCOUNTS] message:nil];
    
    [super awakeFromNib];
    [self setup];
}

- (void)dealloc
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_ACCOUNTS] message:nil];
    
    [self teardown];
}

#pragma mark - // PUBLIC METHODS //

+ (BOOL)createAccountWithEmail:(NSString *)email password:(NSString *)password
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator customCategories:@[AKD_ACCOUNTS] message:nil];
    
    return [SyncEngine createAccountWithEmail:email password:password];
}

+ (BOOL)logInWithEmail:(NSString *)email password:(NSString *)password
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:@[AKD_ACCOUNTS] message:nil];
    
    return [SyncEngine logInWithEmail:email password:password];
}

+ (void)logOut
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:@[AKD_ACCOUNTS] message:nil];
    
    [SyncEngine logOut];
}

#pragma mark - // CATEGORY METHODS (Delegate) //

#pragma mark - // DELEGATED METHODS (AcccountDelegate) //

+ (id <AccountDelegate>)delegateForCentralDispatch
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
    
    return [LoginManager sharedManager];
}

- (NSString *)currentUser
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_ACCOUNTS] message:nil];
    
    if (_currentUser) return _currentUser;
    
    [self setCurrentUser:[SyncEngine currentUser]];
    return _currentUser;
}

- (NSString *)currentUsername
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_ACCOUNTS] message:nil];
    
    return _currentUser;
}

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS (General) //

- (void)setup
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_ACCOUNTS] message:nil];
    
    [self addObserversToSyncEngine];
}

- (void)teardown
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_ACCOUNTS] message:nil];
    
    [self removeObserversFromSyncEngine];
}

#pragma mark - // PRIVATE METHODS (Convenience) //

+ (id)sharedManager
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_ACCOUNTS] message:nil];
    
    static dispatch_once_t once;
    static LoginManager *sharedManager;
    dispatch_once(&once, ^{
        sharedManager = [[LoginManager alloc] init];
    });
    return sharedManager;
}

#pragma mark - // PRIVATE METHODS (Observers) //

- (void)addObserversToSyncEngine
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [SyncEngine startEngine];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentUserDidChange:) name:NOTIFICATION_SYNCENGINE_CURRENTUSER_DID_CHANGE object:nil];
}

- (void)removeObserversFromSyncEngine
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_SYNCENGINE_CURRENTUSER_DID_CHANGE object:nil];
}

#pragma mark - // PRIVATE METHODS (Responders) //

- (void)currentUserDidChange:(NSNotification *)notification
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[LoginManager sharedManager] setCurrentUser:[notification.userInfo objectForKey:NOTIFICATION_OBJECT_KEY]];
}

@end