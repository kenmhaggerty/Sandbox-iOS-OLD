//
//  NSMigrationManager+Lookup.h
//  Sandbox
//
//  Created by Ken M. Haggerty on 8/17/15.
//  Copyright (c) 2015 MCMDI. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <CoreData/CoreData.h>

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

@interface NSMigrationManager (Lookup)
- (NSMutableDictionary *)lookupWithKey:(NSString *)lookupKey;
@end