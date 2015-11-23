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
#import "SandboxAppInfo.h"
#import "DataManager.h"
#import "SandboxCentralDispatch.h"
#import "Message.h"
#import "UIAlertController+Info.h"

#pragma mark - // DEFINITIONS (Private) //

#define ALERT_INFO_RECIPIENT @"recipient"
#define ALERT_INFO_MESSAGE @"message"

#define CELL_LABEL_MISSING_MESSAGE @"(???)"
#define CELL_LABEL_MISSING_SENDER @"(unknown sender)"
#define CELL_LABEL_MISSING_RECIPIENT @"(unknown recipient)"

#define UITABLEVIEWCELL_REUSE_IDENTIFIER @"cell"

@interface TableViewController ()

// GENERAL //

@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *buttonSignInOrOut;
@property (nonatomic, strong) UIAlertController *alertControllerCreateMessage;
@property (nonatomic, strong) UIAlertController *alertControllerDismiss;
- (void)setup;
- (void)teardown;
- (BOOL)isInbox;
- (BOOL)isOutbox;
- (IBAction)actionSignInOrOut:(id)sender;
- (IBAction)actionCreateMessage:(id)sender;

// OBSERVERS //

- (void)addObserversToCentralDispatch;
- (void)removeObserversFromCentralDispatch;
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
@synthesize alertControllerCreateMessage = _alertControllerCreateMessage;
@synthesize alertControllerDismiss = _alertControllerDismiss;

- (void)setData:(NSMutableArray *)data
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:nil message:nil];
    
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
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    if (_data) return _data;
    
    if (self.isInbox) [self setData:[NSMutableArray arrayWithArray:[[SandboxCentralDispatch currentUser].inbox allObjects]]];
    else if (self.isOutbox) [self setData:[NSMutableArray arrayWithArray:[[SandboxCentralDispatch currentUser].outbox allObjects]]];
    [_data sortUsingComparator:(NSComparator)^(Message *message1, Message *message2) {
        return [message2.sendDate compare:message1.sendDate];
    }];
    return _data;
}

- (UIAlertController *)alertControllerCreateMessage
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    if (_alertControllerCreateMessage)
    {
        [((UITextField *)[_alertControllerCreateMessage.textFields objectAtIndex:0]) setText:[_alertControllerCreateMessage.info objectForKey:ALERT_INFO_RECIPIENT]];
        [((UITextField *)[_alertControllerCreateMessage.textFields objectAtIndex:1]) setText:[_alertControllerCreateMessage.info objectForKey:ALERT_INFO_MESSAGE]];
        [_alertControllerCreateMessage setMessage:[NSString stringWithFormat:@"from %@", [SandboxCentralDispatch currentUsername]]];
        return _alertControllerCreateMessage;
    }
    
    _alertControllerCreateMessage = [UIAlertController alertControllerWithTitle:@"Create Message" message:[NSString stringWithFormat:@"from %@", [SandboxCentralDispatch currentUsername]] preferredStyle:UIAlertControllerStyleAlert];
    [_alertControllerCreateMessage addTextFieldWithConfigurationHandler:^(UITextField *textField){
        [textField setPlaceholder:@"recipient"];
    }];
    [_alertControllerCreateMessage addTextFieldWithConfigurationHandler:^(UITextField *textField){
        [textField setPlaceholder:@"message"];
    }];
    [_alertControllerCreateMessage addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        [_alertControllerCreateMessage setInfo:nil];
        [AKGenerics clearAllTextFieldsInAlertController:_alertControllerCreateMessage];
    }]];
    [_alertControllerCreateMessage addAction:[UIAlertAction actionWithTitle:@"Send" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        NSString *recipient = ((UITextField *)[_alertControllerCreateMessage.textFields objectAtIndex:0]).text;
        if (recipient.length == 0) recipient = nil;
        NSString *message = ((UITextField *)[_alertControllerCreateMessage.textFields objectAtIndex:1]).text;
        if (message.length == 0) message = nil;
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        if (recipient) [info setObject:recipient forKey:ALERT_INFO_RECIPIENT];
        if (message) [info setObject:message forKey:ALERT_INFO_MESSAGE];
        [_alertControllerCreateMessage setInfo:info];
        
        if (![SandboxCentralDispatch currentUser])
        {
            [self.alertControllerDismiss setTitle:@"Could Not Send Message"];
            [self.alertControllerDismiss setMessage:@"Please sign in to send your message:"];
            [self presentViewController:self.alertControllerDismiss animated:YES completion:nil];
            return;
        }
        
        if (!recipient)
        {
            [_alertControllerCreateMessage setTitle:@"Error"];
            [_alertControllerCreateMessage setMessage:@"Please specify a recipient for your message:"];
            [self presentViewController:_alertControllerCreateMessage animated:YES completion:nil];
            return;
        }
        
        if (!message)
        {
            [_alertControllerCreateMessage setTitle:@"Error"];
            [_alertControllerCreateMessage setMessage:@"Cannot send an empty message. Please enter your message:"];
            [self presentViewController:_alertControllerCreateMessage animated:YES completion:nil];
            return;
        }
        
        if (![DataManager sendMessageWithText:message toUser:recipient])
        {
            [_alertControllerCreateMessage setTitle:@"Could Not Send Message"];
            [_alertControllerCreateMessage setMessage:@"Please make sure that your are connected to the Internet."];
            [self presentViewController:_alertControllerCreateMessage animated:YES completion:nil];
            return;
        }
        
        [_alertControllerCreateMessage setInfo:nil];
        [AKGenerics clearAllTextFieldsInAlertController:_alertControllerCreateMessage];
    }]];
    return _alertControllerCreateMessage;
}

- (UIAlertController *)alertControllerDismiss
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    if (_alertControllerDismiss) return _alertControllerDismiss;
    
    _alertControllerDismiss = [UIAlertController alertControllerWithTitle:@"Error" message:@"Could not perform action." preferredStyle:UIAlertControllerStyleAlert];
    [_alertControllerDismiss addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil]];
    return _alertControllerDismiss;
}

#pragma mark - // INITS AND LOADS //

- (id)initWithStyle:(UITableViewStyle)style
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    self = [super initWithStyle:style];
    if (self)
    {
        [self setup];
    }
    else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeSetup tags:nil message:[NSString stringWithFormat:@"Could not initialize %@", stringFromVariable(self)]];
    return self;
}

- (void)awakeFromNib
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    [super awakeFromNib];
    [self setup];
}

- (void)viewDidLoad
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    [super viewWillAppear:animated];
    
    if ([SandboxCentralDispatch currentUser])
    {
        [self.buttonSignInOrOut setTitle:TEXT_LOGOUT];
    }
    else
    {
        [self.buttonSignInOrOut setTitle:TEXT_LOGIN];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    [self teardown];
}

#pragma mark - // PUBLIC METHODS //

#pragma mark - // DELEGATED METHODS (UITableViewDataSource) //

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    UITableViewCell *cell;
    if ([AKSystemInfo iOSVersion] < 6.0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:UITABLEVIEWCELL_REUSE_IDENTIFIER];
        if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UITABLEVIEWCELL_REUSE_IDENTIFIER];
    }
    else cell = [tableView dequeueReusableCellWithIdentifier:UITABLEVIEWCELL_REUSE_IDENTIFIER forIndexPath:indexPath];
    if (!cell)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeGetter tags:nil message:[NSString stringWithFormat:@"Could not create %@", stringFromVariable(cell)]];
        return nil;
    }
    
    Message *message = [self.data objectAtIndex:indexPath.row];
    if (!message)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeGetter tags:nil message:[NSString stringWithFormat:@"No %@ exists at row %li", stringFromVariable(message), (unsigned long)indexPath.row]];
        return cell;
    }
    
    NSString *messageText = [[NSString alloc] init];
    if (![message.isRead boolValue]) messageText = @"• ";
    messageText = [messageText stringByAppendingString:message.text];
    [cell.textLabel setText:messageText];
    if (self.isInbox) [cell.detailTextLabel setText:message.sender.username];
    else if (self.isOutbox) [cell.detailTextLabel setText:message.recipient.username];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        Message *message = [self.data objectAtIndex:indexPath.row];
        [DataManager deleteMessage:message];
    }
}

#pragma mark - // DELEGATED METHODS (UITableViewDelegate) //

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    if (self.isInbox)
    {
        Message *message = [self.data objectAtIndex:indexPath.row];
        if (![message.isRead boolValue])
        {
            [DataManager userDidReadMessage:message];
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS (General) //

- (void)setup
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    [self addObserversToCentralDispatch];
}

- (void)teardown
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    [self removeObserversFromCentralDispatch];
}

- (BOOL)isInbox
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    if ([self.title isEqualToString:@"Inbox"])
    {
        return YES;
    }
    
    return NO;
}

- (BOOL)isOutbox
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    if ([self.title isEqualToString:@"Outbox"])
    {
        return YES;
    }
    
    return NO;
}

- (IBAction)actionSignInOrOut:(id)sender
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    if ([SandboxCentralDispatch currentUser])
    {
        [SandboxCentralDispatch presentLogout];
    }
    else
    {
        [SandboxCentralDispatch presentLogin];
    }
}

- (IBAction)actionCreateMessage:(id)sender
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    [self presentViewController:self.alertControllerCreateMessage animated:YES completion:nil];
}

#pragma mark - // PRIVATE METHODS (Observers) //

- (void)addObserversToCentralDispatch
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentUserDidChange:) name:NOTIFICATION_CURRENTUSER_DID_CHANGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageWasCreated:) name:NOTIFICATION_MESSAGE_WAS_CREATED object:nil];
}

- (void)removeObserversFromCentralDispatch
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_CURRENTUSER_DID_CHANGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_MESSAGE_WAS_CREATED object:nil];
}

- (void)addObserversToMessage:(Message *)message
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageIsReadDidChange:) name:NOTIFICATION_MESSAGE_ISREAD_DID_CHANGE object:message];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageWillBeDeleted:) name:NOTIFICATION_MESSAGE_WILL_BE_DELETED object:message];
}

- (void)removeObserversFromMessage:(Message *)message
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_MESSAGE_ISREAD_DID_CHANGE object:message];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_MESSAGE_WILL_BE_DELETED object:message];
}

#pragma mark - // PRIVATE METHODS (Responders) //

- (void)currentUserDidChange:(NSNotification *)notification
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    if ([SandboxCentralDispatch currentUser])
    {
        [self.buttonSignInOrOut setTitle:TEXT_LOGOUT];
    }
    else
    {
        [self.buttonSignInOrOut setTitle:TEXT_LOGIN];
    }
    [self setData:nil];
    [self.tableView reloadData];
}

- (void)messageWasCreated:(NSNotification *)notification
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    Message *message = [notification.userInfo objectForKey:NOTIFICATION_OBJECT_KEY];
    if ((self.isInbox && [message.recipient isEqual:[SandboxCentralDispatch currentUser]]) || (self.isOutbox && [message.sender isEqual:[SandboxCentralDispatch currentUser]]))
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
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    Message *message = notification.object;
    if (![self.data containsObject:message]) return;
    
    NSUInteger index = [self.data indexOfObject:message];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    if (self.isInbox && ([message.isRead boolValue])) [DataManager decrementBadge];
}

- (void)messageWillBeDeleted:(NSNotification *)notification
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    Message *message = notification.object;
    if (![self.data containsObject:message]) return;
    
    [self removeObserversFromMessage:message];
    NSUInteger index = [self.data indexOfObject:message];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.data removeObjectAtIndex:index];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    if (self.isInbox && (![message.isRead boolValue])) [DataManager decrementBadge];
}

@end