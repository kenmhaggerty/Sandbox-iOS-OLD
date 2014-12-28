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
    else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeSetup customCategory:@"Core Data" message:@"Could not initialize self"];
    return self;
}

- (void)dealloc
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategory:@"Core Data" message:nil];
    
    [self teardown];
}

#pragma mark - // PUBLIC METHODS (General) //

+ (BOOL)save
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategory:@"Core Data" message:nil];
    
    NSManagedObjectContext *managedObjectContext = [CoreDataController managedObjectContext];
    if (managedObjectContext)
    {
        __block NSError *error;
        __block BOOL succeeded;
        [managedObjectContext performBlockAndWait:^{
            succeeded = [managedObjectContext save:&error];
        }];
        if (!error)
        {
            if (succeeded)
            {
                [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeInfo methodType:AKMethodTypeUnspecified customCategory:@"Core Data" message:@"Save successful"];
                return YES;
            }
            else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeUnspecified customCategory:@"Core Data" message:@"Could not save"];
        }
        else
        {
            NSArray *detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
            if ((detailedErrors) && (detailedErrors.count))
            {
                for (NSError *detailedError in detailedErrors) [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeUnspecified customCategory:@"Core Data" message:[NSString stringWithFormat:@"%@", [detailedError userInfo]]];
            }
            else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeUnspecified customCategory:@"Core Data" message:[NSString stringWithFormat:@"%@", [error userInfo]]];
        }
    }
    else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeUnspecified customCategory:@"Core Data" message:@"managedObjectContext is nil"];
    return NO;
}

#pragma mark - // PUBLIC METHODS (Existence) //

//+ (BOOL)bookExistsWithTitle:(NSString *)title author:(Author *)author
//{
//    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategory:@"Core Data" message:nil];
//    
//    NSManagedObjectContext *managedObjectContext = [CoreDataController managedObjectContext];
//    if (managedObjectContext)
//    {
//        __block NSUInteger count;
//        __block NSError *error;
//        [managedObjectContext performBlockAndWait:^{
//            NSFetchRequest *request = [[NSFetchRequest alloc] init];
//            [request setEntity:[NSEntityDescription entityForName:NSStringFromClass([Book class]) inManagedObjectContext:managedObjectContext]];
//            [request setPredicate:[NSPredicate predicateWithFormat:@"(%K == %@) AND (%K == %@)", NSStringFromSelector(@selector(title)), title, NSStringFromSelector(@selector(author)), author]];
//            count = [managedObjectContext countForFetchRequest:request error:&error];
//        }];
//        if (!error)
//        {
//            [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeInfo methodType:AKMethodTypeGetter customCategory:@"Core Data" message:[NSString stringWithFormat:@"Found %lu %@(s) with title %@ and author %@ %@", (unsigned long)count, NSStringFromClass([Book class]), title, author.firstName, author.lastName]];
//            if (count)
//            {
//                return YES;
//            }
//        }
//        else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeGetter customCategory:@"Core Data" message:[NSString stringWithFormat:@"%@, %@", error, [error userInfo]]];
//    }
//    else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeGetter customCategory:@"Core Data" message:@"managedObjectContext is nil"];
//    return NO;
//}

+ (BOOL)albumExistsWithTitle:(NSString *)title composer:(NSString *)composer author:(Author *)author
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategory:@"Core Data" message:nil];
    
    NSManagedObjectContext *managedObjectContext = [CoreDataController managedObjectContext];
    if (managedObjectContext)
    {
        __block NSUInteger count;
        __block NSError *error;
        [managedObjectContext performBlockAndWait:^{
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setEntity:[NSEntityDescription entityForName:NSStringFromClass([Album class]) inManagedObjectContext:managedObjectContext]];
            [request setPredicate:[NSPredicate predicateWithFormat:@"(%K == %@) AND (%K == %@) AND (%K == %@)", NSStringFromSelector(@selector(title)), title, NSStringFromSelector(@selector(composer)), composer, NSStringFromSelector(@selector(author)), author]];
            count = [managedObjectContext countForFetchRequest:request error:&error];
        }];
        if (!error)
        {
            [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeInfo methodType:AKMethodTypeGetter customCategory:@"Core Data" message:[NSString stringWithFormat:@"Found %lu %@(s) with title %@, composer %@, and author %@ %@", (unsigned long)count, NSStringFromClass([Album class]), title, composer, author.firstName, author.lastName]];
            if (count)
            {
                return YES;
            }
        }
        else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeGetter customCategory:@"Core Data" message:[NSString stringWithFormat:@"%@, %@", error, [error userInfo]]];
    }
    else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeGetter customCategory:@"Core Data" message:@"managedObjectContext is nil"];
    return NO;
}

#pragma mark - // PUBLIC METHODS (Retrieval) //

+ (Author *)getAuthorWithLastName:(NSString *)lastName firstName:(NSString *)firstName
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategory:@"Core Data" message:nil];
    
    NSManagedObjectContext *managedObjectContext = [CoreDataController managedObjectContext];
    if (managedObjectContext)
    {
        __block NSArray *foundAuthors;
        __block NSError *error;
        [managedObjectContext performBlockAndWait:^{
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setEntity:[NSEntityDescription entityForName:NSStringFromClass([Author class]) inManagedObjectContext:managedObjectContext]];
            [request setPredicate:[NSPredicate predicateWithFormat:@"(%K == %@) AND (%K == %@)", NSStringFromSelector(@selector(lastName)), lastName, NSStringFromSelector(@selector(firstName)), firstName]];
            [request setSortDescriptors:[NSArray arrayWithObjects: [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(editDate)) ascending:YES], nil]];
            foundAuthors = [managedObjectContext executeFetchRequest:request error:&error];
        }];
        if (!error)
        {
            if (foundAuthors.count > 1) [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeGetter customCategory:@"Core Data" message:[NSString stringWithFormat:@"Found %lu %@ object(s) with name %@ %@; returning first object", (unsigned long)foundAuthors.count, NSStringFromClass([Author class]), firstName, lastName]];
            return [foundAuthors firstObject];
        }
        else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeGetter customCategory:@"Core Data" message:[NSString stringWithFormat:@"%@, %@", error, [error userInfo]]];
    }
    else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeGetter customCategory:@"Core Data" message:@"managedObjectContext is nil"];
    return nil;
}

//+ (NSOrderedSet *)getAllBooks
//{
//    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategory:@"Core Data" message:nil];
//    
//    NSManagedObjectContext *managedObjectContext = [CoreDataController managedObjectContext];
//    if (managedObjectContext)
//    {
//        __block NSArray *foundBooks;
//        __block NSError *error;
//        [managedObjectContext performBlockAndWait:^{
//            NSFetchRequest *request = [[NSFetchRequest alloc] init];
//            [request setEntity:[NSEntityDescription entityForName:NSStringFromClass([Book class]) inManagedObjectContext:managedObjectContext]];
//            [request setSortDescriptors:[NSArray arrayWithObjects: [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(editDate)) ascending:NO], nil]];
//            foundBooks = [managedObjectContext executeFetchRequest:request error:&error];
//        }];
//        if (!error)
//        {
//            [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeInfo methodType:AKMethodTypeGetter customCategory:@"Core Data" message:[NSString stringWithFormat:@"Found %lu %@ object(s)", (unsigned long)foundBooks.count, NSStringFromClass([Book class])]];
//            return [NSOrderedSet orderedSetWithArray:foundBooks];
//        }
//        else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeGetter customCategory:@"Core Data" message:[NSString stringWithFormat:@"%@, %@", error, [error userInfo]]];
//    }
//    else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeGetter customCategory:@"Core Data" message:@"managedObjectContext is nil"];
//    return nil;
//}

+ (NSOrderedSet *)getAllAlbums
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategory:@"Core Data" message:nil];
    
    NSManagedObjectContext *managedObjectContext = [CoreDataController managedObjectContext];
    if (managedObjectContext)
    {
        __block NSArray *foundAlbums;
        __block NSError *error;
        [managedObjectContext performBlockAndWait:^{
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setEntity:[NSEntityDescription entityForName:NSStringFromClass([Album class]) inManagedObjectContext:managedObjectContext]];
            [request setSortDescriptors:[NSArray arrayWithObjects: [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(editDate)) ascending:NO], nil]];
            foundAlbums = [managedObjectContext executeFetchRequest:request error:&error];
        }];
        if (!error)
        {
            [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeInfo methodType:AKMethodTypeGetter customCategory:@"Core Data" message:[NSString stringWithFormat:@"Found %lu %@ object(s)", (unsigned long)foundAlbums.count, NSStringFromClass([Album class])]];
            return [NSOrderedSet orderedSetWithArray:foundAlbums];
        }
        else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeGetter customCategory:@"Core Data" message:[NSString stringWithFormat:@"%@, %@", error, [error userInfo]]];
    }
    else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeGetter customCategory:@"Core Data" message:@"managedObjectContext is nil"];
    return nil;
}

#pragma mark - // PUBLIC METHODS (Creation) //

+ (Author *)createAuthorWithLastName:(NSString *)lastName firstName:(NSString *)firstName
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategory:@"Core Data" message:nil];
    
    NSManagedObjectContext *managedObjectContext = [CoreDataController managedObjectContext];
    if (managedObjectContext)
    {
        __block Author *author;
        [managedObjectContext performBlockAndWait:^{
            author = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Author class]) inManagedObjectContext:managedObjectContext];
            [author setEditDate:[NSDate date]];
            [author setLastName:lastName];
            [author setFirstName:firstName];
        }];
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeInfo methodType:AKMethodTypeUnspecified customCategory:@"Core Data" message:[NSString stringWithFormat:@"Created %@ (%@, %@)", NSStringFromClass([Author class]), lastName, firstName]];
        return author;
    }
    else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeUnspecified customCategory:@"Core Data" message:@"managedObjectContext is nil"];
    return nil;
}

//+ (Book *)createBookWithTitle:(NSString *)title author:(Author *)author
//{
//    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategory:@"Core Data" message:nil];
//    
//    NSManagedObjectContext *managedObjectContext = [CoreDataController managedObjectContext];
//    if (managedObjectContext)
//    {
//        __block Book *book;
//        [managedObjectContext performBlockAndWait:^{
//            book = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Book class]) inManagedObjectContext:managedObjectContext];
//            [book setEditDate:[NSDate date]];
//            [book setTitle:title];
//            [book setAuthor:author];
//        }];
//        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeInfo methodType:AKMethodTypeUnspecified customCategory:@"Core Data" message:[NSString stringWithFormat:@"Created %@ \"%@\" (%@, %@)", NSStringFromClass([Book class]), title, author.lastName, author.firstName]];
//        return book;
//    }
//    else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeUnspecified customCategory:@"Core Data" message:@"managedObjectContext is nil"];
//    return nil;
//}

+ (Album *)createAlbumWithTitle:(NSString *)title composer:(NSString *)composer author:(Author *)author
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategory:@"Core Data" message:nil];
    
    NSManagedObjectContext *managedObjectContext = [CoreDataController managedObjectContext];
    if (managedObjectContext)
    {
        __block Album *album;
        [managedObjectContext performBlockAndWait:^{
            album = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Album class]) inManagedObjectContext:managedObjectContext];
            [album setEditDate:[NSDate date]];
            [album setTitle:title];
            [album setComposer:composer];
            [album setAuthor:author];
        }];
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeInfo methodType:AKMethodTypeUnspecified customCategory:@"Core Data" message:[NSString stringWithFormat:@"Created %@ \"%@\" by %@ (%@, %@)", NSStringFromClass([Album class]), title, composer, author.lastName, author.firstName]];
        return album;
    }
    else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeUnspecified customCategory:@"Core Data" message:@"managedObjectContext is nil"];
    return nil;
}

#pragma mark - // PUBLIC METHODS (Deletion) //

+ (BOOL)deleteObject:(NSManagedObject *)object
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategory:@"Core Data" message:nil];
    
    if (object)
    {
        NSManagedObjectContext *managedObjectContext = [CoreDataController managedObjectContext];
        if (managedObjectContext)
        {
            [managedObjectContext performBlockAndWait:^{
                [managedObjectContext deleteObject:object];
            }];
            return YES;
        }
        else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeUnspecified customCategory:@"Core Data" message:@"managedObjectContext is nil"];
    }
    else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeUnspecified customCategory:@"Core Data" message:@"object is nil"];
    return NO;
}

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

@end