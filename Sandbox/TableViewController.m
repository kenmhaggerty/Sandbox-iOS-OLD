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
#import "AKSystemInfo.h"
#import "DataManager.h"
#import "Message.h"
#import "UIAlertController+Info.h"

#pragma mark - // DEFINITIONS (Private) //

#define CELL_LABEL_MISSING_MESSAGE @"(???)"
#define CELL_LABEL_MISSING_SENDER @"(unknown sender)"
#define CELL_LABEL_MISSING_RECIPIENT @"(unknown recipient)"

#define UITABLEVIEWCELL_REUSE_IDENTIFIER @"cell"

@interface TableViewController ()
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) UIAlertController *alertControllerCreateMessage;
@property (nonatomic, strong) UIAlertController *alertControllerError;
- (void)setup;
- (void)teardown;
- (IBAction)actionCreateMessage:(id)sender;
@end

@implementation TableViewController

#pragma mark - // SETTERS AND GETTERS //

@synthesize data = _data;
@synthesize alertControllerCreateMessage = _alertControllerCreateMessage;
@synthesize alertControllerError = _alertControllerError;

- (NSMutableArray *)data
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategory:nil message:nil];
    
    if (!_data)
    {
        _data = [NSMutableArray arrayWithArray:[[DataManager getMessagesSentToUser:<#(NSString *)#>] array]];
    }
    return _data;
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
        [_alertControllerCreateMessage addAction:[UIAlertAction actionWithTitle:@"Add Album" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            NSString *recipient = ((UITextField *)[_alertControllerCreateMessage.textFields objectAtIndex:0]).text;
            NSString *text = ((UITextField *)[_alertControllerCreateMessage.textFields objectAtIndex:1]).text;
            if (recipient.length == 0) recipient = nil;
            if (text.length == 0) text = nil;
            NSString *sender = [DataManager currentUser];
            if (!sender)
            {
                
            }
            
            if (!recipient)
            {
                
            }
            
            if (!text)
            {
                
            }
            
            if (![DataManager createMessageWithText:text fromUser:sender toUser:recipient onDate:[NSDate date]])
            {
                
            }
            
            [self.data insertObject:message atIndex:0];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }]];
    }
    return _alertControllerCreateMessage;
}

- (UIAlertController *)alertControllerError
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategory:nil message:nil];
    
    if (!_alertControllerError)
    {
        _alertControllerError = [UIAlertController alertControllerWithTitle:@"Error" message:@"Could not add album." preferredStyle:UIAlertControllerStyleAlert];
        [_alertControllerError addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
            [_alertControllerError dismissViewControllerAnimated:YES completion:nil];
        }]];
    }
    [_alertControllerError setMessage:[NSString stringWithFormat:@"Could not add album:\n\"%@\"\n%@", [_alertControllerError.info objectForKey:ALERT_INFO_KEY_TITLE], [_alertControllerError.info objectForKey:ALERT_INFO_KEY_COMPOSER]]];
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
    else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeSetup customCategory:nil message:@"Could not initialize self"];
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
    if (cell)
    {
        Album *album = [self.data objectAtIndex:indexPath.row];
        if (album)
        {
            [cell.textLabel setText:album.title];
            if (album.author)
            {
                NSString *author = album.author.lastName;
                if (album.author.firstName) author = [NSString stringWithFormat:@"%@ %@", album.author.firstName, album.author.lastName];
                [cell.detailTextLabel setText:author];
            }
            else
            {
                [cell.detailTextLabel setText:CELL_LABEL_MISSING_AUTHOR];
            }
        }
        else
        {
            [cell.textLabel setText:CELL_LABEL_MISSING_BOOK];
        }
    }
    else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeGetter customCategory:nil message:@"Could not create cell"];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategory:nil message:nil];
    
    if ([tableView isEqual:self.tableView])
    {
        if (indexPath.row < self.data.count)
        {
            return YES;
        }
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategory:nil message:nil];
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        Album *album = [self.data objectAtIndex:indexPath.row];
        [self.data removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        if ([DataManager deleteObject:album])
        {
            if (![DataManager save])
            {
                [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeUnspecified customCategory:nil message:@"Could not save"];
            }
        }
        else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeUnspecified customCategory:nil message:[NSString stringWithFormat:@"Could not delete %@", NSStringFromClass([Album class])]];
    }
}

#pragma mark - // DELEGATED METHODS (UITableViewDelegate) //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS //

- (void)setup
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategory:nil message:nil];
}

- (void)teardown
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategory:nil message:nil];
}

- (IBAction)actionCreateMessage:(id)sender
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategory:nil message:nil];
    
    [self presentViewController:self.alertControllerCreateMessage animated:YES completion:nil];
}

@end