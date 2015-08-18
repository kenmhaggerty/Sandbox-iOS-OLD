//
//  NSMigrationManager+Lookup.m
//  Sandbox
//
//  Created by Ken M. Haggerty on 8/17/15.
//  Copyright (c) 2015 MCMDI. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "NSMigrationManager+Lookup.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#pragma mark - // DEFINITIONS (Private) //

@implementation NSMigrationManager (Lookup)

#pragma mark - // SETTERS AND GETTERS //

#pragma mark - // INITS AND LOADS //

#pragma mark - // PUBLIC METHODS //

- (NSMutableDictionary *)lookupWithKey:(NSString *)lookupKey
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_CORE_DATA] message:nil];
    
    NSMutableDictionary *userInfo = (NSMutableDictionary *)self.userInfo;
    if (!userInfo)
    {
        userInfo = [@{} mutableCopy];
        self.userInfo = userInfo;
    }
    NSMutableDictionary *lookup = [userInfo valueForKey:lookupKey];
    if (!lookup)
    {
        lookup = [@{} mutableCopy];
        [userInfo setValue:lookup forKey:lookupKey];
    }
    return lookup;
}

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS //

@end