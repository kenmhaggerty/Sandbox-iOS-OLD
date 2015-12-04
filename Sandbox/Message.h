//
//  Message.h
//  Sandbox
//
//  Created by Ken M. Haggerty on 5/16/15.
//  Copyright (c) 2014 MCMDI. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

#define NOTIFICATION_MESSAGE_ISREAD_DID_CHANGE @"kNotificationMessageIsReadDidChange"
#define NOTIFICATION_MESSAGE_RECIPIENT_USERNAME_DID_CHANGE @"kNotificationMessageRecipientUsernameDidChange"
#define NOTIFICATION_MESSAGE_SENDER_USERNAME_DID_CHANGE @"kNotificationMessageSenderUsernameDidChange"
#define NOTIFICATION_MESSAGE_WILL_BE_DELETED @"kNotificationMessageWillBeDeleted"

@interface Message : NSManagedObject
@property (nonatomic, retain, readonly) NSNumber *isRead;
@property (nonatomic, retain, readonly) NSString *messageId;
@property (nonatomic, retain, readonly) NSDate *sendDate;
@property (nonatomic, retain, readonly) NSString *text;
@property (nonatomic, retain, readonly) User *recipient;
@property (nonatomic, retain, readonly) User *sender;
@end
