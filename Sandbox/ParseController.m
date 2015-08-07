//
//  ParseController.m
//  Sandbox
//
//  Created by Ken M. Haggerty on 8/7/15.
//  Copyright (c) 2015 MCMDI. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "ParseController.h"
#import "AKDebugger.h"
#import "AKGenerics.h"
#import <Parse/Parse.h>

#pragma mark - // DEFINITIONS (Private) //

@interface ParseController ()
@property (nonatomic, strong) PFInstallation *currentInstallation;

// GENERAL //
- (void)setup;
- (void)teardown;

// CONVENIENCE //
+ (id)sharedController;
+ (PFInstallation *)currentInstallation;

// OBSERVERS //
- (void)addObserversToCentralDispatch;
- (void)removeObserversFromCentralDispatch;

// RESPONDERS //

@end

@implementation ParseController

#pragma mark - // SETTERS AND GETTERS //

@synthesize currentInstallation = _currentInstallation;

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

#pragma mark - // PUBLIC METHODS (Push Notifications) //

+ (BOOL)shouldProcessPushNotificationWithData:(NSDictionary *)notificationPayload
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeValidator customCategories:@[AKD_PUSH_NOTIFICATIONS] message:nil];
    
    NSString *installationId = [notificationPayload objectForKey:PUSH_NOTIFICATION_KEY_INSTALLATION];
    if ([installationId isEqualToString:[AKParseController currentInstallation].objectId]) return NO;
    
    return YES;
}

+ (void)pushNotificationWithData:(NSDictionary *)data recipients:(NSArray *)recipients
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator customCategories:@[AKD_PUSH_NOTIFICATIONS, AKD_PARSE] message:nil];
    
    PFPush *push = [[PFPush alloc] init];
    NSMutableDictionary *mutableData = [NSMutableDictionary dictionaryWithDictionary:data];
    [mutableData setObject:[AKParseController currentInstallation].objectId forKey:PUSH_NOTIFICATION_KEY_INSTALLATION];
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
    
    static ParseController *_sharedController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedController = [[ParseController alloc] init];
    });
    return _sharedController;
}

+ (PFInstallation *)currentInstallation
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_PARSE] message:nil];
    
    return [[ParseController sharedController] currentInstallation];
}

#pragma mark - // PRIVATE METHODS (Observers) //

- (void)addObserversToCentralDispatch
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_NOTIFICATION_CENTER] message:nil];
}

- (void)removeObserversFromCentralDispatch
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_NOTIFICATION_CENTER] message:nil];
}

#pragma mark - // PRIVATE METHODS (Responders) //

@end