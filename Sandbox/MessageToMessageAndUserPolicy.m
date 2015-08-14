//
//  MessageToMessageAndUserPolicy.m
//  Sandbox
//
//  Created by Ken M. Haggerty on 8/12/15.
//  Copyright (c) 2015 MCMDI. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "MessageToMessageAndUserPolicy.h"
#import "AKDebugger.h"
#import "AKGenerics.h"
#import "Message.h"
#import "User.h"

#pragma mark - // DEFINITIONS (Private) //

@interface MessageToMessageAndUserPolicy ()
@end

@implementation MessageToMessageAndUserPolicy

#pragma mark - // SETTERS AND GETTERS //

#pragma mark - // INITS AND LOADS //

#pragma mark - // PUBLIC METHODS //

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

- (BOOL)createDestinationInstancesForSourceInstance:(NSManagedObject *)sInstance entityMapping:(NSEntityMapping *)mapping manager:(NSMigrationManager *)manager error:(NSError *__autoreleasing *)error
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *destinationContext = manager.destinationContext;
    NSString *destinationEntityName = mapping.destinationEntityName;
    NSString *sourceEntityName = [sInstance valueForKey:@"name"];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:manager.userInfo];
    if (!userInfo)
    {
        userInfo = [NSMutableDictionary dictionary];
        [manager setUserInfo:userInfo];
    }
    NSMutableDictionary *createdMessages = [userInfo valueForKey:NSStringFromClass([Message class])];
    if (!createdMessages)
    {
        createdMessages = [NSMutableDictionary dictionary];
        [userInfo setValue:createdMessages forKey:NSStringFromClass([Message class])];
    }
    NSMutableDictionary *createdUsers = [userInfo valueForKey:NSStringFromClass([User class])];
    if (!createdUsers)
    {
        createdUsers = [NSMutableDictionary dictionary];
        [userInfo setValue:createdUsers forKey:NSStringFromClass([User class])];
    }
    NSManagedObject *destinationEntity = [createdMessages valueForKey:sourceEntityName];
    if (!destinationEntity)
    {
        destinationEntity = [NSEntityDescription insertNewObjectForEntityForName:destinationEntityName inManagedObjectContext:destinationContext];
        [destinationEntity setValue:sourceEntityName forKey:@"name"];
        [createdUsers setValue:destinationEntity forKey:sourceEntityName];
        sourceEntityName = [sInstance valueForKey:NSStringFromClass([User class])];
        NSManagedObject *user = [createdUsers valueForKey:sourceEntityName];
        if (!user)
        {
            user = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([User class]) inManagedObjectContext:destinationContext];
            [user setValue:sourceEntityName forKey:@"name"];
            [destinationEntity setValue:user forKey:sourceEntityName];
        }
    }
    [manager associateSourceInstance:sInstance withDestinationInstance:destinationEntity forEntityMapping:mapping];
    return YES;
}

- (BOOL)createRelationshipsForDestinationInstance:(NSManagedObject *)dInstance entityMapping:(NSEntityMapping *)mapping manager:(NSMigrationManager *)manager error:(NSError *__autoreleasing *)error
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_CORE_DATA] message:nil];
    
    return YES;
}

#pragma mark - // PRIVATE METHODS //

@end