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
#import "Author.h"
//#import "Book.h"
#import "Album.h"

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS //

@interface CoreDataController : NSObject

// GENERAL //

+ (BOOL)save;

// EXISTENCE //

//+ (BOOL)bookExistsWithTitle:(NSString *)title author:(Author *)author;
+ (BOOL)albumExistsWithTitle:(NSString *)title composer:(NSString*)composer author:(Author *)author;

// RETRIEVAL //

+ (Author *)getAuthorWithLastName:(NSString *)lastName firstName:(NSString *)firstName;
//+ (NSOrderedSet *)getAllBooks;
+ (NSOrderedSet *)getAllAlbums;

// CREATION //

+ (Author *)createAuthorWithLastName:(NSString *)lastName firstName:(NSString *)firstName;
//+ (Book *)createBookWithTitle:(NSString *)title author:(Author *)author;
+ (Album *)createAlbumWithTitle:(NSString *)title composer:(NSString *)composer author:(Author *)author;

// DELETION //

+ (BOOL)deleteObject:(NSManagedObject *)object;

// DEBUGGING //

@end