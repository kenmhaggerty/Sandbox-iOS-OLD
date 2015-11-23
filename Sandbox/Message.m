//
//  Message.m
//  Sandbox
//
//  Created by Ken M. Haggerty on 5/16/15.
//  Copyright (c) 2014 MCMDI. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "Message+RW.h"
#import "AKDebugger.h"
#import "AKGenerics.h"
#import "User.h"

#pragma mark - // DEFINITIONS (Private) //

@interface Message ()

// GENERAL //

- (void)setup;
- (void)teardown;

// OBSERVERS //

- (void)addObserversToRecipient:(User *)recipient;
- (void)removeObserversFromRecipient:(User *)recipient;
- (void)addObserversToSender:(User *)sender;
- (void)removeObserversFromSender:(User *)sender;

// RESPONDERS //

- (void)recipientUsernameDidChange:(NSNotification *)notification;
- (void)senderUsernameDidChange:(NSNotification *)notification;

@end

@implementation Message

#pragma mark - // SETTERS AND GETTERS //

@dynamic isRead;
@dynamic messageId;
@dynamic recipient;
@dynamic sendDate;
@dynamic sender;
@dynamic text;

- (void)setIsRead:(NSNumber *)isRead
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSNumber *primitiveIsRead = [self primitiveValueForKey:NSStringFromSelector(@selector(isRead))];
    if ([AKGenerics object:isRead isEqualToObject:primitiveIsRead]) return;
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(isRead))];
    [self setPrimitiveValue:isRead forKey:NSStringFromSelector(@selector(isRead))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(isRead))];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (isRead) [userInfo setObject:isRead forKey:NOTIFICATION_OBJECT_KEY];
    [AKGenerics postNotificationName:NOTIFICATION_MESSAGE_ISREAD_DID_CHANGE object:self userInfo:userInfo];
}

- (void)setRecipient:(User *)recipient
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    User *primitiveRecipient = [self primitiveValueForKey:NSStringFromSelector(@selector(recipient))];
    if ([AKGenerics object:recipient isEqualToObject:primitiveRecipient]) return;
    
    NSString *oldUsername;
    if (primitiveRecipient) oldUsername = primitiveRecipient.username;
    NSString *newUsername;
    if (recipient) newUsername = recipient.username;
    
    if (primitiveRecipient)
    {
        [self removeObserversFromRecipient:primitiveRecipient];
    }
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(recipient))];
    [self setPrimitiveValue:recipient forKey:NSStringFromSelector(@selector(recipient))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(recipient))];
    
    if (recipient)
    {
        [self addObserversToRecipient:recipient];
    }
    
    if (![AKGenerics object:oldUsername isEqualToObject:newUsername])
    {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        if (newUsername) [userInfo setObject:newUsername forKey:NOTIFICATION_OBJECT_KEY];
        [AKGenerics postNotificationName:NOTIFICATION_MESSAGE_RECIPIENT_USERNAME_DID_CHANGE object:self userInfo:userInfo];
    }
}

- (void)setSender:(User *)sender
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    User *primitiveSender = [self primitiveValueForKey:NSStringFromSelector(@selector(sender))];
    if ([AKGenerics object:sender isEqualToObject:primitiveSender]) return;
    
    NSString *oldUsername;
    if (primitiveSender) oldUsername = primitiveSender.username;
    NSString *newUsername;
    if (sender) newUsername = sender.username;
    
    if (primitiveSender)
    {
        [self removeObserversFromSender:primitiveSender];
    }
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(sender))];
    [self setPrimitiveValue:sender forKey:NSStringFromSelector(@selector(sender))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(sender))];
    
    if (sender)
    {
        [self addObserversToSender:sender];
    }
    
    if (![AKGenerics object:oldUsername isEqualToObject:newUsername])
    {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        if (newUsername) [userInfo setObject:newUsername forKey:NOTIFICATION_OBJECT_KEY];
        [AKGenerics postNotificationName:NOTIFICATION_MESSAGE_SENDER_USERNAME_DID_CHANGE object:self userInfo:userInfo];
    }
}

#pragma mark - // INITS AND LOADS //

//- (id)initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context
//{
//    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
//
//    self = [super initWithEntity:entity insertIntoManagedObjectContext:context];
//    if (self)
//    {
//        [self setup];
//    }
//    else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:@"Could not initialize self"];
//    return self;
//}

- (void)awakeFromFetch
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    //    [super awakeFromFetch];
    [self setup];
}

- (void)awakeFromInsert
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
//    [super awakeFromInsert];
    [self setup];
}

- (void)willTurnIntoFault
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    [super willTurnIntoFault];
}

- (void)didTurnIntoFault
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    [self teardown];
//    [super didTurnIntoFault];
}

- (void)prepareForDeletion
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MESSAGE_WILL_BE_DELETED object:self];
    [super prepareForDeletion];
}

//- (void)dealloc
//{
//    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
//
//    [self teardown];
//}

#pragma mark - // PUBLIC METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS (General) //

- (void)setup
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    [self addObserversToRecipient:self.recipient];
    [self addObserversToSender:self.sender];
}

- (void)teardown
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    [self removeObserversFromRecipient:self.recipient];
    [self removeObserversFromSender:self.sender];
}

#pragma mark - // PRIVATE METHODS (Observers) //

- (void)addObserversToRecipient:(User *)recipient
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recipientUsernameDidChange:) name:NOTIFICATION_USER_USERNAME_DID_CHANGE object:recipient];
}

- (void)removeObserversFromRecipient:(User *)recipient
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_USER_USERNAME_DID_CHANGE object:recipient];
}

- (void)addObserversToSender:(User *)sender
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(senderUsernameDidChange:) name:NOTIFICATION_USER_USERNAME_DID_CHANGE object:sender];
}

- (void)removeObserversFromSender:(User *)sender
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_USER_USERNAME_DID_CHANGE object:sender];
}

#pragma mark - // PRIVATE METHODS (Responders) //

- (void)recipientUsernameDidChange:(NSNotification *)notification
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [AKGenerics postNotificationName:NOTIFICATION_MESSAGE_RECIPIENT_USERNAME_DID_CHANGE object:self userInfo:notification.userInfo];
}

- (void)senderUsernameDidChange:(NSNotification *)notification
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [AKGenerics postNotificationName:NOTIFICATION_MESSAGE_SENDER_USERNAME_DID_CHANGE object:self userInfo:notification.userInfo];
}

@end