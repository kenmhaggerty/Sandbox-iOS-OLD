//
//  Message.m
//  Sandbox
//
//  Created by Ken M. Haggerty on 5/16/15.
//  Copyright (c) 2014 MCMDI. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "Message.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#pragma mark - // DEFINITIONS (Private) //

@interface Message ()
- (void)setup;
- (void)teardown;
@end

@implementation Message

#pragma mark - // SETTERS AND GETTERS //

@dynamic recipient;
@dynamic sendDate;
@dynamic sender;
@dynamic text;

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
    
    [self teardown];
    //    [super didTurnIntoFault];
}

- (void)prepareForDeletion
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategory:@"Core Data" message:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICIATION_MESSAGE_WILL_BE_DELETED object:self];
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