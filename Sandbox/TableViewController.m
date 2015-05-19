//
//  TableViewController.m
//  Sandbox
//
//  Created by Ken M. Haggerty on 11/20/13.
//  Copyright (c) 2013 MCMDI. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "TableViewController.h"
#import "AKDebugger.h"
#import "AKGenerics.h"
#import "AKSystemInfo.h"
#import "DataManager.h"
#import "Message.h"
#import "UIAlertController+Info.h"

#pragma mark - // DEFINITIONS (Private) //

#define BUTTON_TEXT_LOGIN @"Sign In"
#define BUTTON_TEXT_LOGOUT @"Sign Out"

#define CELL_LABEL_MISSING_MESSAGE @"(???)"
#define CELL_LABEL_MISSING_SENDER @"(unknown sender)"
#define CELL_LABEL_MISSING_RECIPIENT @"(unknown recipient)"

#define UITABLEVIEWCELL_REUSE_IDENTIFIER @"cell"

@interface TableViewController ()

// GENERAL //

@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *buttonSignInOrOut;
@property (nonatomic, strong) UIAlertController *alertControllerSignIn;
@property (nonatomic, strong) UIAlertController *alertControllerCreateMessage;
@property (nonatomic, strong) UIAlertController *alertControllerError;
- (void)setup;
- (void)teardown;
- (BOOL)isInbox;
- (BOOL)isOutbox;
- (IBAction)actionSignInOrOut:(id)sender;
- (IBAction)actionCreateMessage:(id)sender;

// OBSERVERS //

- (void)addObserversToDataManager;
- (void)removeObserversFromDataManager;
- (void)addObserversToMessage:(Message *)message;
- (void)removeObserversFromMessage:(Message *)message;

// RESPONDERS //

- (void)currentUserDidChange:(NSNotification *)notification;
- (void)messageWasCreated:(NSNotification *)notification;
- (void)messageIsReadDidChange:(NSNotification *)notification;
- (void)messageWillBeDeleted:(NSNotification *)notification;

@end

@implementation TableViewController

#pragma mark - // SETTERS AND GETTERS //

@synthesize data = _data;
@synthesize buttonSignInOrOut = _buttonSignInOrOut;
@synthesize alertControllerSignIn = _alertControllerSignIn;
@synthesize alertControllerCreateMessage = _alertControllerCreateMessage;
@synthesize alertControllerError = _alertControllerError;

- (void)setData:(NSMutableArray *)data
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter customCategory:nil message:nil];
    
    if ([data isEqualToArray:_data]) return;
    
    for (Message *message in _data)
    {
        [self removeObserversFromMessage:message];
    }
    _data = data;
    NSUInteger unread = 0;
    for (Message *message in data)
    {
        [self addObserversToMessage:message];
        if (self.isInbox && (![message.isRead boolValue])) unread++;
    }
    if (self.isInbox) [DataManager setBadgeToCount:unread];
}

- (NSMutableArray *)data
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategory:nil message:nil];
    
    if (!_data)
    {
        if (self.isInbox) [self setData:[[NSMutableArray alloc] initWithArray:[[DataManager getMessagesSentToUser:[DataManager currentUser]] array]]];
        else if (self.isOutbox) [self setData:[[NSMutableArray alloc] initWithArray:[[DataManager getMessagesSentByUser:[DataManager currentUser]] array]]];
    }
    return _data;
}

- (UIAlertController *)alertControllerSignIn
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategory:nil message:nil];
    
    if (!_alertControllerSignIn)
    {
        _alertControllerSignIn = [UIAlertController alertControllerWithTitle:BUTTON_TEXT_LOGIN message:@"Please enter a unique username:" preferredStyle:UIAlertControllerStyleAlert];
        [_alertControllerSignIn addTextFieldWithConfigurationHandler:^(UITextField *textField){
            [textField setPlaceholder:@"username"];
        }];
        [_alertControllerSignIn addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
            for (UITextField *textField in _alertControllerSignIn.textFields)
            {
                [textField setText:nil];
            }
        }]];
        [_alertControllerSignIn addAction:[UIAlertAction actionWithTitle:BUTTON_TEXT_LOGIN style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            NSString *username = ((UITextField *)[_alertControllerSignIn.textFields objectAtIndex:0]).text;
            if (username.length == 0) username = nil;
            if (!username)
            {
                [self.alertControllerError setTitle:@"Error"];
                [self.alertControllerError setMessage:[NSString stringWithFormat:@"No %@ was specified.", stringFromVariable(username)]];
                [self presentViewController:self.alertControllerError animated:YES completion:nil];
                return;
            }
            
            [DataManager setCurrentUser:username];
            for (UITextField *textField in _alertControllerSignIn.textFields)
            {
                [textField setText:nil];
            }
            
            if (_alertControllerSignIn.info)
            {
                NSString *recipient = [_alertControllerSignIn.info objectForKey:NSStringFromSelector(@selector(recipient))];
                NSString *text = [_alertControllerSignIn.info objectForKey:NSStringFromSelector(@selector(text))];
                if (![DataManager createMessageWithText:text fromUser:username toUser:recipient onDate:[NSDate date] withId:nil andBroadcast:YES])
                {
                    [self.alertControllerError setMessage:@"Error"];
                    [self.alertControllerError setMessage:@"Could not send message. Check that your are connected to the Internet and try again."];
                    [self presentViewController:self.alertControllerError animated:YES completion:nil];
                    return;
                }
                [_alertControllerSignIn setInfo:nil];
            }
        }]];
    }
    return _alertControllerSignIn;
}

- (UIAlertController *)alertControllerCreateMessage
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategory:nil message:nil];
    
    if (!_alertControllerCreateMessage)
    {
        _alertControllerCreateMessage = [UIAlertController alertControllerWithTitle:@"Create Message" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [_alertControllerCreateMessage addTextFieldWithConfigurationHandler:^(UITextField *textField){
            [textField setPlaceholder:@"recipient"];
        }];
        [_alertControllerCreateMessage addTextFieldWithConfigurationHandler:^(UITextField *textField){
            [textField setPlaceholder:@"message"];
        }];
        [_alertControllerCreateMessage addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
            for (UITextField *textField in _alertControllerCreateMessage.textFields)
            {
                [textField setText:nil];
            }
        }]];
        [_alertControllerCreateMessage addAction:[UIAlertAction actionWithTitle:@"Send" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            NSString *recipient = ((UITextField *)[_alertControllerCreateMessage.textFields objectAtIndex:0]).text;
            NSString *text = ((UITextField *)[_alertControllerCreateMessage.textFields objectAtIndex:1]).text;
            if (recipient.length == 0) recipient = nil;
            if (text.length == 0) text = nil;
            NSString *sender = [DataManager currentUser];
            
            if (!recipient)
            {
                [_alertControllerCreateMessage setMessage:@"Error"];
                [_alertControllerCreateMessage setMessage:@"Please specify a recipient for your message."];
                [self presentViewController:_alertControllerCreateMessage animated:YES completion:nil];
                return;
            }
            
            if (!text)
            {
                [_alertControllerCreateMessage setMessage:@"Error"];
                [_alertControllerCreateMessage setMessage:@"Cannot send an empty message. Please enter your message."];
                [self presentViewController:_alertControllerCreateMessage animated:YES completion:nil];
                return;
            }
            
            if (!sender)
            {
                [self.alertControllerSignIn setMessage:BUTTON_TEXT_LOGIN];
                [self.alertControllerSignIn setMessage:@"Please sign in to send your message."];
                [self.alertControllerSignIn setInfo:[NSDictionary dictionaryWithObjects:@[recipient, text] forKeys:[NSArray arrayWithObjects:stringFromVariable(recipient), stringFromVariable(text), nil]]];
                [self presentViewController:self.alertControllerSignIn animated:YES completion:nil];
                return;
            }
            
            if (![DataManager createMessageWithText:text fromUser:sender toUser:recipient onDate:[NSDate date] withId:nil andBroadcast:YES])
            {
                [self.alertControllerError setMessage:@"Error"];
                [self.alertControllerError setMessage:@"Could not send message. Check that your are connected to the Internet and try again."];
                [self presentViewController:self.alertControllerError animated:YES completion:nil];
                return;
            }
            
            for (UITextField *textField in _alertControllerCreateMessage.textFields)
            {
                [textField setText:nil];
            }
        }]];
    }
    return _alertControllerCreateMessage;
}

- (UIAlertController *)alertControllerError
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategory:nil message:nil];
    
    if (!_alertControllerError)
    {
        _alertControllerError = [UIAlertController alertControllerWithTitle:@"Error" message:@"Could not perform action." preferredStyle:UIAlertControllerStyleAlert];
        [_alertControllerError addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
            [_alertControllerError dismissViewControllerAnimated:YES completion:nil];
        }]];
    }
    return _alertControllerError;
}

#pragma mark - // INITS AND LOADS //

- (id)initWithStyle:(UITableViewStyle)style
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategory:nil message:nil];
    
    self = [super initWithStyle:style];
    if (self)
    {
        [self setup];
    }
    else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeSetup customCategory:nil message:[NSString stringWithFormat:@"Could not initialize %@", stringFromVariable(self)]];
    return self;
}

- (void)awakeFromNib
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategory:nil message:nil];
    
    [super awakeFromNib];
    [self setup];
}

- (void)viewDidLoad
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategory:nil message:nil];
    
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if ([DataManager currentUser])
    {
        [self.tableView reloadData];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategory:nil message:nil];
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategory:nil message:nil];
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategory:nil message:nil];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategory:nil message:nil];
    
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategory:nil message:nil];
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategory:nil message:nil];
    
    [self teardown];
}

#pragma mark - // PUBLIC METHODS //

#pragma mark - // DELEGATED METHODS (UITableViewDataSource) //

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategory:nil message:nil];
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategory:nil message:nil];
    
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategory:nil message:nil];
    
    UITableViewCell *cell;
    if ([AKSystemInfo iOSVersion] < 6.0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:UITABLEVIEWCELL_REUSE_IDENTIFIER];
        if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UITABLEVIEWCELL_REUSE_IDENTIFIER];
    }
    else cell = [tableView dequeueReusableCellWithIdentifier:UITABLEVIEWCELL_REUSE_IDENTIFIER forIndexPath:indexPath];
    if (!cell)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeGetter customCategory:nil message:[NSString stringWithFormat:@"Could not create %@", stringFromVariable(cell)]];
        return nil;
    }
    
    Message *message = [self.data objectAtIndex:indexPath.row];
    if (!message)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeGetter customCategory:nil message:[NSString stringWithFormat:@"No %@ exists at row %li", stringFromVariable(message), (unsigned long)indexPath.row]];
        return cell;
    }
    
    NSString *messageText = [[NSString alloc] init];
    if (![message.isRead boolValue]) messageText = @"• ";
    messageText = [messageText stringByAppendingString:message.text];
    [cell.textLabel setText:messageText];
    if (self.isInbox) [cell.detailTextLabel setText:message.sender];
    else if (self.isOutbox) [cell.detailTextLabel setText:message.recipient];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategory:nil message:nil];
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategory:nil message:nil];
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        Message *message = [self.data objectAtIndex:indexPath.row];
        [DataManager deleteMessage:message];
    }
}

#pragma mark - // DELEGATED METHODS (UITableViewDelegate) //

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategory:nil message:nil];
    
    if (self.isInbox)
    {
        Message *message = [self.data objectAtIndex:indexPath.row];
        if (![message.isRead boolValue])
        {
            [DataManager userDidReadMessage:message andBroadcast:YES];
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS (General) //

- (void)setup
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategory:nil message:nil];
    
    [self addObserversToDataManager];
}

- (void)teardown
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategory:nil message:nil];
    
    [self removeObserversFromDataManager];
}

- (BOOL)isInbox
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategory:nil message:nil];
    
    if ([self.title isEqualToString:@"Inbox"])
    {
        return YES;
    }
    
    return NO;
}

- (BOOL)isOutbox
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategory:nil message:nil];
    
    if ([self.title isEqualToString:@"Outbox"])
    {
        return YES;
    }
    
    return NO;
}

- (IBAction)actionSignInOrOut:(id)sender
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategory:nil message:nil];
    
    if ([DataManager currentUser])
    {
        [DataManager setCurrentUser:nil];
    }
    else
    {
        [self presentViewController:self.alertControllerSignIn animated:YES completion:nil];
    }
}

- (IBAction)actionCreateMessage:(id)sender
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategory:nil message:nil];
    
    [self presentViewController:self.alertControllerCreateMessage animated:YES completion:nil];
}

#pragma mark - // PRIVATE METHODS (Observers) //

- (void)addObserversToDataManager
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategory:nil message:nil];
    
    [DataManager addObserver:self selector:@selector(currentUserDidChange:) name:NOTIFICATION_CURRENTUSER_DID_CHANGE];
    [DataManager addObserver:self selector:@selector(messageWasCreated:) name:NOTIFICATION_MESSAGE_WAS_CREATED];
}

- (void)removeObserversFromDataManager
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategory:nil message:nil];
    
    [DataManager removeObserver:self name:NOTIFICATION_CURRENTUSER_DID_CHANGE];
    [DataManager removeObserver:self name:NOTIFICATION_MESSAGE_WAS_CREATED];
}

- (void)addObserversToMessage:(Message *)message
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategory:nil message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageIsReadDidChange:) name:NOTIFICATION_MESSAGE_ISREAD_DID_CHANGE object:message];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageWillBeDeleted:) name:NOTIFICATION_MESSAGE_WILL_BE_DELETED object:message];
}

- (void)removeObserversFromMessage:(Message *)message
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategory:nil message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_MESSAGE_ISREAD_DID_CHANGE object:message];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_MESSAGE_WILL_BE_DELETED object:message];
}

#pragma mark - // PRIVATE METHODS (Responders) //

- (void)currentUserDidChange:(NSNotification *)notification
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategory:nil message:nil];
    
    NSString *username;
    if (notification.userInfo) username = [notification.userInfo objectForKey:NOTIFICATION_OBJECT_KEY];
    if (username)
    {
        [self.buttonSignInOrOut setTitle:BUTTON_TEXT_LOGOUT];
    }
    else
    {
        [self.buttonSignInOrOut setTitle:BUTTON_TEXT_LOGIN];
    }
    [self setData:nil];
    [self.tableView reloadData];
}

- (void)messageWasCreated:(NSNotification *)notification
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategory:nil message:nil];
    
    Message *message = [notification.userInfo objectForKey:NOTIFICATION_OBJECT_KEY];
    if ((self.isInbox && [message.recipient isEqualToString:[DataManager currentUser]]) || (self.isOutbox && [message.sender isEqualToString:[DataManager currentUser]]))
    {
        [self addObserversToMessage:message];
        NSUInteger index = 0;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.data insertObject:message atIndex:index];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        if (self.isInbox && (![message.isRead boolValue])) [DataManager incrementBadge];
    }
}

- (void)messageIsReadDidChange:(NSNotification *)notification
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategory:nil message:nil];
    
    Message *message = notification.object;
    if ([self.data containsObject:message])
    {
        NSUInteger index = [self.data indexOfObject:message];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        if (self.isInbox && ([message.isRead boolValue])) [DataManager decrementBadge];
    }
}

- (void)messageWillBeDeleted:(NSNotification *)notification
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategory:nil message:nil];
    
    Message *message = notification.object;
    if ([self.data containsObject:message])
    {
        [self removeObserversFromMessage:message];
        NSUInteger index = [self.data indexOfObject:message];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.data removeObjectAtIndex:index];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        if (self.isInbox && (![message.isRead boolValue])) [DataManager decrementBadge];
    }
}

@end