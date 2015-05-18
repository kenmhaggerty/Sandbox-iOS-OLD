//
//  CoreDataController.m
//  Sandbox
//
//  Created by Ken M. Haggerty on 4/5/13.
//  Copyright (c) 2013 Eureka Valley Co. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "CoreDataController.h"
#import "AKDebugger.h"
#import "AKGenerics.h"
#import "SandboxPrivateInfo.h"

#pragma mark - // DEFINITIONS (Private) //

#define CORE_DATA_FILENAME @"coredata.sqlite"
#define CORE_DATA_MODEL_NAME @"CoreDataModel"
#define CORE_DATA_MODEL_EXTENSION @"momd"

#define NSStringFromVariable(var) (@""#var)

@interface CoreDataController ()
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// GENERAL //

+ (id)sharedController;
+ (NSManagedObjectContext *)managedObjectContext;
+ (NSManagedObjectModel *)managedObjectModel;
+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (void)setup;
- (void)teardown;
+ (BOOL)save;
+ (BOOL)deleteObject:(NSManagedObject *)object;

@end

@implementation CoreDataController

#pragma mark - // SETTERS AND GETTERS //

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSManagedObjectContext *)managedObjectContext
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategory:@"Core Data" message:nil];
    
    if (!_managedObjectContext)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategory:@"Core Data" message:nil];

    if (!_managedObjectModel)
    {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:CORE_DATA_MODEL_NAME withExtension:CORE_DATA_MODEL_EXTENSION];
        if (modelURL)
        {
            _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        }
        else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeGetter customCategory:@"Core Data" message:@"modelURL is nil"];
    }
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategory:@"Core Data" message:nil];
    
    if (!_persistentStoreCoordinator)
    {
        if (![NSThread isMainThread])
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                (void)[self persistentStoreCoordinator];
            });
            return _persistentStoreCoordinator;
        }
        NSURL *storeURL = [[SandboxPrivateInfo applicationDocumentsDirectory] URLByAppendingPathComponent:CORE_DATA_FILENAME];
        NSError *error;
        NSManagedObjectModel *managedObjectModel = [self managedObjectModel];
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
        NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption : @YES, NSInferMappingModelAutomaticallyOption : @YES};
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             
             Typical reasons for an error here include:
             * The persistent store is not accessible;
             * The schema for the persistent store is incompatible with current managed object model.
             Check the error message to determine what the actual problem was.
             
             
             If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
             
             If you encounter schema incompatibility errors during development, you can reduce their frequency by:
             * Simply deleting the existing store:
             [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
             
             * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
             [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
             
             Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
             
             */
            [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeUnspecified customCategory:@"Core Data" message:[NSString stringWithFormat:@"%@, %@", error, [error userInfo]]];
            abort();
        }
    }
    return _persistentStoreCoordinator;
}

#pragma mark - // INITS AND LOADS //

- (id)init
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategory:@"Core Data" message:nil];
    
    self = [super init];
    if (self)
    {
        [self setup];
    }
    else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeSetup customCategory:@"Core Data" message:[NSString stringWithFormat:@"Could not initialize %@", stringFromVariable(self)]];
    return self;
}

- (void)dealloc
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategory:@"Core Data" message:nil];
    
    [self teardown];
}

#pragma mark - // PUBLIC METHODS (General) //

#pragma mark - // PUBLIC METHODS (Existence) //

#pragma mark - // PUBLIC METHODS (Retrieval) //

+ (NSOrderedSet *)getMessagesSentToUser:(NSString *)recipient
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategory:@"Core Data" message:nil];
    
    NSManagedObjectContext *managedObjectContext = [CoreDataController managedObjectContext];
    if (!managedObjectContext)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeGetter customCategory:@"Core Data" message:[NSString stringWithFormat:@"%@ is nil", stringFromVariable(managedObjectContext)]];
        return nil;
    }
    
    __block NSArray *foundMessages;
    __block NSError *error;
    [managedObjectContext performBlockAndWait:^{
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:NSStringFromClass([Message class]) inManagedObjectContext:managedObjectContext]];
        [request setPredicate:[NSPredicate predicateWithFormat:@"(%K == %@)", NSStringFromSelector(@selector(recipient)), recipient]];
        [request setSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(sendDate)) ascending:NO], nil]];
        foundMessages = [managedObjectContext executeFetchRequest:request error:&error];
    }];
    if (error)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeGetter customCategory:@"Core Data" message:[NSString stringWithFormat:@"%@, %@", error, [error userInfo]]];
        return nil;
    }
    
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeInfo methodType:AKMethodTypeGetter customCategory:@"Core Data" message:[NSString stringWithFormat:@"Found %lu %@ object(s) with %@ %@", (unsigned long)foundMessages.count, NSStringFromClass([Message class]), stringFromVariable(recipient), recipient]];
    return [NSOrderedSet orderedSetWithArray:foundMessages];
}

+ (NSOrderedSet *)getMessagesSentByUser:(NSString *)sender
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategory:@"Core Data" message:nil];
    
    NSManagedObjectContext *managedObjectContext = [CoreDataController managedObjectContext];
    if (!managedObjectContext)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeGetter customCategory:@"Core Data" message:[NSString stringWithFormat:@"%@ is nil", stringFromVariable(managedObjectContext)]];
        return nil;
    }
    
    __block NSArray *foundMessages;
    __block NSError *error;
    [managedObjectContext performBlockAndWait:^{
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:NSStringFromClass([Message class]) inManagedObjectContext:managedObjectContext]];
        [request setPredicate:[NSPredicate predicateWithFormat:@"(%K == %@)", NSStringFromSelector(@selector(sender)), sender]];
        [request setSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(sendDate)) ascending:NO], nil]];
        foundMessages = [managedObjectContext executeFetchRequest:request error:&error];
    }];
    if (error)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeGetter customCategory:@"Core Data" message:[NSString stringWithFormat:@"%@, %@", error, [error userInfo]]];
        return nil;
    }
    
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeInfo methodType:AKMethodTypeGetter customCategory:@"Core Data" message:[NSString stringWithFormat:@"Found %lu %@ object(s) with %@ %@", (unsigned long)foundMessages.count, NSStringFromClass([Message class]), stringFromVariable(sender), sender]];
    return [NSOrderedSet orderedSetWithArray:foundMessages];
}

#pragma mark - // PUBLIC METHODS (Creation) //

+ (Message *)createMessageWithText:(NSString *)text fromUser:(NSString *)sender toUser:(NSString *)recipient onDate:(NSDate *)sendDate
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator customCategory:@"Core Data" message:nil];
    
    NSManagedObjectContext *managedObjectContext = [CoreDataController managedObjectContext];
    if (!managedObjectContext)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeCreator customCategory:@"Core Data" message:[NSString stringWithFormat:@"%@ is nil", stringFromVariable(managedObjectContext)]];
        return nil;
    }
    
    __block Message *message;
    [managedObjectContext performBlockAndWait:^{
        message = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Message class]) inManagedObjectContext:managedObjectContext];
        [message setSender:sender];
        [message setRecipient:recipient];
        [message setText:text];
        [message setSendDate:sendDate];
    }];
    
    if (![CoreDataController save])
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeCreator customCategory:@"Core Data" message:[NSString stringWithFormat:@"Could not create %@", stringFromVariable(message)]];
        if (![CoreDataController deleteObject:message])
        {
            [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeCreator customCategory:@"Core Data" message:[NSString stringWithFormat:@"Could not delete %@", stringFromVariable(message)]];
        }
        return nil;
    }
    
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeInfo methodType:AKMethodTypeCreator customCategory:@"Core Data" message:[NSString stringWithFormat:@"Created %@ with %@ %@ and %@ %@", NSStringFromClass([Message class]), stringFromVariable(sender), sender, stringFromVariable(recipient), recipient]];
    return message;
}

#pragma mark - // PUBLIC METHODS (Deletion) //

#pragma mark - // PUBLIC METHODS (Debugging) //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS (General) //

+ (id)sharedController
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategory:@"Core Data" message:nil];
    
    static dispatch_once_t once;
    static CoreDataController *sharedController;
    dispatch_once(&once, ^{
        sharedController = [[CoreDataController alloc] init];
    });
    return sharedController;
}

+ (NSManagedObjectContext *)managedObjectContext
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategory:@"Core Data" message:nil];
    
    return [[CoreDataController sharedController] managedObjectContext];
}

+ (NSManagedObjectModel *)managedObjectModel
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategory:@"Core Data" message:nil];
    
    return [[CoreDataController sharedController] managedObjectModel];
}

+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategory:@"Core Data" message:nil];
    
    return [[CoreDataController sharedController] persistentStoreCoordinator];
}

- (void)setup
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategory:@"Core Data" message:nil];
}

- (void)teardown
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategory:@"Core Data" message:nil];
}

+ (BOOL)save
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategory:@"Core Data" message:nil];
    
    NSManagedObjectContext *managedObjectContext = [CoreDataController managedObjectContext];
    if (!managedObjectContext)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeUnspecified customCategory:@"Core Data" message:[NSString stringWithFormat:@"%@ is nil", stringFromVariable(managedObjectContext)]];
        return NO;
    }
    
    __block NSError *error;
    __block BOOL succeeded;
    [managedObjectContext performBlockAndWait:^{
        succeeded = [managedObjectContext save:&error];
    }];
    if (error)
    {
        NSArray *detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
        if (detailedErrors)
        {
            for (NSError *detailedError in detailedErrors)
            {
                [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeUnspecified customCategory:@"Core Data" message:[NSString stringWithFormat:@"%@", [detailedError userInfo]]];
            }
        }
        else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeUnspecified customCategory:@"Core Data" message:[NSString stringWithFormat:@"%@", [error userInfo]]];
        return NO;
    }
    
    if (!succeeded)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeUnspecified customCategory:@"Core Data" message:@"Could not save"];
        return NO;
    }
    
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeInfo methodType:AKMethodTypeUnspecified customCategory:@"Core Data" message:@"Save successful"];
    return YES;
}

+ (BOOL)deleteObject:(NSManagedObject *)object
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategory:@"Core Data" message:nil];
    
    NSManagedObjectContext *managedObjectContext = [CoreDataController managedObjectContext];
    if (!managedObjectContext)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeUnspecified customCategory:@"Core Data" message:[NSString stringWithFormat:@"%@ is nil", stringFromVariable(managedObjectContext)]];
        return NO;
    }
    
    [managedObjectContext performBlockAndWait:^{
        [managedObjectContext deleteObject:object];
    }];
    return YES;
}

@end