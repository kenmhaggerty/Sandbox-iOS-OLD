//
//  Author.m
//  Sandbox
//
//  Created by Ken M. Haggerty on 12/25/14.
//  Copyright (c) 2014 MCMDI. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "Author.h"
#import "AKDebugger.h"
#import "Book.h"

#pragma mark - // DEFINITIONS (Private) //

@interface Author ()
- (void)setup;
- (void)teardown;
@end

@implementation Author

#pragma mark - // SETTERS AND GETTERS //

@dynamic editDate;
@dynamic lastName;
@dynamic firstName;
@dynamic books;

#pragma mark - // INITS AND LOADS //

//- (id)initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context
//{
//    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategory:@"Core Data" message:nil];
//    
//    self = [super initWithEntity:entity insertIntoManagedObjectContext:context];
//    if (self)
//    {
//        [self setup];
//    }
//    else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeSetup customCategory:@"Core Data" message:@"Could not initialize self"];
//    return self;
//}

- (void)awakeFromFetch
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategory:@"Core Data" message:nil];
    
//    [super awakeFromFetch];
    [self setup];
}

- (void)awakeFromInsert
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategory:@"Core Data" message:nil];
    
//    [super awakeFromInsert];
    [self setup];
}

- (void)willTurnIntoFault
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategory:@"Core Data" message:nil];
    
    [super willTurnIntoFault];
}

- (void)didTurnIntoFault
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategory:@"Core Data" message:nil];
    
//    [super didTurnIntoFault];
    [self teardown];
}

- (void)prepareForDeletion
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategory:@"Core Data" message:nil];
    
    [super prepareForDeletion];
}

//- (void)dealloc
//{
//    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategory:@"Core Data" message:nil];
//    
//    [self teardown];
//}

#pragma mark - // PUBLIC METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS //

- (void)setup
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategory:@"Core Data" message:nil];
}

- (void)teardown
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategory:@"Core Data" message:nil];
}

@end