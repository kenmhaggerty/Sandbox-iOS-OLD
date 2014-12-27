//
//  Author.h
//  Sandbox
//
//  Created by Ken M. Haggerty on 12/25/14.
//  Copyright (c) 2014 MCMDI. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

//@class Book;
@class Album;

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

@interface Author : NSManagedObject
@property (nonatomic, retain) NSDate *editDate;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) NSString *firstName;
//@property (nonatomic, retain) NSSet *books;
@property (nonatomic, retain) NSSet *albums;
@end

@interface Author (CoreDataGeneratedAccessors)
//// books //
//- (void)addBooksObject:(Book *)value;
//- (void)removeBooksObject:(Book *)value;
//- (void)addBooks:(NSSet *)values;
//- (void)removeBooks:(NSSet *)values;
// albums //
- (void)addAlbumsObject:(Album *)value;
- (void)removeAlbumsObject:(Album *)value;
- (void)addAlbums:(NSSet *)values;
- (void)removeAlbums:(NSSet *)values;
@end