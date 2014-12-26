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
#import "Author.h"
#import "Book.h"

#pragma mark - // DEFINITIONS (Private) //

#define CELL_LABEL_MISSING_BOOK @"(???)"
#define CELL_LABEL_MISSING_AUTHOR @"(unknown author)"

#define UITABLEVIEWCELL_REUSE_IDENTIFIER @"cell"

@interface TableViewController ()
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) UIAlertController *alertControllerAddBook;
@property (nonatomic, strong) UIAlertController *alertControllerError;
- (void)setup;
- (void)teardown;
- (IBAction)actionAdd:(id)sender;
@end

@implementation TableViewController

#pragma mark - // SETTERS AND GETTERS //

@synthesize data = _data;
@synthesize alertControllerAddBook = _alertControllerAddBook;
@synthesize alertControllerError = _alertControllerError;

- (NSMutableArray *)data
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategory:nil message:nil];
    
    if (!_data) _data = [NSMutableArray arrayWithArray:[[DataManager getAllBooks] array]];
    return _data;
}

- (UIAlertController *)alertControllerAddBook
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategory:nil message:nil];
    
    if (!_alertControllerAddBook)
    {
        _alertControllerAddBook = [UIAlertController alertControllerWithTitle:@"Book" message:@"Please enter book info:" preferredStyle:UIAlertControllerStyleAlert];
        [_alertControllerAddBook addTextFieldWithConfigurationHandler:^(UITextField *textField){
            [textField setPlaceholder:@"title"];
        }];
        [_alertControllerAddBook addTextFieldWithConfigurationHandler:^(UITextField *textField){
            [textField setPlaceholder:@"author (last name)"];
        }];
        [_alertControllerAddBook addTextFieldWithConfigurationHandler:^(UITextField *textField){
            [textField setPlaceholder:@"author (first name)"];
        }];
        [_alertControllerAddBook addAction:[UIAlertAction actionWithTitle:@"Add Book" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            NSString *title = ((UITextField *)[_alertControllerAddBook.textFields objectAtIndex:0]).text;
            NSString *lastName = ((UITextField *)[_alertControllerAddBook.textFields objectAtIndex:1]).text;
            NSString *firstName = ((UITextField *)[_alertControllerAddBook.textFields objectAtIndex:2]).text;
            Author *author = [DataManager authorWithLastName:lastName firstName:firstName];
            if (author)
            {
                Book *book = [DataManager createBookWithTitle:title author:author];
                if (book)
                {
                    if ([DataManager save])
                    {
                        [self.data insertObject:book atIndex:0];
                        [self.tableView reloadData];
                    }
                    else
                    {
                        [self presentViewController:self.alertControllerError animated:YES completion:nil];
                    }
                }
                else
                {
                    [self presentViewController:self.alertControllerError animated:YES completion:nil];
                }
            }
            else
            {
                [self presentViewController:self.alertControllerError animated:YES completion:nil];
            }
            for (UITextField *textField in _alertControllerAddBook.textFields)
            {
                [textField setText:nil];
            }
        }]];
        [_alertControllerAddBook addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
            [_alertControllerAddBook dismissViewControllerAnimated:YES completion:^{
                for (UITextField *textField in _alertControllerAddBook.textFields)
                {
                    [textField setText:nil];
                }
            }];
        }]];
    }
    return _alertControllerAddBook;
}

- (UIAlertController *)alertControllerError
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategory:nil message:nil];
    
    if (!_alertControllerError)
    {
        _alertControllerError = [UIAlertController alertControllerWithTitle:@"Error" message:@"Could not add book." preferredStyle:UIAlertControllerStyleAlert];
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
        Book *book = [self.data objectAtIndex:indexPath.row];
        if (book)
        {
            [cell.textLabel setText:book.title];
            if (book.author)
            {
                [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@ %@", book.author.firstName, book.author.lastName]];
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
        Book *book = [self.data objectAtIndex:indexPath.row];
        [self.data removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        if ([DataManager deleteObject:book])
        {
            if (![DataManager save])
            {
                [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeUnspecified customCategory:nil message:@"Could not save"];
            }
        }
        else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeUnspecified customCategory:nil message:[NSString stringWithFormat:@"Could not delete %@", NSStringFromClass([Book class])]];
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

- (IBAction)actionAdd:(id)sender
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategory:nil message:nil];
    
    [self presentViewController:self.alertControllerAddBook animated:YES completion:nil];
}

@end