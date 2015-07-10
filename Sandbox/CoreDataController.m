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
#import "AKPrivateInfo.h"
#import "Message+RW.h"

#pragma mark - // DEFINITIONS (Private) //

#define MESSAGE_ID_LENGTH 10
#define MESSAGE_ID_CHARACTERS @"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

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
+ (BOOL)progressivelyMigrateURL:(NSURL *)sourceStoreURL ofType:(NSString *)type toModel:(NSManagedObjectModel *)finalModel error:(NSError **)error;
+ (NSManagedObjectModel *)sourceModelForSourceMetadata:(NSDictionary *)sourceMetadata;
+ (BOOL)getDestinationModel:(NSManagedObjectModel **)destinationModel mappingModel:(NSMappingModel **)mappingModel modelName:(NSString **)modelName forSourceModel:(NSManagedObjectModel *)sourceModel error:(NSError **)error;
+ (NSArray *)modelPaths;
+ (NSURL *)destinationStoreURLWithSourceStoreURL:(NSURL *)sourceStoreURL modelName:(NSString *)modelName;
+ (BOOL)backupSourceStoreAtURL:(NSURL *)sourceStoreURL movingDestinationStoreAtURL:(NSURL *)destinationStoreURL error:(NSError **)error;

@end

@implementation CoreDataController

#pragma mark - // SETTERS AND GETTERS //

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSManagedObjectContext *)managedObjectContext
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_CORE_DATA] message:nil];
    
    if (!_managedObjectContext)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_CORE_DATA] message:nil];

    if (!_managedObjectModel)
    {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:CORE_DATA_MODEL_NAME withExtension:CORE_DATA_MODEL_EXTENSION];
        if (modelURL)
        {
            _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        }
        else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeGetter customCategories:@[AKD_CORE_DATA] message:@"modelURL is nil"];
    }
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_CORE_DATA] message:nil];
    
    if (!_persistentStoreCoordinator)
    {
        if (![NSThread isMainThread])
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                (void)[self persistentStoreCoordinator];
            });
            return _persistentStoreCoordinator;
        }
        NSURL *storeURL = [[AKPrivateInfo applicationDocumentsDirectory] URLByAppendingPathComponent:CORE_DATA_FILENAME];
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
            [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeUnspecified customCategories:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@, %@", error, [error userInfo]]];
            abort();
        }
    }
    return _persistentStoreCoordinator;
}

#pragma mark - // INITS AND LOADS //

- (id)init
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_CORE_DATA] message:nil];
    
    self = [super init];
    if (self)
    {
        [self setup];
    }
    else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeSetup customCategories:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"Could not initialize %@", stringFromVariable(self)]];
    return self;
}

- (void)dealloc
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_CORE_DATA] message:nil];
    
    [self teardown];
}

#pragma mark - // PUBLIC METHODS (General) //

#pragma mark - // PUBLIC METHODS (Existence) //

+ (BOOL)messageExistsWithId:(NSString *)messageId
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_CORE_DATA] message:nil];
    
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
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeGetter customCategories:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@, %@", error, [error userInfo]]];
        return NO;
    }
    
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeInfo methodType:AKMethodTypeGetter customCategories:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"Found %lu %@ object(s)", (unsigned long)count, NSStringFromClass([Message class])]];
    if (count == 0) return NO;
    return YES;
}

#pragma mark - // PUBLIC METHODS (Retrieval) //

+ (NSOrderedSet *)getMessagesSentToUser:(NSString *)recipient
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = [CoreDataController managedObjectContext];
    if (!managedObjectContext)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeGetter customCategories:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@ is nil", stringFromVariable(managedObjectContext)]];
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
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeGetter customCategories:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@, %@", error, [error userInfo]]];
        return nil;
    }
    
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeInfo methodType:AKMethodTypeGetter customCategories:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"Found %lu %@ object(s) with %@ %@", (unsigned long)foundMessages.count, NSStringFromClass([Message class]), stringFromVariable(recipient), recipient]];
    return [NSOrderedSet orderedSetWithArray:foundMessages];
}

+ (NSOrderedSet *)getMessagesSentByUser:(NSString *)sender
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = [CoreDataController managedObjectContext];
    if (!managedObjectContext)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeGetter customCategories:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@ is nil", stringFromVariable(managedObjectContext)]];
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
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeGetter customCategories:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@, %@", error, [error userInfo]]];
        return nil;
    }
    
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeInfo methodType:AKMethodTypeGetter customCategories:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"Found %lu %@ object(s) with %@ %@", (unsigned long)foundMessages.count, NSStringFromClass([Message class]), stringFromVariable(sender), sender]];
    return [NSOrderedSet orderedSetWithArray:foundMessages];
}

+ (Message *)getMessageWithId:(NSString *)messageId
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = [CoreDataController managedObjectContext];
    if (!managedObjectContext)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeGetter customCategories:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@ is nil", stringFromVariable(managedObjectContext)]];
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
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeGetter customCategories:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@, %@", error, [error userInfo]]];
        return nil;
    }
    
    if (foundMessages.count > 1) [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeGetter customCategories:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"Found %lu %@ object(s) with %@ %@; returning first object", (unsigned long)foundMessages.count, NSStringFromClass([Message class]), stringFromVariable(messageId), messageId]];
    return [foundMessages firstObject];
}

#pragma mark - // PUBLIC METHODS (Creation) //

+ (Message *)createMessageWithText:(NSString *)text fromUser:(NSString *)sender toUser:(NSString *)recipient onDate:(NSDate *)sendDate withId:(NSString *)messageId
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator customCategories:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = [CoreDataController managedObjectContext];
    if (!managedObjectContext)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeCreator customCategories:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@ is nil", stringFromVariable(managedObjectContext)]];
        return nil;
    }
    
    __block Message *message;
    [managedObjectContext performBlockAndWait:^{
        message = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Message class]) inManagedObjectContext:managedObjectContext];
        if (messageId) [message setMessageId:messageId];
        else [message setMessageId:[AKGenerics randomStringWithCharacters:MESSAGE_ID_CHARACTERS length:MESSAGE_ID_LENGTH]];
        [message setSender:sender];
        [message setRecipient:recipient];
        [message setText:text];
        [message setSendDate:sendDate];
    }];
    
    if (![CoreDataController save])
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeCreator customCategories:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"Could not create %@", stringFromVariable(message)]];
        if (![CoreDataController deleteObject:message])
        {
            [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeCreator customCategories:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"Could not delete %@", stringFromVariable(message)]];
        }
        return nil;
    }
    
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeInfo methodType:AKMethodTypeCreator customCategories:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"Created %@ with %@ %@ and %@ %@", NSStringFromClass([Message class]), stringFromVariable(sender), sender, stringFromVariable(recipient), recipient]];
    return message;
}

#pragma mark - // PUBLIC METHODS (Deletion) //

+ (BOOL)deleteObject:(NSManagedObject *)object
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = [CoreDataController managedObjectContext];
    if (!managedObjectContext)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeUnspecified customCategories:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@ is nil", stringFromVariable(managedObjectContext)]];
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

+ (id)sharedController
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_CORE_DATA] message:nil];
    
    static dispatch_once_t once;
    static CoreDataController *sharedController;
    dispatch_once(&once, ^{
        sharedController = [[CoreDataController alloc] init];
    });
    return sharedController;
}

+ (NSManagedObjectContext *)managedObjectContext
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_CORE_DATA] message:nil];
    
    return [[CoreDataController sharedController] managedObjectContext];
}

+ (NSManagedObjectModel *)managedObjectModel
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_CORE_DATA] message:nil];
    
    return [[CoreDataController sharedController] managedObjectModel];
}

+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_CORE_DATA] message:nil];
    
    return [[CoreDataController sharedController] persistentStoreCoordinator];
}

- (void)setup
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_CORE_DATA] message:nil];
}

- (void)teardown
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_CORE_DATA] message:nil];
}

+ (BOOL)save
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = [CoreDataController managedObjectContext];
    if (!managedObjectContext)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeUnspecified customCategories:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@ is nil", stringFromVariable(managedObjectContext)]];
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
                [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeUnspecified customCategories:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@", [detailedError userInfo]]];
            }
        }
        else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeUnspecified customCategories:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@", [error userInfo]]];
        return NO;
    }
    
    if (!succeeded)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeUnspecified customCategories:@[AKD_CORE_DATA] message:@"Could not save"];
        return NO;
    }
    
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeInfo methodType:AKMethodTypeUnspecified customCategories:@[AKD_CORE_DATA] message:@"Save successful"];
    return YES;
}

+ (BOOL)progressivelyMigrateURL:(NSURL *)sourceStoreURL ofType:(NSString *)type toModel:(NSManagedObjectModel *)finalModel error:(NSError **)error
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_CORE_DATA] message:nil];
    
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:type URL:sourceStoreURL error:error];
    if (!sourceMetadata)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeSetup customCategories:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@ is nil", stringFromVariable(sourceMetadata)]];
        return NO;
    }
    
    if ([finalModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata])
    {
        if (NULL != error) *error = nil;
        return YES;
    }
    
    NSManagedObjectModel *sourceModel = [CoreDataController sourceModelForSourceMetadata:sourceMetadata];
    NSManagedObjectModel *destinationModel = nil;
    NSMappingModel *mappingModel = nil;
    NSString *modelName = nil;
    if (![CoreDataController getDestinationModel:&destinationModel mappingModel:&mappingModel modelName:&modelName forSourceModel:sourceModel error:error])
    {
        return NO;
    }
    
    NSURL *destinationStoreURL = [CoreDataController destinationStoreURLWithSourceStoreURL:sourceStoreURL modelName:modelName];
    NSMigrationManager *manager = [[NSMigrationManager alloc] initWithSourceModel:sourceModel destinationModel:destinationModel];
    if (![manager migrateStoreFromURL:sourceStoreURL type:type options:nil withMappingModel:mappingModel toDestinationURL:destinationStoreURL destinationType:type destinationOptions:nil error:error])
    {
        return NO;
    }
    
    if (![CoreDataController backupSourceStoreAtURL:sourceStoreURL movingDestinationStoreAtURL:destinationStoreURL error:error])
    {
        return NO;
    }
    
    return [self progressivelyMigrateURL:sourceStoreURL ofType:type toModel:finalModel error:error];
}

+ (NSManagedObjectModel *)sourceModelForSourceMetadata:(NSDictionary *)sourceMetadata
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_CORE_DATA] message:nil];
    
    return [NSManagedObjectModel mergedModelFromBundles:@[[NSBundle mainBundle]] forStoreMetadata:sourceMetadata];
}

+ (BOOL)getDestinationModel:(NSManagedObjectModel **)destinationModel mappingModel:(NSMappingModel **)mappingModel modelName:(NSString **)modelName forSourceModel:(NSManagedObjectModel *)sourceModel error:(NSError **)error
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_CORE_DATA] message:nil];
    
    NSArray *modelPaths = [CoreDataController modelPaths];
    if (!modelPaths.count)
    {
        if (NULL != error) *error = [NSError errorWithDomain:@"Zarra" code:8001 userInfo:@{NSLocalizedDescriptionKey:@"No models found!"}];
        return NO;
    }
    
    NSManagedObjectModel *model = nil;
    NSMappingModel *mapping = nil;
    NSString *modelPath = nil;
    for (modelPath in modelPaths)
    {
        model = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:modelPath]];
        mapping = [NSMappingModel mappingModelFromBundles:@[[NSBundle mainBundle]] forSourceModel:sourceModel destinationModel:model];
        if (mapping)
        {
            break;
        }
    }
    if (!mapping)
    {
        if (NULL != error) *error = [NSError errorWithDomain:@"Zarra" code:8001 userInfo:@{NSLocalizedDescriptionKey:@"No mapping model found in bundle"}];
        return NO;
    }
    
    *destinationModel = model;
    *mappingModel = mapping;
    *modelName = modelPath.lastPathComponent.stringByDeletingPathExtension;
    return YES;
}

+ (NSArray *)modelPaths
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_CORE_DATA] message:nil];
    
    NSMutableArray *modelPaths = [NSMutableArray array];
    NSArray *momdArray = [[NSBundle mainBundle] pathsForResourcesOfType:@"momd" inDirectory:nil];
    for (NSString *momdPath in momdArray)
    {
        NSString *resourceSubpath = [momdPath lastPathComponent];
        NSArray *array = [[NSBundle mainBundle] pathsForResourcesOfType:@"mom" inDirectory:resourceSubpath];
        [modelPaths addObjectsFromArray:array];
    }
    NSArray *otherModels = [[NSBundle mainBundle] pathsForResourcesOfType:@"mom" inDirectory:nil];
    [modelPaths addObjectsFromArray:otherModels];
    return modelPaths;
}

+ (NSURL *)destinationStoreURLWithSourceStoreURL:(NSURL *)sourceStoreURL modelName:(NSString *)modelName
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_CORE_DATA] message:nil];
    
    NSString *storeExtension = sourceStoreURL.path.pathExtension;
    NSString *storePath = sourceStoreURL.path.stringByDeletingPathExtension;
    storePath = [NSString stringWithFormat:@"%@.%@.%@", storePath, modelName, storeExtension];
    return [NSURL fileURLWithPath:storePath];
}

+ (BOOL)backupSourceStoreAtURL:(NSURL *)sourceStoreURL movingDestinationStoreAtURL:(NSURL *)destinationStoreURL error:(NSError **)error
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_CORE_DATA] message:nil];
    
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *backupPath = [NSTemporaryDirectory() stringByAppendingPathComponent:guid];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager moveItemAtPath:sourceStoreURL.path toPath:backupPath error:error])
    {
        return NO;
    }
    
    if (![fileManager moveItemAtPath:destinationStoreURL.path toPath:sourceStoreURL.path error:error])
    {
        [fileManager moveItemAtPath:backupPath toPath:sourceStoreURL.path error:nil];
        return NO;
    }
    
    return YES;
}

@end