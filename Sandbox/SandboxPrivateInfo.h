//
//  SandboxPrivateInfo.h
//  Sandbox
//
//  Created by Ken M. Haggerty on 7/23/13.
//  Copyright (c) 2013 Eureka Valley Co. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

@interface SandboxPrivateInfo : NSObject

// LOCAL //

+ (NSString *)pathForPrivateDocs;
+ (NSURL *)applicationDocumentsDirectory;

// PARSE //

+ (NSString *)parseApplicationId;
+ (NSString *)parseClientKey;

// REACHABILITY //

+ (NSString *)reachabilityDomain;

@end
