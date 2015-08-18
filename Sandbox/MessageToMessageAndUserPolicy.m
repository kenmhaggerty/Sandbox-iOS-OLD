//
//  MessageToMessageAndUserPolicy.m
//  Sandbox
//
//  Created by Ken M. Haggerty on 8/12/15.
//  Copyright (c) 2015 MCMDI. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "MessageToMessageAndUserPolicy.h"
#import "AKDebugger.h"
#import "AKGenerics.h"
#import "NSMigrationManager+Lookup.h"
#import "Message+RW.h"
#import "User+RW.h"
#import "SyncEngine.h"

#pragma mark - // DEFINITIONS (Private) //

@interface MessageToMessageAndUserPolicy ()
@end

@implementation MessageToMessageAndUserPolicy

#pragma mark - // SETTERS AND GETTERS //

#pragma mark - // INITS AND LOADS //

#pragma mark - // PUBLIC METHODS //

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

- (BOOL)createDestinationInstancesForSourceInstance:(NSManagedObject *)sInstance entityMapping:(NSEntityMapping *)mapping manager:(NSMigrationManager *)manager error:(NSError *__autoreleasing *)error
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *destinationContext = manager.destinationContext;
    
    NSMutableDictionary *createdMessages = [manager lookupWithKey:NSStringFromClass([Message class])];
    NSString *messageId = [sInstance valueForKey:NSStringFromSelector(@selector(messageId))];
    Message *newMessage = [createdMessages valueForKey:messageId];
    if (!newMessage)
    {
        newMessage = [NSEntityDescription insertNewObjectForEntityForName:[mapping destinationEntityName] inManagedObjectContext:destinationContext];
        NSNumber *isRead = [sInstance valueForKey:NSStringFromSelector(@selector(isRead))];
        NSDate *sendDate = [sInstance valueForKey:NSStringFromSelector(@selector(sendDate))];
        NSString *text = [sInstance valueForKey:NSStringFromSelector(@selector(text))];
        [newMessage setMessageId:messageId];
        [newMessage setText:text];
        [newMessage setIsRead:isRead];
        [newMessage setSendDate:sendDate];
        if (messageId) [createdMessages setValue:newMessage forKey:messageId];
    }
    
    NSMutableDictionary *createdUsers = [manager lookupWithKey:NSStringFromClass([User class])];
    NSString *recipientUsername = [sInstance valueForKey:NSStringFromSelector(@selector(recipient))];
    User *recipient = [createdUsers valueForKey:recipientUsername];
    if (!recipient)
    {
        recipient = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([User class]) inManagedObjectContext:destinationContext];
        [recipient setUsername:recipientUsername];
        [recipient setUserId:[SyncEngine getAccountIdForUsername:recipientUsername]];
        [createdUsers setValue:recipient forKey:recipientUsername];
    }
    [newMessage setRecipient:recipient];
    NSString *senderUsername = [sInstance valueForKey:NSStringFromSelector(@selector(sender))];
    User *sender = [createdUsers valueForKey:senderUsername];
    if (!sender)
    {
        sender = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([User class]) inManagedObjectContext:destinationContext];
        [sender setUsername:senderUsername];
        [sender setUserId:[SyncEngine getAccountIdForUsername:senderUsername]];
        [createdUsers setValue:sender forKey:senderUsername];
    }
    [newMessage setSender:sender];
    
    [manager associateSourceInstance:sInstance withDestinationInstance:newMessage forEntityMapping:mapping];
    return YES;
}

- (BOOL)createRelationshipsForDestinationInstance:(NSManagedObject *)dInstance entityMapping:(NSEntityMapping *)mapping manager:(NSMigrationManager *)manager error:(NSError *__autoreleasing *)error
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_CORE_DATA] message:nil];
    
    return YES;
}

#pragma mark - // PRIVATE METHODS //

@end