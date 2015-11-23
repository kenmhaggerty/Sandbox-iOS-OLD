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
#import "SystemInfo.h"
#import "AlertTableViewController.h"
#import "UIViewController+Syncing.h"
#import "AlertSwitchViewController.h" // temp

#pragma mark - // DEFINITIONS (Private) //

#define ALERT_ACTION_DISMISS_TITLE @"Dismiss"
#define ALERT_ACTION_OK_TITLE @"OK"

#define CELL_REUSE_IDENTIFIER @"Cell"

#define SYNC_TIME 5.0
#define TICKS_PER_SEC 5

#define NOTIFICATION_TICK @"kNotificationTick"
#define NOTIFICATION_TIMER_DID_STOP @"kNotificationTimerDidStop"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, SwitchDelegate, SyncViewDelegate>
@property (nonatomic, strong) AlertTableViewController *alertTableViewController;
@property (nonatomic, strong) AlertSwitchViewController *alertSwitchViewController;
@property (nonatomic, strong) UIAlertController *alertControllerDismiss;
@property (nonatomic, strong) UIAlertAction *alertActionDismiss;
@property (nonatomic) BOOL timerIsActive;
@property (nonatomic, strong) IBOutlet UILabel *labelWiFi;
@property (nonatomic, strong) IBOutlet UILabel *labelWWAN;
@property (nonatomic, strong) IBOutlet UILabel *labelInternet;

// GENERAL //

- (void)setup;
- (void)teardown;

// RESPONDERS //

- (void)timerDidTick:(NSNotification *)notification;
- (void)internetStatusDidChange:(NSNotification *)notification;

// ACTIONS //

- (IBAction)actionAlertTableViewController:(id)sender;
- (IBAction)actionAlertSwitchViewController:(id)sender;
- (IBAction)actionSync:(id)sender;
- (IBAction)actionRefresh:(id)sender;

// OTHER //

- (void)startTimer;
- (void)tick:(NSNumber *)ticks;
- (void)setLabels;

@end

@implementation ViewController

#pragma mark - // SETTERS AND GETTERS //

@synthesize alertTableViewController = _alertTableViewController;
@synthesize alertSwitchViewController = _alertSwitchViewController;
@synthesize alertControllerDismiss = _alertControllerDismiss;
@synthesize alertActionDismiss = _alertActionDismiss;
@synthesize timerIsActive = _timerIsActive;
@synthesize labelWiFi = _labelWiFi;
@synthesize labelWWAN = _labelWWAN;
@synthesize labelInternet = _labelInternet;

- (AlertTableViewController *)alertTableViewController
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    if (_alertTableViewController) return _alertTableViewController;
    
    _alertTableViewController = [AlertTableViewController alertControllerWithTitle:@"AlertTableViewController" message:@"Choose one of the following options:" preferredStyle:UIAlertControllerStyleAlert];
    [_alertTableViewController.tableView setDataSource:self];
    [_alertTableViewController.tableView setDelegate:self];
    [_alertTableViewController addAction:self.alertActionDismiss];
    return _alertTableViewController;
}

- (AlertSwitchViewController *)alertSwitchViewController
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    if (_alertSwitchViewController) return _alertSwitchViewController;
    
    _alertSwitchViewController = [AlertSwitchViewController alertControllerWithTitle:@"AlertSwitchViewController" message:@"You can toggle the following options:" preferredStyle:UIAlertControllerStyleAlert];
    for (int i = 0; i < 10; i++)
    {
        [_alertSwitchViewController addSwitchWithText:[NSString stringWithFormat:@"Switch %i", i+1] on:YES];
    }
    [_alertSwitchViewController setDelegate:self];
    [_alertSwitchViewController addAction:self.alertActionDismiss];
    return _alertSwitchViewController;
}

- (UIAlertController *)alertControllerDismiss
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    if (_alertControllerDismiss) return _alertControllerDismiss;
    
    _alertControllerDismiss = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    [_alertControllerDismiss addAction:self.alertActionDismiss];
    return _alertControllerDismiss;
}

- (UIAlertAction *)alertActionDismiss
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    if (_alertActionDismiss) return _alertActionDismiss;
    
    _alertActionDismiss = [UIAlertAction actionWithTitle:ALERT_ACTION_DISMISS_TITLE style:UIAlertActionStyleCancel handler:nil];
    return _alertActionDismiss;
}

#pragma mark - // INITS AND LOADS //

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self setup];
    }
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
    
    [self setLabels];
}

- (void)viewWillAppear:(BOOL)animated
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    [super viewWillAppear:animated];
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
    [self teardown];
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
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    if ([tableView isEqual:self.alertTableViewController.tableView])
    {
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    if ([tableView isEqual:self.alertTableViewController.tableView])
    {
        return 5;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
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
        else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeGetter tags:@[AKD_UI] message:[NSString stringWithFormat:@"Could not create %@", stringFromVariable(cell)]];
    }
    return cell;
}

#pragma mark - // DELEGATED METHODS (UITableViewDelegate) //

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeAction tags:@[AKD_UI] message:nil];
    
    if ([tableView isEqual:self.alertTableViewController.tableView])
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - // DELEGATED METHODS (SwitchDelegate) //

- (IBAction)actionSwitchDidToggle:(UISwitch *)sender
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeAction tags:@[AKD_UI] message:nil];
    
    NSNumber *index = [self.alertSwitchViewController indexForSwitch:sender];
    if (!index) return;
    
    if (!index.integerValue) return;
    
    if (sender.on)
    {
        [self.alertSwitchViewController showSwitchAtIndex:index.integerValue-1 animated:YES completion:nil];
    }
    else
    {
        [self.alertSwitchViewController hideSwitchAtIndex:index.integerValue-1 animated:YES completion:nil];
    }
}

#pragma mark - // DELEGATED METHODS (SyncViewDelegate) //

- (void)syncViewCancelButtonWasTapped:(SyncViewController *)sender
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeAction tags:nil message:nil];
    
    if (![sender isEqual:self.syncViewController]) return;
    
    [self setTimerIsActive:NO];
    [self cancelSyncViewWithPrimaryText:nil secondaryText:nil animated:YES completionType:SyncViewCancelled alertController:nil delay:0.18*6 completionBlock:nil];
}

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS (General) //

- (void)setup
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    [self setTimerIsActive:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timerDidTick:) name:NOTIFICATION_TICK object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(internetStatusDidChange:) name:NOTIFICATION_INTERNETSTATUS_DID_CHANGE object:nil];
}

- (void)teardown
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_TICK object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_INTERNETSTATUS_DID_CHANGE object:nil];
}

#pragma mark - // PRIVATE METHODS (Responders) //

- (void)timerDidTick:(NSNotification *)notification
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    NSUInteger tickValue = [[notification.userInfo objectForKey:NOTIFICATION_OBJECT_KEY] integerValue];
    [self setSyncViewSecondaryText:[NSString stringWithFormat:@"(%lu / %i)", (unsigned long)tickValue, (int)(TICKS_PER_SEC*SYNC_TIME)]];
    float progress = ((float)tickValue)/(TICKS_PER_SEC*SYNC_TIME);
    [self setSyncViewProgress:progress animated:YES];
}

- (void)internetStatusDidChange:(NSNotification *)notification
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [self setLabels];
}

#pragma mark - // PRIVATE METHODS (Actions) //

- (IBAction)actionAlertTableViewController:(id)sender
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeAction tags:nil message:nil];
    
    [self presentViewController:self.alertTableViewController animated:YES completion:nil];
}

- (IBAction)actionAlertSwitchViewController:(id)sender
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeAction tags:nil message:nil];
    
    [self presentViewController:self.alertSwitchViewController animated:YES completion:nil];
}

- (IBAction)actionSync:(id)sender
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeAction tags:nil message:nil];
    
    [self startTimer];
    [self startSyncViewWithPrimaryText:nil secondaryText:nil progressView:YES cancelButton:YES animated:YES];
}

- (IBAction)actionRefresh:(id)sender
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeAction tags:nil message:nil];
    
    [self setLabels];
}

#pragma mark - // PRIVATE METHODS (Other) //

- (void)startTimer
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    [self setTimerIsActive:YES];
    [self tick:[NSNumber numberWithInteger:0]];
}

- (void)tick:(NSNumber *)ticks
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    if (!self.timerIsActive)
    {
        [self cancelSyncViewWithPrimaryText:nil secondaryText:nil animated:YES completionType:SyncViewCancelled alertController:nil delay:0.18*10 completionBlock:nil];
        return;
    }
    
    NSUInteger tickValue = [ticks integerValue];
    if (tickValue == (int)(TICKS_PER_SEC*SYNC_TIME))
    {
        [self cancelSyncViewWithPrimaryText:@"Done" secondaryText:nil animated:YES completionType:SyncViewComplete alertController:nil delay:0.18*10 completionBlock:nil];
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TICK object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:tickValue] forKey:NOTIFICATION_OBJECT_KEY]];
    [self performSelector:@selector(tick:) withObject:[NSNumber numberWithInteger:++tickValue] afterDelay:1.0/(float)TICKS_PER_SEC];
}

- (void)setLabels
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_UI] message:nil];
    
    [self.labelWiFi setText:[AKGenerics textForBool:[SystemInfo isReachableViaWiFi] yesText:@"ON" noText:@"OFF"]];
    [self.labelWWAN setText:[AKGenerics textForBool:[SystemInfo isReachableViaWWAN] yesText:@"ON" noText:@"OFF"]];
    [self.labelInternet setText:[AKGenerics textForBool:[SystemInfo isReachable] yesText:@"ON" noText:@"OFF"]];
}

@end