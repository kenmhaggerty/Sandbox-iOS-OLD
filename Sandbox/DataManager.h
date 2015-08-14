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

@interface DataManager : NSObject

// GENERAL //

// VALIDATION //

// EXISTENCE //

// RETRIEVAL //

//+ (NSOrderedSet *)getMessagesSentToUser:(NSString *)recipient;
//+ (NSOrderedSet *)getMessagesSentByUser:(NSString *)sender;
+ (Message *)getMessageWithId:(NSString *)messageId;

// CREATION //

+ (BOOL)sendMessageWithText:(NSString *)text toUser:(NSString *)recipient;

// EDITING //

+ (void)userDidReadMessage:(Message *)message;
+ (void)incrementBadge;
+ (void)decrementBadge;
+ (void)setBadgeToCount:(NSUInteger)count;

// DELETION //

+ (void)deleteMessage:(Message *)message;

// DEBUGGING //

@end