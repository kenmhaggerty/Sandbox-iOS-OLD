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
#import "Message+RW.h"
#import "User+RW.h"

#pragma mark - // DEFINITIONS (Private) //

#define MESSAGE_ID_LENGTH 10
#define MESSAGE_ID_CHARACTERS @"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

#define CORE_DATA_FILENAME @"coredata.sqlite"
#define CORE_DATA_MODEL_NAME @"CoreDataModel"
#define CORE_DATA_MODEL_DIRECTORY_EXTENSION @"momd"
#define CORE_DATA_MODEL_FILE_EXTENSION @"mom"

@interface CoreDataController ()
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// GENERAL //

- (void)setup;
- (void)teardown;

// CONVENIENCE //

+ (id)sharedController;
+ (NSManagedObjectContext *)managedObjectContext;
+ (NSManagedObjectModel *)managedObjectModel;
+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator;

// MIGRATION //

+ (BOOL)isMigrationNeeded;
+ (BOOL)migrate;
+ (BOOL)progressivelyMigrateURL:(NSURL *)sourceStoreURL ofType:(NSString *)type toModel:(NSManagedObjectModel *)finalModel error:(NSError *)error;
+ (NSURL *)sourceStoreURL;
+ (BOOL)getDestinationModel:(NSManagedObjectModel **)destinationModel mappingModel:(NSMappingModel **)mappingModel modelName:(NSString **)modelName forSourceModel:(NSManagedObjectModel *)sourceModel error:(NSError **)error;
+ (NSArray *)modelPaths;
+ (NSURL *)destinationStoreURLWithSourceStoreURL:(NSURL *)sourceStoreURL modelName:(NSString *)modelName;
+ (BOOL)backupSourceStoreAtURL:(NSURL *)sourceStoreURL movingDestinationStoreAtURL:(NSURL *)destinationStoreURL error:(NSError *)error;

@end

@implementation CoreDataController

#pragma mark - // SETTERS AND GETTERS //

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSManagedObjectContext *)managedObjectContext
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    if (!_managedObjectContext)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];

    if (!_managedObjectModel)
    {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:CORE_DATA_MODEL_NAME withExtension:CORE_DATA_MODEL_DIRECTORY_EXTENSION];
        if (modelURL)
        {
            _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        }
        else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:@"modelURL is nil"];
    }
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    if (_persistentStoreCoordinator) return _persistentStoreCoordinator;
    
    if (![NSThread isMainThread])
    {
        dispatch_sync(dispatch_get_main_queue(), ^{
            (void)[self persistentStoreCoordinator];
        });
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *managedObjectModel = [self managedObjectModel];
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES, NSInferMappingModelAutomaticallyOption: @YES};
    NSURL *storeURL = [CoreDataController sourceStoreURL];
    NSError *error;
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
        
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@, %@", error, [error userInfo]]];
        abort();
    }
    return _persistentStoreCoordinator;
}

#pragma mark - // INITS AND LOADS //

- (id)init
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    self = [super init];
    if (self)
    {
        [self setup];
    }
    else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"Could not initialize %@", stringFromVariable(self)]];
    return self;
}

- (void)dealloc
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    [self teardown];
}

#pragma mark - // PUBLIC METHODS (General) //

+ (void)setup
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    if ([CoreDataController isMigrationNeeded]) [CoreDataController migrate];
}

+ (BOOL)save
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = [CoreDataController managedObjectContext];
    if (!managedObjectContext)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@ is nil", stringFromVariable(managedObjectContext)]];
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
                [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@", [detailedError userInfo]]];
            }
        }
        else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@", [error userInfo]]];
        return NO;
    }
    
    if (!succeeded)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:@"Could not save"];
        return NO;
    }
    
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeInfo methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:@"Save successful"];
    return YES;
}

#pragma mark - // PUBLIC METHODS (Existence) //

+ (BOOL)messageExistsWithId:(NSString *)messageId
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    if (!messageId) return NO;
    
    NSManagedObjectContext *managedObjectContext = [CoreDataController managedObjectContext];
    __block NSUInteger count;
    __block NSError *error;
    [managedObjectContext performBlockAndWait:^{
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:NSStringFromClass([Message class]) inManagedObjectContext:managedObjectContext]];
        [request setPredicate:[NSPredicate predicateWithFormat:@"(%K == %@)", NSStringFromSelector(@selector(messageId)), messageId]];
        count = [managedObjectContext countForFetchRequest:request error:&error];
    }];
    if (error)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@, %@", error, [error userInfo]]];
        return NO;
    }
    
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeInfo methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"Found %lu %@ object(s)", (unsigned long)count, NSStringFromClass([Message class])]];
    if (count == 0) return NO;
    return YES;
}

#pragma mark - // PUBLIC METHODS (Retrieval) //

+ (User *)getUserWithUserId:(NSString *)userId
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = [CoreDataController managedObjectContext];
    __block NSArray *foundUsers;
    __block NSError *error;
    [managedObjectContext performBlockAndWait:^{
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:NSStringFromClass([User class]) inManagedObjectContext:managedObjectContext]];
        [request setPredicate:[NSPredicate predicateWithFormat:@"(%K == %@)", NSStringFromSelector(@selector(userId)), userId]];
        foundUsers = [managedObjectContext executeFetchRequest:request error:&error];
    }];
    if (error)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@, %@", error, [error userInfo]]];
        return nil;
    }
    
    if (foundUsers.count > 1) [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"Found %lu %@ object(s) with %@ %@; returning first object", (unsigned long)foundUsers.count, NSStringFromClass([User class]), stringFromVariable(userId), userId]];
    return [foundUsers firstObject];
}

+ (User *)getUserWithUsername:(NSString *)username
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = [CoreDataController managedObjectContext];
    __block NSArray *foundUsers;
    __block NSError *error;
    [managedObjectContext performBlockAndWait:^{
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:NSStringFromClass([User class]) inManagedObjectContext:managedObjectContext]];
        [request setPredicate:[NSPredicate predicateWithFormat:@"(%K == %@)", NSStringFromSelector(@selector(username)), username]];
        foundUsers = [managedObjectContext executeFetchRequest:request error:&error];
    }];
    if (error)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@, %@", error, [error userInfo]]];
        return nil;
    }
    
    if (foundUsers.count > 1) [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"Found %lu %@ object(s) with %@ %@; returning first object", (unsigned long)foundUsers.count, NSStringFromClass([User class]), stringFromVariable(username), username]];
    return [foundUsers firstObject];
}

+ (Message *)getMessageWithId:(NSString *)messageId
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = [CoreDataController managedObjectContext];
    if (!managedObjectContext)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@ is nil", stringFromVariable(managedObjectContext)]];
        return nil;
    }
    
    __block NSArray *foundMessages;
    __block NSError *error;
    [managedObjectContext performBlockAndWait:^{
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:NSStringFromClass([Message class]) inManagedObjectContext:managedObjectContext]];
        [request setPredicate:[NSPredicate predicateWithFormat:@"(%K == %@)", NSStringFromSelector(@selector(messageId)), messageId]];
        [request setSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(sendDate)) ascending:NO], nil]];
        foundMessages = [managedObjectContext executeFetchRequest:request error:&error];
    }];
    if (error)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@, %@", error, [error userInfo]]];
        return nil;
    }
    
    if (foundMessages.count > 1) [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"Found %lu %@ object(s) with %@ %@; returning first object", (unsigned long)foundMessages.count, NSStringFromClass([Message class]), stringFromVariable(messageId), messageId]];
    return [foundMessages firstObject];
}

#pragma mark - // PUBLIC METHODS (Creation) //

+ (User *)createUserWithUserId:(NSString *)userId username:(NSString *)username
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator tags:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = [CoreDataController managedObjectContext];
    __block User *user;
    [managedObjectContext performBlockAndWait:^{
        user = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([User class]) inManagedObjectContext:managedObjectContext];
        [user setUsername:username];
        [user setUserId:userId];
    }];
    return user;
}

+ (Message *)createMessageWithText:(NSString *)text fromUser:(User *)sender toUser:(User *)recipient onDate:(NSDate *)sendDate withId:(NSString *)messageId
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator tags:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = [CoreDataController managedObjectContext];
    __block Message *message;
    [managedObjectContext performBlockAndWait:^{
        message = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Message class]) inManagedObjectContext:managedObjectContext];
        if (messageId) [message setMessageId:messageId];
        [message setSender:sender];
        [message setRecipient:recipient];
        [message setText:text];
        [message setSendDate:sendDate];
    }];
    return message;
}

#pragma mark - // PUBLIC METHODS (Convenience) //

+ (User *)userWithUserId:(NSString *)userId username:(NSString *)username
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    User *user = [CoreDataController getUserWithUserId:userId];
    if (!user)
    {
        user = [CoreDataController createUserWithUserId:userId username:username];
        if (![CoreDataController save])
        {
            [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"Could not %@ %@", NSStringFromSelector(@selector(save)), NSStringFromClass([CoreDataController class])]];
        }
    }
    return user;
}

#pragma mark - // PUBLIC METHODS (Deletion) //

+ (BOOL)deleteObject:(NSManagedObject *)object
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = [CoreDataController managedObjectContext];
    if (!managedObjectContext)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@ is nil", stringFromVariable(managedObjectContext)]];
        return NO;
    }
    
    [managedObjectContext performBlockAndWait:^{
        [managedObjectContext deleteObject:object];
    }];
    return YES;
}

#pragma mark - // PUBLIC METHODS (Debugging) //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS (General) //

- (void)setup
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
}

- (void)teardown
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
}

#pragma mark - // PRIVATE METHODS (Convenience) //

+ (id)sharedController
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    static dispatch_once_t once;
    static CoreDataController *sharedController;
    dispatch_once(&once, ^{
        sharedController = [[CoreDataController alloc] init];
    });
    return sharedController;
}

+ (NSManagedObjectContext *)managedObjectContext
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    return [[CoreDataController sharedController] managedObjectContext];
}

+ (NSManagedObjectModel *)managedObjectModel
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    return [[CoreDataController sharedController] managedObjectModel];
}

+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    return [[CoreDataController sharedController] persistentStoreCoordinator];
}

#pragma mark - // PRIVATE METHODS (Migration) //

+ (BOOL)isMigrationNeeded
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSError *error;
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:[CoreDataController sourceStoreURL] error:&error];
    BOOL isMigrationNeeded = NO;
    if (sourceMetadata)
    {
        NSManagedObjectModel *destinationModel = [CoreDataController managedObjectModel];
        isMigrationNeeded = ![destinationModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata];
    }
    return isMigrationNeeded;
}

+ (BOOL)migrate
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    __block UIBackgroundTaskIdentifier bgTask;
    bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    NSError *error;
    BOOL success = [CoreDataController progressivelyMigrateURL:[CoreDataController sourceStoreURL] ofType:NSSQLiteStoreType toModel:[CoreDataController managedObjectModel] error:error];
    if (error)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
    }
    if (!success)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:@"Migration unsuccessful"];
    }
    else
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeInfo methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:@"Migration successful"];
    }
    [[UIApplication sharedApplication] endBackgroundTask:bgTask];
    bgTask = UIBackgroundTaskInvalid;
    return success;
}

+ (BOOL)progressivelyMigrateURL:(NSURL *)sourceStoreURL ofType:(NSString *)type toModel:(NSManagedObjectModel *)finalModel error:(NSError *)error
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:type URL:sourceStoreURL error:&error];
    if (error)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
    }
    if (!sourceMetadata)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@ is nil", stringFromVariable(sourceMetadata)]];
        return NO;
    }
    
    if ([finalModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata])
    {
        error = nil;
        return YES;
    }
    
    NSManagedObjectModel *sourceModel = [NSManagedObjectModel mergedModelFromBundles:@[[NSBundle mainBundle]] forStoreMetadata:sourceMetadata];
    NSManagedObjectModel *destinationModel;
    NSMappingModel *mappingModel;
    NSString *modelName;
    BOOL success = [CoreDataController getDestinationModel:&destinationModel mappingModel:&mappingModel modelName:&modelName forSourceModel:sourceModel error:&error];
    if (error)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
    }
    if (!success)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"Could not get %@, %@, and/or %@ for %@", stringFromVariable(destinationModel), stringFromVariable(mappingModel), stringFromVariable(modelName), stringFromVariable(sourceModel)]];
        return NO;
    }
    
    NSArray *mappingModels = @[mappingModel];
    NSURL *destinationStoreURL = [CoreDataController destinationStoreURLWithSourceStoreURL:sourceStoreURL modelName:modelName];
    NSMigrationManager *manager = [[NSMigrationManager alloc] initWithSourceModel:sourceModel destinationModel:destinationModel];
    for (NSMappingModel *mappingModel in mappingModels)
    {
        success = ([manager migrateStoreFromURL:sourceStoreURL type:type options:nil withMappingModel:mappingModel toDestinationURL:destinationStoreURL destinationType:type destinationOptions:nil error:&error] && success);
    }
    if (!success)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"Could not successfully migrate all %@", stringFromVariable(mappingModels)]];
        return NO;
    }
    
    success = [self backupSourceStoreAtURL:sourceStoreURL movingDestinationStoreAtURL:destinationStoreURL error:error];
    if (error)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
    }
    if (!success)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"Could not back up source store at %@ to %@", sourceStoreURL, destinationStoreURL]];
        return NO;
    }
    
    return [self progressivelyMigrateURL:sourceStoreURL ofType:type toModel:finalModel error:error];
}

+ (NSURL *)sourceStoreURL
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    return [[SandboxPrivateInfo applicationDocumentsDirectory] URLByAppendingPathComponent:CORE_DATA_FILENAME];
}

+ (BOOL)getDestinationModel:(NSManagedObjectModel **)destinationModel mappingModel:(NSMappingModel **)mappingModel modelName:(NSString **)modelName forSourceModel:(NSManagedObjectModel *)sourceModel error:(NSError **)error
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSArray *modelPaths = [CoreDataController modelPaths];
    if (!modelPaths.count)
    {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary setValue:@"No models found in bundle" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Zarra" code:8001 userInfo:dictionary];
        return NO;
    }
    
    NSManagedObjectModel *model;
    NSMappingModel *mapping;
    NSString *modelPath;
    for (modelPath in modelPaths)
    {
        model = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:modelPath]];
        mapping = [NSMappingModel mappingModelFromBundles:@[[NSBundle mainBundle]] forSourceModel:sourceModel destinationModel:model];
        if (mapping) break;
    }
    if (!mapping)
    {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary setValue:@"No models found in bundle" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Zarra" code:8001 userInfo:dictionary];
        return NO;
    }
    
    *destinationModel = model;
    *mappingModel = mapping;
    *modelName = modelPath.lastPathComponent.stringByDeletingPathExtension;
    return YES;
}

+ (NSArray *)modelPaths
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSMutableArray *modelPaths = [NSMutableArray array];
    NSArray *momdArray = [[NSBundle mainBundle] pathsForResourcesOfType:CORE_DATA_MODEL_DIRECTORY_EXTENSION inDirectory:nil];
    for (NSString *momdPath in momdArray)
    {
        NSString *resourceSubpath = [momdPath lastPathComponent];
        NSArray *array = [[NSBundle mainBundle] pathsForResourcesOfType:CORE_DATA_MODEL_FILE_EXTENSION inDirectory:resourceSubpath];
        [modelPaths addObjectsFromArray:array];
    }
    NSArray *otherModels = [[NSBundle mainBundle] pathsForResourcesOfType:CORE_DATA_MODEL_FILE_EXTENSION inDirectory:nil];
    [modelPaths addObjectsFromArray:otherModels];
    return modelPaths;
}

+ (NSURL *)destinationStoreURLWithSourceStoreURL:(NSURL *)sourceStoreURL modelName:(NSString *)modelName
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSString *storeExtension = sourceStoreURL.path.pathExtension;
    NSString *storePath = sourceStoreURL.path.stringByDeletingPathExtension;
    storePath = [NSString stringWithFormat:@"%@.%@.%@", storePath, modelName, storeExtension];
    return [NSURL fileURLWithPath:storePath];
}

+ (BOOL)backupSourceStoreAtURL:(NSURL *)sourceStoreURL movingDestinationStoreAtURL:(NSURL *)destinationStoreURL error:(NSError *)error
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *backupPath = [NSTemporaryDirectory() stringByAppendingPathComponent:guid];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager moveItemAtPath:sourceStoreURL.path toPath:backupPath error:&error];
    if (error)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
    }
    if (!success)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"Failed to move item at %@ to %@", sourceStoreURL.path, backupPath]];
        return NO;
    }
    
    success = [fileManager moveItemAtPath:destinationStoreURL.path toPath:sourceStoreURL.path error:&error];
    if (error)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
    }
    if (!success)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"Could not move item at %@ to %@; reverting changes", destinationStoreURL.path, sourceStoreURL.path]];
        [fileManager moveItemAtPath:backupPath toPath:sourceStoreURL.path error:nil];
        return NO;
    }
    
    return YES;
}

@end