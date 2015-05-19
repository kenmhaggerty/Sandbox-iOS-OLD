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

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

#define NOTIFICATION_MESSAGE_ISREAD_DID_CHANGE @"kNotificationMessageIsReadDidChange"
#define NOTIFICATION_MESSAGE_WILL_BE_DELETED @"kNotificationMessageWillBeDeleted"

@interface Message : NSManagedObject
@property (nonatomic, retain, readonly) NSNumber *isRead;
@property (nonatomic, retain, readonly) NSString *messageId;
@property (nonatomic, retain, readonly) NSString *recipient;
@property (nonatomic, retain, readonly) NSDate *sendDate;
@property (nonatomic, retain, readonly) NSString *sender;
@property (nonatomic, retain, readonly) NSString *text;
@end