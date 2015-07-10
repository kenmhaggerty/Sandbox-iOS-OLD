//
//  DataManager.m
//  Databox
//
//  Created by Ken M. Haggerty on 7/11/13.
//  Copyright (c) 2013 Eureka Valley Co. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "DataManager.h"
#import "AKDebugger.h"
#import "AKGenerics.h"
#import "AKPrivateInfo.h"
#import "CoreDataController.h"
#import "Message+RW.h"
#import <Parse/Parse.h>

#pragma mark - // DEFINITIONS (Private) //

#define USERNAME_KEY @"Username"
#define DATA_FILENAME @"data.plist"
#define CREDENTIALS_FILENAME @"local.credentials"

@interface DataManager ()
@property (nonatomic, strong) NSString *currentUser;
+ (id)sharedManager;
- (void)setup;
- (void)teardown;
+ (BOOL)save;
+ (NSString *)storedUsername;
@end

@implementation DataManager

#pragma mark - // SETTERS AND GETTERS //

- (void)setCurrentUser:(NSString *)currentUser
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter customCategories:nil message:nil];
    
    if ([currentUser isEqualToString:_currentUser]) return;
    
    _currentUser = currentUser;
    if (![currentUser isEqualToString:[DataManager storedUsername]])
    {
        [DataManager save];
    }
    NSArray *channels = @[];
    NSDictionary *userInfo;
    if (currentUser)
    {
        channels = @[currentUser];
        userInfo = [NSDictionary dictionaryWithObject:currentUser forKey:NOTIFICATION_OBJECT_KEY];
    }
    [[PFInstallation currentInstallation] setChannels:channels];
    [[PFInstallation currentInstallation] saveInBackground];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CURRENTUSER_DID_CHANGE object:self userInfo:userInfo];
}

#pragma mark - // INITS AND LOADS //

- (id)init
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:nil message:nil];
    
    self = [super init];
    if (self)
    {
        [self setup];
    }
    else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeSetup customCategories:nil message:[NSString stringWithFormat:@"Could not initialize %@", stringFromVariable(self)]];
    return self;
}

- (void)dealloc
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:nil message:nil];
    
    [self teardown];
}

#pragma mark - // PUBLIC METHODS (General) //

#pragma mark - // PUBLIC METHODS (Validation) //

#pragma mark - // PUBLIC METHODS (Existence) //

#pragma mark - // PUBLIC METHODS (Retrieval) //

+ (NSOrderedSet *)getMessagesSentToUser:(NSString *)recipient
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
    
    return [CoreDataController getMessagesSentToUser:recipient];
}

+ (NSOrderedSet *)getMessagesSentByUser:(NSString *)sender
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
    
    return [CoreDataController getMessagesSentByUser:sender];
}

+ (Message *)getMessageWithId:(NSString *)messageId
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
    
    return [CoreDataController getMessageWithId:messageId];
}

#pragma mark - // PUBLIC METHODS (Creation) //

+ (BOOL)createMessageWithText:(NSString *)text fromUser:(NSString *)sender toUser:(NSString *)recipient onDate:(NSDate *)sendDate withId:(NSString *)messageId andBroadcast:(BOOL)broadcast
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator customCategories:nil message:nil];
    
    if ([CoreDataController messageExistsWithId:messageId])
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeInfo methodType:AKMethodTypeCreator customCategories:nil message:[NSString stringWithFormat:@"%@ already exists with %@ %@", stringFromVariable(message), stringFromVariable(messageId), messageId]];
        return NO;
    }
    
    Message *message = [CoreDataController createMessageWithText:text fromUser:sender toUser:recipient onDate:sendDate withId:messageId];
    if (!message)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeCreator customCategories:nil message:[NSString stringWithFormat:@"Could not create %@", stringFromVariable(message)]];
        return NO;
    }
    
    if (broadcast)
    {
        PFPush *push = [[PFPush alloc] init];
        messageId = message.messageId;
        NSString *installationId = [PFInstallation currentInstallation].objectId;
        [push setData:@{@"pushType":@"newMessage", @"messageId":messageId, @"installationId":installationId, @"sender":sender, @"alert":text, @"sendDate":sendDate}];
        [push setChannel:recipient];
        [push sendPushInBackground];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MESSAGE_WAS_CREATED object:[DataManager sharedManager] userInfo:[NSDictionary dictionaryWithObject:message forKey:NOTIFICATION_OBJECT_KEY]];
    return YES;
}

#pragma mark - // PUBLIC METHODS (Editing) //

+ (void)setCurrentUser:(NSString *)currentUser
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter customCategories:nil message:nil];
    
    [[DataManager sharedManager] setCurrentUser:currentUser];
}

+ (NSString *)currentUser
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
    
    NSString *currentUser = [[DataManager sharedManager] currentUser];
    if (!currentUser)
    {
        currentUser = [DataManager storedUsername];
        if (currentUser)
        {
            [DataManager setCurrentUser:currentUser];
        }
    }
    return currentUser;
}

+ (void)userDidReadMessage:(Message *)message andBroadcast:(BOOL)broadcast
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:nil message:nil];
    
    if ([message.isRead boolValue]) return;
    
    [message setIsRead:[NSNumber numberWithBool:YES]];
    if (![CoreDataController save])
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeCreator customCategories:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"Could not save %@", stringFromVariable(message)]];
        return;
    }
    
    if (broadcast)
    {
        PFPush *push = [[PFPush alloc] init];
        NSString *installationId = [PFInstallation currentInstallation].objectId;
        [push setData:@{@"pushType":@"messageRead",@"messageId":message.messageId, @"installationId":installationId}];
        [push setChannel:message.sender];
        [push sendPushInBackground];
    }
}

+ (void)incrementBadge
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter customCategories:nil message:nil];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[UIApplication sharedApplication] applicationIconBadgeNumber]+1];
}

+ (void)decrementBadge
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter customCategories:nil message:nil];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[UIApplication sharedApplication] applicationIconBadgeNumber]-1];
}

+ (void)setBadgeToCount:(NSUInteger)count
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter customCategories:nil message:nil];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:count];
}

#pragma mark - // PUBLIC METHODS (Deletion) //

+ (BOOL)deleteMessage:(Message *)message
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:nil message:nil];
    
    if (![CoreDataController deleteObject:message])
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeUnspecified customCategories:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"Could not delete %@", stringFromVariable(message)]];
        return NO;
    }
    
    if (![CoreDataController save])
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeCreator customCategories:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"Could not save %@", stringFromVariable(message)]];
        return NO;
    }
    
    return YES;
}

#pragma mark - // PUBLIC METHODS (Observation) //

+ (void)addObserver:(id)observer selector:(SEL)selector name:(NSString *)name
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:nil message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:name object:[DataManager sharedManager]];
}

+ (void)removeObserver:(id)observer name:(NSString *)name
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:nil message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:name object:[DataManager sharedManager]];
}

#pragma mark - // PUBLIC METHODS (Debugging) //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS //

+ (id)sharedManager
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
    
    static dispatch_once_t once;
    static DataManager *sharedManager;
    dispatch_once(&once, ^{
        sharedManager = [[DataManager alloc] init];
    });
    return sharedManager;
}

- (void)setup
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:nil message:nil];
}

- (void)teardown
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:nil message:nil];
}

+ (BOOL)save
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:@[AKD_ACCOUNTS] message:nil];
    
    NSString *pathForPrivateDocs = [AKPrivateInfo pathForPrivateDocs];
    if (!pathForPrivateDocs)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeUnspecified customCategories:@[AKD_ACCOUNTS] message:[NSString stringWithFormat:@"Could not obtain %@", stringFromVariable(pathForPrivateDocs)]];
        return NO;
    }
    
    NSString *dataPath = [pathForPrivateDocs stringByAppendingPathComponent:CREDENTIALS_FILENAME];
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    if (!defaultManager)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeUnspecified customCategories:@[AKD_ACCOUNTS] message:[NSString stringWithFormat:@"Could not obtain %@", stringFromVariable(defaultManager)]];
        return NO;
    }
    
    if (![defaultManager fileExistsAtPath:dataPath])
    {
        NSError *error;
        if (![defaultManager createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:&error])
        {
            [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeUnspecified customCategories:@[AKD_ACCOUNTS] message:[NSString stringWithFormat:@"%@, %@", error, [error userInfo]]];
            return NO;
        }
        
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeInfo methodType:AKMethodTypeUnspecified customCategories:@[AKD_ACCOUNTS] message:@"Created directory"];
    }
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:[[DataManager sharedManager] currentUser] forKey:USERNAME_KEY];
    [archiver finishEncoding];
    return [data writeToFile:[dataPath stringByAppendingPathComponent:DATA_FILENAME] atomically:YES];
}

+ (NSString *)storedUsername
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_ACCOUNTS] message:nil];
    
    NSString *pathForPrivateDocs = [AKPrivateInfo pathForPrivateDocs];
    if (!pathForPrivateDocs)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeGetter customCategories:@[AKD_ACCOUNTS] message:[NSString stringWithFormat:@"%@ is nil", stringFromVariable(pathForPrivateDocs)]];
        return nil;
    }
    
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *files = [defaultManager contentsOfDirectoryAtPath:pathForPrivateDocs error:&error];
    if (error)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeGetter customCategories:@[AKD_ACCOUNTS] message:[NSString stringWithFormat:@"%@, %@", error, [error userInfo]]];
        return nil;
    }
    
    if (!files)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeGetter customCategories:@[AKD_ACCOUNTS] message:@"No saved files"];
        return nil;
    }
    
    NSMutableArray *arrayOfUsernames = [[NSMutableArray alloc] init];
    for (NSString *file in files)
    {
        if ([file.lastPathComponent isEqualToString:CREDENTIALS_FILENAME])
        {
            [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeDebug methodType:AKMethodTypeGetter customCategories:@[AKD_ACCOUNTS] message:@"Found credentials file"];
            NSString *dataPath = [[pathForPrivateDocs stringByAppendingPathComponent:file] stringByAppendingPathComponent:DATA_FILENAME];
            if ([defaultManager fileExistsAtPath:dataPath])
            {
                [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeDebug methodType:AKMethodTypeGetter customCategories:@[AKD_ACCOUNTS] message:[NSString stringWithFormat:@"Found %@", stringFromVariable(dataPath)]];
                NSData *codedData = [[NSData alloc] initWithContentsOfFile:dataPath];
                if (codedData)
                {
                    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeDebug methodType:AKMethodTypeGetter customCategories:@[AKD_ACCOUNTS] message:[NSString stringWithFormat:@"Found %@", stringFromVariable(codedData)]];
                    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:codedData];
                    NSString *username = [unarchiver decodeObjectForKey:USERNAME_KEY];
                    [unarchiver finishDecoding];
                    if (username)
                    {
                        [arrayOfUsernames addObject:username];
                    }
                    else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeGetter customCategories:@[AKD_ACCOUNTS] message:[NSString stringWithFormat:@"%@ is nil", stringFromVariable(username)]];
                }
                else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeGetter customCategories:@[AKD_ACCOUNTS] message:[NSString stringWithFormat:@"%@ is nil", stringFromVariable(codedData)]];
            }
            else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeGetter customCategories:@[AKD_ACCOUNTS] message:[NSString stringWithFormat:@"%@ does not exist", DATA_FILENAME]];
        }
    }
    if (arrayOfUsernames.count > 1) [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeGetter customCategories:@[AKD_ACCOUNTS] message:[NSString stringWithFormat:@"Found %lu usernames; returning last object", (unsigned long)arrayOfUsernames.count]];
    return [arrayOfUsernames firstObject];
}

@end