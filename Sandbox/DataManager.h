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
#import "Author.h"
//#import "Book.h"
#import "Album.h"

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

@interface DataManager : NSObject

// GENERAL //

+ (BOOL)save;

// VALIDATION //

// EXISTENCE //

//+ (BOOL)bookExistsWithTitle:(NSString *)title author:(Author *)author;
+ (BOOL)albumExistsWithTitle:(NSString *)title composer:(NSString *)composer author:(Author *)author;

// RETRIEVAL //

//+ (NSOrderedSet *)getAllBooks;
+ (NSOrderedSet *)getAllAlbums;

// EXISTENCE + RETRIEVAL //

+ (Author *)authorWithLastName:(NSString *)lastName firstName:(NSString *)firstName;

// CREATION //

//+ (Book *)createBookWithTitle:(NSString *)title author:(Author *)author;
+ (Album *)createAlbumWithTitle:(NSString *)title composer:(NSString *)composer author:(Author *)author;

// DELETION //

+ (BOOL)deleteObject:(NSManagedObject *)object;

// DEBUGGING //

@end