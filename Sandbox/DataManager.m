//
//  DataManager.m
//  Databox
//
//  Created by Ken M. Haggerty on 7/11/13.
//  Copyright (c) 2013 Eureka Valley Co. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "DataManager.h"
#import "AKDebugger.h"
#import "AKGenerics.h"
#import "CoreDataController.h"
#import "Message.h"

#pragma mark - // DEFINITIONS (Private) //

@interface DataManager ()
@property (nonatomic, strong) NSString *currentUser;
+ (id)sharedManager;
- (void)setup;
- (void)teardown;
@end

@implementation DataManager

#pragma mark - // SETTERS AND GETTERS //

- (void)setCurrentUser:(NSString *)currentUser
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter customCategory:@"Data Manager" message:nil];
    
    if ([currentUser isEqualToString:_currentUser]) return;
    
    _currentUser = currentUser;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CURRENTUSER_DID_CHANGE object:self userInfo:[NSDictionary dictionaryWithObject:currentUser forKey:NOTIFICATION_OBJECT_KEY]];
}

#pragma mark - // INITS AND LOADS //

- (id)init
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategory:@"Data Manager" message:nil];
    
    self = [super init];
    if (self)
    {
        [self setup];
    }
    else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeSetup customCategory:@"Data Manager" message:[NSString stringWithFormat:@"Could not initialize %@", stringFromVariable(self)]];
    return self;
}

- (void)dealloc
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategory:@"Data Manager" message:nil];
    
    [self teardown];
}

#pragma mark - // PUBLIC METHODS (General) //

#pragma mark - // PUBLIC METHODS (Validation) //

#pragma mark - // PUBLIC METHODS (Existence) //

#pragma mark - // PUBLIC METHODS (Retrieval) //

+ (NSOrderedSet *)getMessagesSentToUser:(NSString *)recipient
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategory:@"Data Manager" message:nil];
    
    return [CoreDataController getMessagesSentToUser:recipient];
}

+ (NSOrderedSet *)getMessagesSentByUser:(NSString *)sender
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategory:@"Data Manager" message:nil];
    
    return [CoreDataController getMessagesSentByUser:sender];
}

#pragma mark - // PUBLIC METHODS (Creation) //

+ (BOOL)createMessageWithText:(NSString *)text fromUser:(NSString *)sender toUser:(NSString *)recipient onDate:(NSDate *)sendDate
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator customCategory:@"Data Manager" message:nil];
    
    Message *message = [CoreDataController createMessageWithText:text fromUser:sender toUser:recipient onDate:sendDate];
    if (!message)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeCreator customCategory:@"Data Manager" message:[NSString stringWithFormat:@"Could not create %@", stringFromVariable(message)]];
        return NO;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MESSAGE_WAS_CREATED object:message];
    return YES;
}

#pragma mark - // PUBLIC METHODS (Editing) //

+ (void)setCurrentUser:(NSString *)currentUser
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter customCategory:@"Data Manager" message:nil];
    
    [[DataManager sharedManager] setCurrentUser:currentUser];
}

+ (NSString *)currentUser
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategory:@"Data Manager" message:nil];
    
    return [[DataManager sharedManager] currentUser];
}

#pragma mark - // PUBLIC METHODS (Deletion) //

#pragma mark - // PUBLIC METHODS (Debugging) //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS //

+ (id)sharedManager
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategory:@"Data Manager" message:nil];
    
    static dispatch_once_t once;
    static DataManager *sharedManager;
    dispatch_once(&once, ^{
        sharedManager = [[DataManager alloc] init];
    });
    return sharedManager;
}

- (void)setup
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategory:@"Data Manager" message:nil];
}

- (void)teardown
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategory:@"Data Manager" message:nil];
}

@end