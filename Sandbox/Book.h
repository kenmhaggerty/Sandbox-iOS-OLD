//
//  Book.h
//  Sandbox
//
//  Created by Ken M. Haggerty on 12/25/14.
//  Copyright (c) 2014 MCMDI. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Author;

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

@interface Book : NSManagedObject
@property (nonatomic, retain) NSDate *editDate;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) Author *author;
@end