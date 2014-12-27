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
#import "CoreDataController.h"

#pragma mark - // DEFINITIONS (Private) //

@interface DataManager ()
@end

@implementation DataManager

#pragma mark - // SETTERS AND GETTERS //

#pragma mark - // INITS AND LOADS //

#pragma mark - // PUBLIC METHODS (General) //

+ (BOOL)save
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategory:@"Data Manager" message:nil];
    
    return [CoreDataController save];
}

#pragma mark - // PUBLIC METHODS (Validation) //

#pragma mark - // PUBLIC METHODS (Existence) //

//+ (BOOL)bookExistsWithTitle:(NSString *)title author:(Author *)author
//{
//    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategory:@"Data Manager" message:nil];
//    
//    return [CoreDataController bookExistsWithTitle:title author:author];
//}

+ (BOOL)albumExistsWithTitle:(NSString *)title composer:(NSString *)composer author:(Author *)author
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategory:@"Data Manager" message:nil];
    
    return [CoreDataController albumExistsWithTitle:title composer:composer author:author];
}

#pragma mark - // PUBLIC METHODS (Retrieval) //

//+ (NSOrderedSet *)getAllBooks
//{
//    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategory:@"Data Manager" message:nil];
//    
//    return [CoreDataController getAllBooks];
//}

+ (NSOrderedSet *)getAllAlbums
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategory:@"Data Manager" message:nil];
    
    return [CoreDataController getAllAlbums];
}

#pragma mark - // PUBLIC METHODS (Creation) //

//+ (Book *)createBookWithTitle:(NSString *)title author:(Author *)author
//{
//    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategory:@"Data Manager" message:nil];
//    
//    return [CoreDataController createBookWithTitle:title author:author];
//}

+ (Album *)createAlbumWithTitle:(NSString *)title composer:(NSString *)composer author:(Author *)author
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategory:@"Data Manager" message:nil];
    
    return [CoreDataController createAlbumWithTitle:title composer:composer author:author];
}

#pragma mark - // PUBLIC METHODS (Retrieval + Creation) //

+ (Author *)authorWithLastName:(NSString *)lastName firstName:(NSString *)firstName
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategory:@"Data Manager" message:nil];
    
    Author *author = [CoreDataController getAuthorWithLastName:lastName firstName:firstName];
    if (!author) author = [CoreDataController createAuthorWithLastName:lastName firstName:firstName];
    return author;
}

#pragma mark - // PUBLIC METHODS (Deletion) //

+ (BOOL)deleteObject:(NSManagedObject *)object
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategory:@"Data Manager" message:nil];
    
    return [CoreDataController deleteObject:object];
}

#pragma mark - // PUBLIC METHODS (Debugging) //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS //

@end