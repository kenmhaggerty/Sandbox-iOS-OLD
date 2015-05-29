//
//  ViewController.m
//  Sandbox
//
//  Created by Ken M. Haggerty on 11/30/12.
//  Copyright (c) 2012 MCMDI. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "ViewController.h"
#import "AKDebugger.h"
#import "AKGenerics.h"
#import "AKSystemInfo.h"
#import "AlertTableViewController.h"
#import "UIViewController+Syncing.h"

#pragma mark - // DEFINITIONS (Private) //

#define ALERT_CONTROLLER_TITLE @"Hello World!"
#define ALERT_CONTROLLER_MESSAGE @"Choose one of the following options:"

#define ALERT_ACTION_DISMISS_TITLE @"Dismiss"
#define ALERT_ACTION_OK_TITLE @"OK"

#define CELL_REUSE_IDENTIFIER @"Cell"

#define SYNC_TIME 5.0
#define TICKS_PER_SEC 5

#define NOTIFICATION_TICK @"kNotificationTick"
#define NOTIFICATION_TIMER_DID_STOP @"kNotificationTimerDidStop"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) AlertTableViewController *alertTableViewController;
@property (nonatomic, strong) UIAlertController *alertControllerDismiss;
@property (nonatomic, strong) UIAlertAction *alertActionDismiss;
@property (nonatomic) BOOL timerIsActive;
- (void)setup;
- (void)teardown;
- (IBAction)actionTest:(id)sender;
- (IBAction)actionSync:(id)sender;
- (void)startTimer;
- (void)tick:(NSNumber *)ticks;
- (void)timerDidTick:(NSNotification *)notification;
@end

@implementation ViewController

#pragma mark - // SETTERS AND GETTERS //

@synthesize alertTableViewController = _alertTableViewController;
@synthesize alertControllerDismiss = _alertControllerDismiss;
@synthesize alertActionDismiss = _alertActionDismiss;
@synthesize timerIsActive = _timerIsActive;

- (AlertTableViewController *)alertTableViewController
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_UI] message:nil];
    
    if (!_alertTableViewController)
    {
        _alertTableViewController = [AlertTableViewController alertControllerWithTitle:ALERT_CONTROLLER_TITLE message:ALERT_CONTROLLER_MESSAGE preferredStyle:UIAlertControllerStyleAlert];
        [_alertTableViewController addAction:self.alertActionDismiss];
        [_alertTableViewController setDataSource:self];
        [_alertTableViewController setDelegate:self];
    }
    return _alertTableViewController;
}

- (UIAlertController *)alertControllerDismiss
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
    
    if (!_alertControllerDismiss)
    {
        _alertControllerDismiss = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
        [_alertControllerDismiss addAction:self.alertActionDismiss];
    }
    return _alertControllerDismiss;
}

- (UIAlertAction *)alertActionDismiss
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
    
    if (!_alertActionDismiss)
    {
        _alertActionDismiss = [UIAlertAction actionWithTitle:ALERT_ACTION_DISMISS_TITLE style:UIAlertActionStyleCancel handler:nil];
    }
    return _alertActionDismiss;
}

#pragma mark - // INITS AND LOADS //

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:nil message:nil];
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:nil message:nil];
    
    [super awakeFromNib];
    [self setup];
}

- (void)viewDidLoad
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:nil message:nil];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:nil message:nil];
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:nil message:nil];
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:nil message:nil];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:nil message:nil];
    
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:nil message:nil];
    
    [super didReceiveMemoryWarning];
    [self teardown];
}

- (void)dealloc
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:nil message:nil];
    
    [self teardown];
}

#pragma mark - // PUBLIC METHODS //

#pragma mark - // DELEGATED METHODS (UITableViewDataSource) //

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_UI] message:nil];
    
    if ([tableView isEqual:self.alertTableViewController.tableView])
    {
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_UI] message:nil];
    
    if ([tableView isEqual:self.alertTableViewController.tableView])
    {
        return 5;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_UI] message:nil];
    
    UITableViewCell *cell;
    if ([tableView isEqual:self.alertTableViewController.tableView])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CELL_REUSE_IDENTIFIER];
        if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_REUSE_IDENTIFIER];
        
        if (cell)
        {
            [cell setBackgroundColor:[UIColor clearColor]];
            [cell.textLabel setText:[NSString stringWithFormat:@"Cell (%li, %li)", (long)indexPath.section, (long)indexPath.row]];
        }
        else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeGetter customCategories:@[AKD_UI] message:[NSString stringWithFormat:@"Could not create %@", stringFromVariable(cell)]];
    }
    return cell;
}

#pragma mark - // DELEGATED METHODS (UITableViewDelegate) //

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeAction customCategories:@[AKD_UI] message:nil];
    
    if ([tableView isEqual:self.alertTableViewController.tableView])
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - // DELEGATED METHODS (SyncViewDelegate) //

- (void)syncViewCancelButtonWasTapped:(SyncViewController *)sender
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeAction customCategories:nil message:nil];
    
    if (![sender isEqual:self.syncViewController]) return;
    
    [self setTimerIsActive:NO];
    [self cancelSyncViewWithPrimaryText:nil secondaryText:nil completionType:SyncViewCancelled alertController:nil delay:0.18*6 completionBlock:nil];
}

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS //

- (void)setup
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:nil message:nil];
    
    [self setTimerIsActive:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timerDidTick:) name:NOTIFICATION_TICK object:self];
}

- (void)teardown
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:nil message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_TICK object:self];
}

- (IBAction)actionTest:(id)sender
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeAction customCategories:nil message:nil];
    
    [self presentViewController:self.alertTableViewController animated:YES completion:nil];
}

- (IBAction)actionSync:(id)sender
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeAction customCategories:nil message:nil];
    
    [self startTimer];
    [self startSyncViewWithPrimaryText:nil secondaryText:nil progressView:YES cancelButton:YES];
}

- (void)startTimer
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:nil message:nil];
    
    [self setTimerIsActive:YES];
    [self tick:[NSNumber numberWithInteger:0]];
}

- (void)tick:(NSNumber *)ticks
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:nil message:nil];
    
    if (!self.timerIsActive)
    {
        [self cancelSyncViewWithPrimaryText:nil secondaryText:nil completionType:SyncViewCancelled alertController:nil delay:0.18*10 completionBlock:nil];
        return;
    }
    
    NSUInteger tickValue = [ticks integerValue];
    if (tickValue == (int)(TICKS_PER_SEC*SYNC_TIME))
    {
        [self cancelSyncViewWithPrimaryText:@"Done" secondaryText:nil completionType:SyncViewComplete alertController:nil delay:0.18*10 completionBlock:nil];
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TICK object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:tickValue] forKey:NOTIFICATION_OBJECT_KEY]];
    [self performSelector:@selector(tick:) withObject:[NSNumber numberWithInteger:++tickValue] afterDelay:1.0/(float)TICKS_PER_SEC];
}

- (void)timerDidTick:(NSNotification *)notification
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:nil message:nil];
    
    NSUInteger tickValue = [[notification.userInfo objectForKey:NOTIFICATION_OBJECT_KEY] integerValue];
    [self setSyncViewSecondaryText:[NSString stringWithFormat:@"(%i / %i)", tickValue, (int)(TICKS_PER_SEC*SYNC_TIME)]];
    float progress = ((float)tickValue)/(TICKS_PER_SEC*SYNC_TIME);
    [self setSyncViewProgress:progress animated:YES];
}

@end