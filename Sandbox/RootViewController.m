//
//  RootViewController.m
//  Sandbox
//
//  Created by Ken M. Haggerty on 8/8/15.
//  Copyright (c) 2015 MCMDI. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "RootViewController.h"
#import "AKDebugger.h"
#import "AKGenerics.h"
#import "CentralDispatch+PRIVATE.h"
#import "SandboxAppInfo.h"
#import "LoginManager.h"
#import "UIAlertController+Info.h"

#pragma mark - // DEFINITIONS (Private) //

#define ALERT_INFO_EMAIL @"email"

@interface RootViewController () <LoginControllerDelegate>
@property (nonatomic, strong) UIAlertController *alertControllerSignIn;
@property (nonatomic, strong) UIAlertController *alertControllerCreateAccount;
@property (nonatomic, strong) UIAlertController *alertControllerSignOut;
@property (nonatomic, strong) UIAlertController *alertControllerDismiss;

// GENERAL //

- (void)setup;
- (void)teardown;

// OBSERVERS //

- (void)addObserversToCentralDispatch;
- (void)removeObserversFromCentralDispatch;

// RESPONDERS //

- (void)currentUserDidChange:(NSNotification *)notification;

// OTHER //

- (void)clearAlertControllers;

@end

@implementation RootViewController

#pragma mark - // SETTERS AND GETTERS //

@synthesize alertControllerSignIn = _alertControllerSignIn;
@synthesize alertControllerCreateAccount = _alertControllerCreateAccount;
@synthesize alertControllerSignOut = _alertControllerSignOut;
@synthesize alertControllerDismiss = _alertControllerDismiss;

- (UIAlertController *)alertControllerSignIn
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
    
    if (_alertControllerSignIn)
    {
        [((UITextField *)[_alertControllerSignIn.textFields objectAtIndex:0]) setText:[_alertControllerSignIn.info objectForKey:ALERT_INFO_EMAIL]];
        return _alertControllerSignIn;
    }
    
    _alertControllerSignIn = [UIAlertController alertControllerWithTitle:TEXT_LOGIN message:nil preferredStyle:UIAlertControllerStyleAlert];
    [_alertControllerSignIn addTextFieldWithConfigurationHandler:^(UITextField *textField){
        [textField setPlaceholder:@"email"];
    }];
    [_alertControllerSignIn addTextFieldWithConfigurationHandler:^(UITextField *textField){
        [textField setPlaceholder:@"password"];
        [textField setSecureTextEntry:YES];
    }];
    [_alertControllerSignIn addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        [self clearAlertControllers];
    }]];
    [_alertControllerSignIn addAction:[UIAlertAction actionWithTitle:TEXT_LOGIN style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        NSString *email = ((UITextField *)[_alertControllerSignIn.textFields objectAtIndex:0]).text;
        if (email.length == 0) email = nil;
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        if (email) [info setObject:email forKey:ALERT_INFO_EMAIL];
        [_alertControllerSignIn setInfo:info];
        
        if (!email)
        {
            [self.alertControllerDismiss setTitle:@"Could Not Sign In"];
            [self.alertControllerDismiss setMessage:[NSString stringWithFormat:@"You must provide an %@ in order to sign in.", stringFromVariable(email)]];
            [self presentViewController:self.alertControllerDismiss animated:YES completion:nil];
            return;
        }
        
        NSString *password = ((UITextField *)[_alertControllerSignIn.textFields objectAtIndex:1]).text;
        if (![LoginManager logInWithEmail:email password:password])
        {
            [self.alertControllerDismiss setTitle:@"Invalid Password"];
            [self.alertControllerDismiss setMessage:@"Make sure you are using the correct password."];
            [self presentViewController:self.alertControllerDismiss animated:YES completion:nil];
            return;
        }
        
        [self.alertControllerDismiss setTitle:@"Welcome!"];
        [self.alertControllerDismiss setMessage:@"You are now logged in."];
        [self presentViewController:self.alertControllerDismiss animated:YES completion:^{
            [self clearAlertControllers];
        }];
    }]];
    [_alertControllerSignIn addAction:[UIAlertAction actionWithTitle:@"Create New Account" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        NSString *email = ((UITextField *)[_alertControllerSignIn.textFields objectAtIndex:0]).text;
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        if (email) [info setObject:email forKey:ALERT_INFO_EMAIL];
        [self.alertControllerCreateAccount setInfo:info];
        [self presentViewController:self.alertControllerCreateAccount animated:YES completion:nil];
    }]];
    
    return _alertControllerSignIn;
}

- (UIAlertController *)alertControllerCreateAccount
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_UI] message:nil];
    
    if (_alertControllerCreateAccount)
    {
        [((UITextField *)[_alertControllerCreateAccount.textFields objectAtIndex:0]) setText:[_alertControllerCreateAccount.info objectForKey:ALERT_INFO_EMAIL]];
        return _alertControllerCreateAccount;
    }
    
    _alertControllerCreateAccount = [UIAlertController alertControllerWithTitle:@"Create Account" message:@"Enter your email and a unique password below to create your account:" preferredStyle:UIAlertControllerStyleAlert];
    [_alertControllerCreateAccount addTextFieldWithConfigurationHandler:^(UITextField *textField){
        [textField setPlaceholder:@"email"];
    }];
    [_alertControllerCreateAccount addTextFieldWithConfigurationHandler:^(UITextField *textField){
        [textField setPlaceholder:@"password"];
        [textField setSecureTextEntry:YES];
    }];
    [_alertControllerCreateAccount addTextFieldWithConfigurationHandler:^(UITextField *textField){
        [textField setPlaceholder:@"confirm password"];
        [textField setSecureTextEntry:YES];
    }];
    [_alertControllerCreateAccount addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        [self clearAlertControllers];
    }]];
    [_alertControllerCreateAccount addAction:[UIAlertAction actionWithTitle:@"Create Account" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        NSString *email = ((UITextField *)[_alertControllerCreateAccount.textFields objectAtIndex:0]).text;
        NSString *password = ((UITextField *)[_alertControllerCreateAccount.textFields objectAtIndex:1]).text;
        NSString *passwordConfirm = ((UITextField *)[_alertControllerCreateAccount.textFields objectAtIndex:2]).text;
        if (![AKGenerics object:password isEqualToObject:passwordConfirm])
        {
            [self.alertControllerDismiss setTitle:@"Could Not Create Account"];
            [self.alertControllerDismiss setMessage:@"The provided passwords did not match."];
            [self presentViewController:self.alertControllerDismiss animated:YES completion:nil];
            return;
        }
        
        if (![LoginManager createAccountWithEmail:email password:password])
        {
            [self.alertControllerDismiss setTitle:@"Could Not Create Account"];
            [self.alertControllerDismiss setMessage:@"Please make sure you are connected to the Internet and do not already have an account."];
            [self presentViewController:self.alertControllerDismiss animated:YES completion:nil];
            return;
        }
        
        [self.alertControllerDismiss setTitle:@"Welcome!"];
        [self.alertControllerDismiss setMessage:@"You are now logged in."];
        [self presentViewController:self.alertControllerDismiss animated:YES completion:^{
            [self clearAlertControllers];
        }];
    }]];
    [_alertControllerCreateAccount addAction:[UIAlertAction actionWithTitle:@"Already Have Account" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        NSString *email = ((UITextField *)[_alertControllerCreateAccount.textFields objectAtIndex:0]).text;
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        if (email) [info setObject:email forKey:ALERT_INFO_EMAIL];
        [self.alertControllerSignIn setInfo:info];
        [self presentViewController:self.alertControllerSignIn animated:YES completion:^{
            [self clearAlertControllers];
        }];
    }]];
    return _alertControllerCreateAccount;
}

- (UIAlertController *)alertControllerSignOut
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
    
    if (_alertControllerSignOut) return _alertControllerSignOut;
    
    _alertControllerSignOut = [UIAlertController alertControllerWithTitle:nil message:[CentralDispatch currentUsername] preferredStyle:UIAlertControllerStyleActionSheet];
    [_alertControllerSignOut addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [_alertControllerSignOut addAction:[UIAlertAction actionWithTitle:TEXT_LOGOUT style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [LoginManager logOut];
    }]];
    return _alertControllerSignOut;
}

- (UIAlertController *)alertControllerDismiss
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
    
    if (_alertControllerDismiss) return _alertControllerDismiss;
    
    _alertControllerDismiss = [UIAlertController alertControllerWithTitle:@"Error" message:@"Could not perform action." preferredStyle:UIAlertControllerStyleAlert];
    [_alertControllerDismiss addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        if (self.alertControllerCreateAccount.info)
        {
            [self presentViewController:self.alertControllerCreateAccount animated:YES completion:nil];
        }
        else if (self.alertControllerSignIn.info)
        {
            [self presentViewController:self.alertControllerSignIn animated:YES completion:nil];
        }
    }]];
    return _alertControllerDismiss;
}

#pragma mark - // INITS AND LOADS //

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_UI] message:nil];
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeCritical methodType:AKMethodTypeSetup customCategories:@[AKD_UI] message:[NSString stringWithFormat:@"Could not instantiate %@", stringFromVariable(self)]];
        return nil;
    }
    
    [self setup];
    return self;
}

- (void)awakeFromNib
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_UI] message:nil];
    
    [super awakeFromNib];
    [self setup];
}

- (void)viewDidLoad
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_UI] message:nil];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_UI] message:nil];
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_UI] message:nil];
    
    [super viewDidAppear:animated];
    
    if (![CentralDispatch currentUser])
    {
        [self presentViewController:self.alertControllerSignIn animated:YES completion:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_UI] message:nil];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_UI] message:nil];
    
    [super viewDidDisappear:animated];
}

- (void)dealloc
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_UI] message:nil];
    
    [self teardown];
}

#pragma mark - // PUBLIC METHODS //

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS (LoginControllerDelegate) //

- (void)presentLogin
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:@[AKD_UI, AKD_ACCOUNTS] message:nil];
    
    if ([CentralDispatch currentUser]) return;
    
    if (self.alertControllerSignIn.isBeingPresented || self.alertControllerCreateAccount.isBeingPresented || self.alertControllerDismiss.isBeingPresented) return;
    
    [self presentViewController:self.alertControllerSignIn animated:YES completion:nil];
}

- (void)dismissLogin
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:@[AKD_UI, AKD_ACCOUNTS] message:nil];
    
    if (self.alertControllerSignIn.isBeingPresented) [self.alertControllerSignIn dismissViewControllerAnimated:YES completion:^{
        [self clearAlertControllers];
    }];
    
    if (self.alertControllerCreateAccount.isBeingPresented) [self.alertControllerCreateAccount dismissViewControllerAnimated:YES completion:^{
        [self clearAlertControllers];
    }];
}

- (void)presentLogout
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:@[AKD_UI] message:nil];
    
    if (![CentralDispatch currentUser]) return;
    
    [self presentViewController:self.alertControllerSignOut animated:YES completion:nil];
}

- (void)dismissLogout
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:@[AKD_UI] message:nil];
    
    [self.alertControllerSignOut dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS (General) //

- (void)setup
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_UI] message:nil];
    
    [self addObserversToCentralDispatch];
    [CentralDispatch setLoginControllerDelegate:self];
}

- (void)teardown
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_UI] message:nil];
    
    [self removeObserversFromCentralDispatch];
}

#pragma mark - // PRIVATE METHODS (Observers) //

- (void)addObserversToCentralDispatch
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentUserDidChange:) name:NOTIFICATION_CURRENTUSER_DID_CHANGE object:nil];
}

- (void)removeObserversFromCentralDispatch
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_CURRENTUSER_DID_CHANGE object:nil];
}

#pragma mark - // PRIVATE METHODS (Responders) //

- (void)currentUserDidChange:(NSNotification *)notification
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:@[AKD_NOTIFICATION_CENTER, AKD_ACCOUNTS] message:nil];
    
    if (![CentralDispatch currentUser]) [self presentViewController:self.alertControllerSignIn animated:YES completion:nil];
}

#pragma mark - // PRIVATE METHODS (Other) //

- (void)clearAlertControllers
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_UI] message:nil];
    
    [self.alertControllerSignIn setInfo:nil];
    [AKGenerics clearAllTextFieldsInAlertController:self.alertControllerSignIn];
    [self.alertControllerCreateAccount setInfo:nil];
    [AKGenerics clearAllTextFieldsInAlertController:self.alertControllerCreateAccount];
}

@end