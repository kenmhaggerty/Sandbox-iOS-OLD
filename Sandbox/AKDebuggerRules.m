//
//  AKDebuggerRules.m
//  Sandbox
//
//  Created by Ken M. Haggerty on 10/11/13.
//  Copyright (c) 2013 Eureka Valley Co. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "AKDebuggerRules.h"

#pragma mark - // DEFINITIONS (Private) //

// RULES (General) //

#define MASTER_ON YES

#define PRINT_CLASS_METHODS YES
#define PRINT_INSTANCE_METHODS YES

#define PRINT_SETUP YES
#define PRINT_SETTERS YES
#define PRINT_GETTERS YES
#define PRINT_VALIDATORS YES
#define PRINT_UNSPECIFIED YES

#define PRINT_METHOD_NAMES YES
#define PRINT_EMERGENCIES YES
#define PRINT_ALERTS YES
#define PRINT_FAILURES YES
#define PRINT_ERRORS YES
#define PRINT_WARNINGS YES
#define PRINT_NOTICES YES
#define PRINT_INFO YES
#define PRINT_DEBUG YES

// RULES (Custom Categories) //

#define CUSTOM_CATEGORIES_TO_PRINT [NSSet setWithObjects:nil]
#define CUSTOM_CATEGORIES_TO_SKIP [NSSet setWithObjects:nil]

// RULES (View Controllers) //

#define PRINT_VIEWCONTROLLERS YES
#define VIEWCONTROLLERS_TO_SKIP [NSSet setWithObjects:@"ExampleViewController", nil]

// RULES (Views) //

#define PRINT_VIEWS YES
#define VIEWS_TO_SKIP [NSSet setWithObjects:@"ExampleView", nil]

// RULES (Other) //

#define PRINT_OTHERCLASSES YES
#define CLASSES_TO_SKIP [NSSet setWithObjects:@"ExampleClass", nil]
#define METHODS_TO_SKIP [NSSet setWithObjects:@"exampleMethod", nil]
#define METHODS_TO_PRINT nil

// RULES (Categories) //

#define PRINT_CATEGORIES YES
#define CATEGORIES_TO_SKIP [NSSet setWithObjects:@"ExampleCategory", nil]

// FORMATTING //

// OTHER //

@implementation AKDebuggerRules

#pragma mark - // SETTERS AND GETTERS //

#pragma mark - // INITS AND LOADS //

#pragma mark - // PUBLIC METHODS (General) //

+ (BOOL)masterOn
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return MASTER_ON;
}

+ (BOOL)printClassMethods
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return PRINT_CLASS_METHODS;
}

+ (BOOL)printInstanceMethods
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return PRINT_INSTANCE_METHODS;
}

+ (BOOL)printSetup
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return PRINT_SETUP;
}

+ (BOOL)printSetters
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return PRINT_SETTERS;
}

+ (BOOL)printGetters
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return PRINT_GETTERS;
}

+ (BOOL)printValidators
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return PRINT_VALIDATORS;
}

+ (BOOL)printUnspecified
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return PRINT_UNSPECIFIED;
}

+ (BOOL)printMethodNames
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return PRINT_METHOD_NAMES;
}

+ (BOOL)printEmergencies
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return PRINT_EMERGENCIES;
}

+ (BOOL)printAlerts
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return PRINT_ALERTS;
}

+ (BOOL)printFailures
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return PRINT_FAILURES;
}

+ (BOOL)printErrors
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return PRINT_ERRORS;
}

+ (BOOL)printWarnings
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return PRINT_WARNINGS;
}

+ (BOOL)printNotices
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return PRINT_NOTICES;
}

+ (BOOL)printInformation
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return PRINT_INFO;
}

+ (BOOL)printDebug
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return PRINT_DEBUG;
}

#pragma mark - // PUBLIC METHODS (Custom Categories) //

+ (NSSet *)customCategoriesToPrint
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return CUSTOM_CATEGORIES_TO_PRINT;
}

+ (NSSet *)customCategoriesToSkip
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return CUSTOM_CATEGORIES_TO_SKIP;
}

#pragma mark - // PUBLIC METHODS (View Controllers) //

+ (BOOL)printViewControllers
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return PRINT_VIEWCONTROLLERS;
}

+ (NSSet *)viewControllersToSkip
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return VIEWCONTROLLERS_TO_SKIP;
}

#pragma mark - // PUBLIC METHODS (Views) //

+ (BOOL)printViews
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return PRINT_VIEWS;
}

+ (NSSet *)viewsToSkip
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return VIEWS_TO_SKIP;
}

#pragma mark - // PUBLIC METHODS (Other) //

+ (BOOL)printOtherClasses
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return PRINT_OTHERCLASSES;
}

+ (NSSet *)otherClassesToSkip
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return CLASSES_TO_SKIP;
}

+ (NSSet *)methodsToSkip
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return METHODS_TO_SKIP;
}

+ (NSSet *)methodsToPrint
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return METHODS_TO_PRINT;
}

#pragma mark - // PUBLIC METHODS (Categories) //

+ (BOOL)printCategories
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return PRINT_CATEGORIES;
}

+ (NSSet *)categoriesToSkip
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return CATEGORIES_TO_SKIP;
}

#pragma mark - // PUBLIC METHODS (Debugging) //

+ (BOOL)test
{
    if (PRINT_DEBUGGER) AKLog(@"%s", __PRETTY_FUNCTION__);
    
    return YES;
}

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS //

@end