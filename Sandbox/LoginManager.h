//
//  LoginManager.h
//  Sandbox
//
//  Created by Ken M. Haggerty on 8/7/15.
//  Copyright (c) 2015 MCMDI. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

@interface LoginManager : NSObject
+ (BOOL)createAccountWithEmail:(NSString *)email password:(NSString *)password;
+ (BOOL)logInWithEmail:(NSString *)email password:(NSString *)password;
+ (void)logOut;
@end
