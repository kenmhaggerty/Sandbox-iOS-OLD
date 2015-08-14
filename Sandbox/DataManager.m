//
//  DataManager.m
//  Databox
//
//  Created by Ken M. Haggerty on 7/11/13.
//  Copyright (c) 2013 Eureka Valley Co. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "DataManager+PRIVATE.h"
#import "AKDebugger.h"
#import "AKGenerics.h"
#import "AKPrivateInfo.h"
#import "CentralDispatch.h"
#import "CoreDataController.h"
#import "SyncEngine.h"
#import "Message+RW.h"

#pragma mark - // DEFINITIONS (Private) //

@interface DataManager ()

// GENERAL //

- (void)setup;
- (void)teardown;

// CONVENIENCE METHODS //

+ (id)sharedManager;

// CREATORS //

+ (Message *)createMessageWithText:(NSString *)text fromUser:(NSString *)sender toUser:(NSString *)recipient onDate:(NSDate *)sendDate withId:(NSString *)messageId;

@end

@implementation DataManager

#pragma mark - // SETTERS AND GETTERS //

#pragma mark - // INITS AND LOADS //

- (id)init
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_DATA] message:nil];
    
    self = [super init];
    if (!self)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeCritical methodType:AKMethodTypeSetup customCategories:nil message:[NSString stringWithFormat:@"Could not instantiate %@", stringFromVariable(self)]];
        return nil;
    }
    
    [self setup];
    return self;
}

- (void)awakeFromNib
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_DATA] message:nil];
    
    [super awakeFromNib];
    [self setup];
}

- (void)dealloc
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_DATA] message:nil];
    
    [self teardown];
}

#pragma mark - // PUBLIC METHODS (General) //

#pragma mark - // PUBLIC METHODS (Validation) //

#pragma mark - // PUBLIC METHODS (Existence) //

#pragma mark - // PUBLIC METHODS (Retrieval) //

//+ (NSOrderedSet *)getMessagesSentToUser:(NSString *)recipient
//{
//    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
//    
//    return [CoreDataController getMessagesSentToUser:recipient];
//}
//
//+ (NSOrderedSet *)getMessagesSentByUser:(NSString *)sender
//{
//    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
//    
//    return [CoreDataController getMessagesSentByUser:sender];
//}

+ (Message *)getMessageWithId:(NSString *)messageId
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
    
    return [CoreDataController getMessageWithId:messageId];
}

#pragma mark - // PUBLIC METHODS (Creation) //

+ (BOOL)sendMessageWithText:(NSString *)text toUser:(NSString *)recipient
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator customCategories:nil message:nil];
    
    return [SyncEngine sendMessage:[DataManager createMessageWithText:text fromUser:[CentralDispatch currentUsername] toUser:recipient onDate:[NSDate date] withId:nil]];
}

#pragma mark - // PUBLIC METHODS (Editing) //

+ (void)userDidReadMessage:(Message *)message
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:nil message:nil];
    
    if ([message.isRead boolValue]) return;
    
    [message setIsRead:@YES];
    if (![CoreDataController save])
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeCreator customCategories:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"Could not save %@", stringFromVariable(message)]];
        return;
    }
}

+ (void)incrementBadge
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter customCategories:nil message:nil];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[UIApplication sharedApplication] applicationIconBadgeNumber]+1];
}

+ (void)decrementBadge
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter customCategories:nil message:nil];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[UIApplication sharedApplication] applicationIconBadgeNumber]-1];
}

+ (void)setBadgeToCount:(NSUInteger)count
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter customCategories:nil message:nil];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:count];
}

#pragma mark - // PUBLIC METHODS (Deletion) //

+ (void)deleteMessage:(Message *)message
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:nil message:nil];
    
    NSString *messageId = message.messageId;
    if (![CoreDataController deleteObject:message])
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeUnspecified customCategories:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"Could not delete %@", stringFromVariable(message)]];
        return;
    }
    
    if (![CoreDataController save])
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeCreator customCategories:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"Could not save %@", stringFromVariable(message)]];
    }
    
    [SyncEngine messageWasDeleted:messageId];
}

#pragma mark - // PUBLIC METHODS (Debugging) //

#pragma mark - // CATEGORY METHODS (Private) //

+ (BOOL)saveMessageWithText:(NSString *)text fromUser:(NSString *)sender toUser:(NSString *)recipient onDate:(NSDate *)sendDate withId:(NSString *)messageId
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator customCategories:@[AKD_DATA] message:nil];
    
    Message *message = [DataManager createMessageWithText:text fromUser:sender toUser:recipient onDate:sendDate withId:messageId];
    if (message)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeCreator customCategories:@[AKD_DATA] message:[NSString stringWithFormat:@"Could not create %@", stringFromVariable(message)]];
        return NO;
    }
    
    return YES;
}

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS (General) //

- (void)setup
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_DATA] message:nil];
}

- (void)teardown
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_DATA] message:nil];
}

#pragma mark - // PRIVATE METHODS (Convenience) //

+ (id)sharedManager
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_DATA] message:nil];
    
    static dispatch_once_t once;
    static DataManager *sharedManager;
    dispatch_once(&once, ^{
        sharedManager = [[DataManager alloc] init];
    });
    return sharedManager;
}

#pragma mark - // PRIVATE METHODS (Creators) //

+ (Message *)createMessageWithText:(NSString *)text fromUser:(NSString *)sender toUser:(NSString *)recipient onDate:(NSDate *)sendDate withId:(NSString *)messageId
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator customCategories:@[AKD_DATA] message:nil];
    
    if ([CoreDataController messageExistsWithId:messageId])
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeInfo methodType:AKMethodTypeCreator customCategories:nil message:[NSString stringWithFormat:@"%@ already exists with %@ %@", stringFromVariable(message), stringFromVariable(messageId), messageId]];
        return nil;
    }
    
    Message *message = [CoreDataController createMessageWithText:text fromUser:sender toUser:recipient onDate:sendDate withId:messageId];
    
    if (!message)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeCreator customCategories:@[AKD_DATA] message:[NSString stringWithFormat:@"Could not create %@", stringFromVariable(message)]];
        return nil;
    }
    
    [CentralDispatch postNotificationName:NOTIFICATION_MESSAGE_WAS_CREATED object:nil userInfo:[NSDictionary dictionaryWithObject:message forKey:NOTIFICATION_OBJECT_KEY]];
    return message;
}

@end