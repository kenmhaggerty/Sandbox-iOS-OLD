//
//  DataManager.h
//  Sandbox
//
//  Created by Ken M. Haggerty on 7/11/13.
//  Copyright (c) 2013 Eureka Valley Co. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Message.h"

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

#define NOTIFICATION_CURRENTUSER_DID_CHANGE @"kNotificationCurrentUserDidChange"
#define NOTIFICATION_MESSAGE_WAS_CREATED @"kNotificationMessageWasCreated"

@interface DataManager : NSObject

// GENERAL //

// VALIDATION //

// EXISTENCE //

// RETRIEVAL //

+ (NSOrderedSet *)getMessagesSentToUser:(NSString *)recipient;
+ (NSOrderedSet *)getMessagesSentByUser:(NSString *)sender;
+ (Message *)getMessageWithId:(NSString *)messageId;

// CREATION //

+ (BOOL)createMessageWithText:(NSString *)text fromUser:(NSString *)sender toUser:(NSString *)recipient onDate:(NSDate *)sendDate withId:(NSString *)messageId andBroadcast:(BOOL)broadcast;

// EDITING //

+ (void)setCurrentUser:(NSString *)currentUser;
+ (NSString *)currentUser;
+ (void)userDidReadMessage:(Message *)message andBroadcast:(BOOL)broadcast;
+ (void)incrementBadge;
+ (void)decrementBadge;
+ (void)setBadgeToCount:(NSUInteger)count;

// DELETION //

+ (BOOL)deleteMessage:(Message *)message;

// OBSERVATION  //

+ (void)addObserver:(id)observer selector:(SEL)selector name:(NSString *)name;
+ (void)removeObserver:(id)observer name:(NSString *)name;

// DEBUGGING //

@end