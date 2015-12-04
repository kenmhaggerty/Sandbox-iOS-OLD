//
//  User+RW.h
//  Sandbox
//
//  Created by Ken M. Haggerty on 8/12/15.
//  Copyright (c) 2015 MCMDI. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import "User.h"

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

@interface User (RW)
@property (nonatomic, retain, readwrite) NSString *username;
@property (nonatomic, retain, readwrite) NSString *userId;
@property (nonatomic, retain, readwrite) NSSet *inbox;
@property (nonatomic, retain, readwrite) NSSet *outbox;
@end
