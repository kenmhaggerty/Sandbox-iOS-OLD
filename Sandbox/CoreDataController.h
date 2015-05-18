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

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS //

@interface CoreDataController : NSObject

// GENERAL //

// EXISTENCE //

// RETRIEVAL //

+ (NSOrderedSet *)getMessagesSentToUser:(NSString *)recipient;
+ (NSOrderedSet *)getMessagesSentByUser:(NSString *)sender;

// CREATION //

+ (Message *)createMessageWithText:(NSString *)text fromUser:(NSString *)sender toUser:(NSString *)recipient onDate:(NSDate *)sendDate;

// DELETION //

// DEBUGGING //

@end