//
//  User.h
//  Sandbox
//
//  Created by Ken M. Haggerty on 8/12/15.
//  Copyright (c) 2015 MCMDI. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Message;

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

#define NOTIFICATION_USER_USERNAME_DID_CHANGE @"kNotificationUserUsernameDidChange"

@interface User : NSManagedObject
@property (nonatomic, retain, readonly) NSString *username;
@property (nonatomic, retain, readonly) NSString *userId;
@property (nonatomic, retain, readonly) NSSet *inbox;
@property (nonatomic, retain, readonly) NSSet *outbox;
@end

@interface User (CoreDataGeneratedAccessors)

// inbox //

- (void)addInboxObject:(Message *)value;
- (void)removeInboxObject:(Message *)value;
- (void)addInbox:(NSSet *)values;
- (void)removeInbox:(NSSet *)values;

// outbox //

- (void)addOutboxObject:(Message *)value;
- (void)removeOutboxObject:(Message *)value;
- (void)addOutbox:(NSSet *)values;
- (void)removeOutbox:(NSSet *)values;

@end