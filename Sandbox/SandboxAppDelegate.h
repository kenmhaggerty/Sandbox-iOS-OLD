//
//  SandboxAppDelegate.h
//  Sandbox
//
//  Created by Ken Haggerty on 5/2/12.
//  Copyright (c) 2012 MCMDI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface SandboxAppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (readonly, nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (readonly, nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
- (void)saveContext;
- (NSString *)applicationDocumentsDirectory;
@end