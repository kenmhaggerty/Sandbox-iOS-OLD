//
//  LoginManager+Delegate.h
//  Sandbox
//
//  Created by Ken M. Haggerty on 8/9/15.
//  Copyright (c) 2015 MCMDI. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import "LoginManager.h"
#import "SandboxCentralDispatch+PRIVATE.h"

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

@interface LoginManager (Delegate) <AccountDelegate>
+ (id)delegateForCentralDispatch;
- (User *)currentUser;
- (NSString *)currentUsername;
@end
