//
//  SyncEngine.m
//  Sandbox
//
//  Created by Ken M. Haggerty on 8/7/15.
//  Copyright (c) 2015 MCMDI. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "SyncEngine+Delegate.h"
#import "AKDebugger.h"
#import "AKGenerics.h"
#import "ParseController+PRIVATE.h"
#import "Message+RW.h"
#import "DataManager+PRIVATE.h"
#import "CoreDataController.h"

#pragma mark - // DEFINITIONS (Private) //

#define PARSE_CLASS_MESSAGE @"Message"

#define PARSE_KEY_MESSAGE_ID @"objectId"
#define PARSE_KEY_MESSAGE_SENDERID @"senderId"
#define PARSE_KEY_MESSAGE_SENDERUSERNAME @"senderUsername"
#define PARSE_KEY_MESSAGE_RECIPIENTID @"recipientId"
#define PARSE_KEY_MESSAGE_RECIPIENTUSERNAME @"recipientUsername"
#define PARSE_KEY_MESSAGE_TEXT @"text"
#define PARSE_KEY_MESSAGE_SENDDATE @"sendDate"
#define PARSE_KEY_MESSAGE_ISREAD @"isRead"

@interface SyncEngine ()

// GENERAL //

- (void)setup;
- (void)teardown;

// CONVENIENCE //

+ (id)sharedEngine;

// OBSERVERS //

- (void)addObserversToParseController;
- (void)removeObserversFromParseController;

// RESPONDERS //

- (void)currentAccountDidChange:(NSNotification *)notification;

// TRANSLATORS //

+ (NSDictionary *)parseInfoForMessage:(Message *)message;
+ (User *)userForAccount:(PFUser *)account;

@end

@implementation SyncEngine

#pragma mark - // SETTERS AND GETTERS //

#pragma mark - // INITS AND LOADS //

- (id)init
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:nil message:nil];
    
    self = [super init];
    if (!self)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeCritical methodType:AKMethodTypeSetup customCategories:nil message:[NSString stringWithFormat:@"Could not initialize %@", stringFromVariable(self)]];
        return nil;
    }
    
    [self setup];
    return self;
}

- (void)awakeFromNib
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:nil message:nil];
    
    [super awakeFromNib];
    [self setup];
}

- (void)dealloc
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:nil message:nil];
    
    [self teardown];
}

#pragma mark - // PUBLIC METHODS (General) //

+ (void)startEngine
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:nil message:nil];
    
    [SyncEngine sharedEngine];
}

#pragma mark - // PUBLIC METHODS (Account) //

+ (User *)currentUser
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_ACCOUNTS] message:nil];
    
    return [SyncEngine userForAccount:[ParseController currentAccount]];
}

+ (NSString *)getAccountIdForUsername:(NSString *)username
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_ACCOUNTS] message:nil];
    
    return [ParseController getAccountIdForUsername:username];
}

+ (BOOL)createAccountWithEmail:(NSString *)email password:(NSString *)password
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator customCategories:@[AKD_ACCOUNTS] message:nil];
    
    return [ParseController createAccountWithEmail:email password:password];
}

+ (BOOL)logInWithEmail:(NSString *)email password:(NSString *)password
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:@[AKD_ACCOUNTS] message:nil];
    
    return [ParseController logInWithEmail:email password:password];
}

+ (void)logOut
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:@[AKD_ACCOUNTS] message:nil];
    
    [ParseController logOut];
}

#pragma mark - // PUBLIC METHODS (Message) //

+ (BOOL)sendMessage:(Message *)message
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:@[AKD_DATA] message:nil];
    
    if (!message)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeUnspecified customCategories:@[AKD_DATA] message:[NSString stringWithFormat:@"%@ is nil", stringFromVariable(message)]];
        return NO;
    }
    
    NSString *objectId = [ParseController createParseObjectWithClass:PARSE_CLASS_MESSAGE info:[SyncEngine parseInfoForMessage:message]];
    if (!objectId)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeUnspecified customCategories:@[AKD_DATA] message:[NSString stringWithFormat:@"Could not create Parse object for %@", stringFromVariable(message)]];
        return NO;
    }
    
    [message setMessageId:objectId];
    if (![CoreDataController save])
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeUnspecified customCategories:@[AKD_DATA, AKD_CORE_DATA] message:[NSString stringWithFormat:@"Could not %@ %@", NSStringFromSelector(@selector(save)), NSStringFromClass([CoreDataController class])]];
    }
    return YES;
}

+ (void)messageWasRead:(NSString *)messageId
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:@[AKD_DATA] message:nil];
    
    [ParseController messageWasRead:messageId];
}

+ (void)messageWasDeleted:(NSString *)messageId
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeDeletor customCategories:@[AKD_DATA, AKD_PARSE] message:nil];
    
    PFObject *message = [PFQuery getObjectOfClass:PARSE_CLASS_MESSAGE objectId:messageId];
    if (!message) return;
    
    [ParseController removeCurrentInstallationFromObject:message];
}

#pragma mark - // CATEGORY METHODS (Delegate) //

#pragma mark - // DELEGATED METHODS (PushNotificationDelegate) //

+ (id <PushNotificationDelegate>)delegateForCentralDispatch
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_PUSH_NOTIFICATIONS] message:nil];
    
    return [SyncEngine sharedEngine];
}

- (void)processRemoteNotification:(NSDictionary *)userInfo
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:@[AKD_PUSH_NOTIFICATIONS] message:nil];
    
    if (![ParseController shouldProcessPushNotificationWithData:userInfo]) return;
    
    NSDictionary *info = [ParseController translatePushNotification:userInfo];
    NSString *pushType = [info objectForKey:PUSHNOTIFICATION_KEY_TYPE];
    NSString *messageId = [info objectForKey:PUSHNOTIFICATION_KEY_MESSAGEID];
    if ([pushType isEqualToString:PUSHNOTIFICATION_TYPE_READRECEIPT])
    {
        Message *message = [DataManager getMessageWithId:messageId];
        if (message) [DataManager userDidReadMessage:message];
    }
    else if ([pushType isEqualToString:PUSHNOTIFICATION_TYPE_NEWMESSAGE])
    {
        NSString *sender = [info objectForKey:PUSHNOTIFICATION_KEY_SENDER];
        NSString *recipient = [CentralDispatch currentUsername];
        NSString *text = [info objectForKey:PUSHNOTIFICATION_KEY_TEXT];
        NSDate *sendDate = [info objectForKey:PUSHNOTIFICATION_KEY_SENDDATE];
        [DataManager saveMessageWithText:text fromUser:[CoreDataController userWithUserId:[ParseController getAccountIdForUsername:sender] username:sender] toUser:[CoreDataController userWithUserId:[ParseController getAccountIdForUsername:recipient] username:recipient] onDate:sendDate withId:messageId];
    }
}

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS (General) //

- (void)setup
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:nil message:nil];
    
    [self addObserversToParseController];
}

- (void)teardown
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:nil message:nil];
    
    [self removeObserversFromParseController];
}

#pragma mark - // PRIVATE METHODS (Convenience) //

+ (id)sharedEngine
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
    
    static dispatch_once_t once;
    static SyncEngine *sharedEngine;
    dispatch_once(&once, ^{
        sharedEngine = [[SyncEngine alloc] init];
    });
    return sharedEngine;
}

#pragma mark - // PRIVATE METHODS (Observers) //

- (void)addObserversToParseController
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentAccountDidChange:) name:NOTIFICATION_PARSECONTROLLER_CURRENTACCOUNT_DID_CHANGE object:nil];
}

- (void)removeObserversFromParseController
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_PARSECONTROLLER_CURRENTACCOUNT_DID_CHANGE object:nil];
}

#pragma mark - // PRIVATE METHODS (Responders) //

- (void)currentAccountDidChange:(NSNotification *)notification
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:@[AKD_NOTIFICATION_CENTER, AKD_ACCOUNTS] message:nil];
    
    PFUser *currentAccount = [notification.userInfo objectForKey:NOTIFICATION_OBJECT_KEY];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (currentAccount) [userInfo setObject:[SyncEngine userForAccount:currentAccount] forKey:NOTIFICATION_OBJECT_KEY];
    [CentralDispatch postNotificationName:NOTIFICATION_SYNCENGINE_CURRENTUSER_DID_CHANGE object:nil userInfo:userInfo];
}

#pragma mark - // PRIVATE METHODS (Translators) //

+ (NSDictionary *)parseInfoForMessage:(Message *)message
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:@[AKD_DATA, AKD_PARSE] message:nil];
    
    if (!message)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeUnspecified customCategories:@[AKD_DATA, AKD_PARSE] message:[NSString stringWithFormat:@"%@ is nil", stringFromVariable(message)]];
        return nil;
    }
    
    NSMutableDictionary *parseInfo = [NSMutableDictionary dictionary];
    [parseInfo setObject:message.sender.userId forKey:PARSE_KEY_MESSAGE_SENDERID];
    [parseInfo setObject:message.sender.username forKey:PARSE_KEY_MESSAGE_SENDERUSERNAME];
    [parseInfo setObject:message.recipient.userId forKey:PARSE_KEY_MESSAGE_RECIPIENTID];
    [parseInfo setObject:message.recipient.username forKey:PARSE_KEY_MESSAGE_RECIPIENTUSERNAME];
    [parseInfo setObject:message.text forKey:PARSE_KEY_MESSAGE_TEXT];
    [parseInfo setObject:message.sendDate forKey:PARSE_KEY_MESSAGE_SENDDATE];
    [parseInfo setObject:message.isRead forKey:PARSE_KEY_MESSAGE_ISREAD];
    return parseInfo;
}

+ (User *)userForAccount:(PFUser *)account
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_DATA, AKD_ACCOUNTS] message:nil];
    
    if (!account) return nil;
    
    return [CoreDataController userWithUserId:account.objectId username:account.username];
}

@end