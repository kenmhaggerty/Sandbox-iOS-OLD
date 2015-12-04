//
//  DataManager+PRIVATE.h
//  Sandbox
//
//  Created by Ken M. Haggerty on 8/7/15.
//  Copyright (c) 2015 MCMDI. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import "DataManager.h"
#import "User.h"

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

@interface DataManager (PRIVATE)
+ (BOOL)saveMessageWithText:(NSString *)text fromUser:(User *)sender toUser:(User *)recipient onDate:(NSDate *)sendDate withId:(NSString *)messageId;
@end
