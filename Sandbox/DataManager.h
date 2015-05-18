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

// CREATION //

+ (BOOL)createMessageWithText:(NSString *)text fromUser:(NSString *)sender toUser:(NSString *)recipient onDate:(NSDate *)sendDate;

// EDITING //

+ (void)setCurrentUser:(NSString *)currentUser;
+ (NSString *)currentUser;

// DELETION //

// DEBUGGING //

@end