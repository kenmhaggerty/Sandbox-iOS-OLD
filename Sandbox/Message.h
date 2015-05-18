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

#define NOTIFICIATION_MESSAGE_WILL_BE_DELETED @"kNotificationMessageWillBeDeleted"

@interface Message : NSManagedObject
@property (nonatomic, retain) NSString *recipient;
@property (nonatomic, retain) NSDate *sendDate;
@property (nonatomic, retain) NSString *sender;
@property (nonatomic, retain) NSString *text;
@end