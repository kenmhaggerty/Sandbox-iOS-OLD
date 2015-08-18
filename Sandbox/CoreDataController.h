//
//  CoreDataController.h
//  Sandbox
//
//  Created by Ken M. Haggerty on 4/5/13.
//  Copyright (c) 2013 Eureka Valley Co. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "Message.h"
#import "User.h"

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS //

@interface CoreDataController : NSObject

// GENERAL //

+ (void)setup;
+ (BOOL)save;

// EXISTENCE //

+ (BOOL)messageExistsWithId:(NSString *)messageId;

// RETRIEVAL //

+ (User *)getUserWithUserId:(NSString *)userId;
+ (User *)getUserWithUsername:(NSString *)username;
+ (Message *)getMessageWithId:(NSString *)messageId;

// CREATION //

+ (User *)createUserWithUserId:(NSString *)userId username:(NSString *)username;
+ (Message *)createMessageWithText:(NSString *)text fromUser:(User *)sender toUser:(User *)recipient onDate:(NSDate *)sendDate withId:(NSString *)messageId;

// CONVENIENCE //

+ (User *)userWithUserId:(NSString *)userId username:(NSString *)username;

// DELETION //

+ (BOOL)deleteObject:(NSManagedObject *)object;

// DEBUGGING //

@end