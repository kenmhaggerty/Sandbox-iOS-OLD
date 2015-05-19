//
//  Message+RW.h
//  Sandbox
//
//  Created by Ken M. Haggerty on 5/18/15.
//  Copyright (c) 2015 Eureka Valley Co. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import "Message.h"

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

@interface Message ()
@property (nonatomic, retain, readwrite) NSNumber *isRead;
@property (nonatomic, retain, readwrite) NSString *messageId;
@property (nonatomic, retain, readwrite) NSString *recipient;
@property (nonatomic, retain, readwrite) NSDate *sendDate;
@property (nonatomic, retain, readwrite) NSString *sender;
@property (nonatomic, retain, readwrite) NSString *text;
@end