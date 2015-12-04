//
//  TestViewController.m
//  Sandbox
//
//  Created by Ken M. Haggerty on 11/23/15.
//  Copyright © 2015 MCMDI. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "TestViewController.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#pragma mark - // DEFINITIONS (Private) //

#define ARRAY_LABELS_SOURCE @[self.labelSource0, self.labelSource1, self.labelSource2, self.labelSource3, self.labelSource4, self.labelSource5, self.labelSource6]
#define ARRAY_LABELS_DESTINATION @[self.labelDestination0, self.labelDestination1, self.labelDestination2, self.labelDestination3, self.labelDestination4, self.labelDestination5, self.labelDestination6]

#define TO @"to"
#define FROM @"from"

@interface TestViewController ()
@property (nonatomic, strong) IBOutlet UILabel *labelSource0;
@property (nonatomic, strong) IBOutlet UILabel *labelSource1;
@property (nonatomic, strong) IBOutlet UILabel *labelSource2;
@property (nonatomic, strong) IBOutlet UILabel *labelSource3;
@property (nonatomic, strong) IBOutlet UILabel *labelSource4;
@property (nonatomic, strong) IBOutlet UILabel *labelSource5;
@property (nonatomic, strong) IBOutlet UILabel *labelSource6;
@property (nonatomic, strong) IBOutlet UITextField *textField0;
@property (nonatomic, strong) IBOutlet UITextField *textField1;
@property (nonatomic, strong) IBOutlet UITextField *textField2;
@property (nonatomic, strong) IBOutlet UITextField *textField3;
@property (nonatomic, strong) IBOutlet UITextField *textField4;
@property (nonatomic, strong) IBOutlet UITextField *textField5;
@property (nonatomic, strong) IBOutlet UITextField *textField6;
@property (nonatomic, strong) IBOutlet UILabel *labelDestination0;
@property (nonatomic, strong) IBOutlet UILabel *labelDestination1;
@property (nonatomic, strong) IBOutlet UILabel *labelDestination2;
@property (nonatomic, strong) IBOutlet UILabel *labelDestination3;
@property (nonatomic, strong) IBOutlet UILabel *labelDestination4;
@property (nonatomic, strong) IBOutlet UILabel *labelDestination5;
@property (nonatomic, strong) IBOutlet UILabel *labelDestination6;
- (void)setup;
- (void)teardown;
- (IBAction)actionSort:(id)sender;
@end

@implementation TestViewController

#pragma mark - // SETTERS AND GETTERS //

#pragma mark - // INITS AND LOADS //

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    [self setup];
    return self;
}

- (void)awakeFromNib
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [super awakeFromNib];
    
    [self setup];
}

- (void)viewDidLoad
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [super viewWillAppear:animated];
}


- (void)viewDidAppear:(BOOL)animated
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [self teardown];
}

#pragma mark - // PUBLIC METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

- (void)viewWillLayoutSubviews
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [super viewWillLayoutSubviews];
}

- (void)viewDidLayoutSubviews
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
    
    [super viewDidLayoutSubviews];
}

#pragma mark - // PRIVATE METHODS //

- (void)setup
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
}

- (void)teardown
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
}

//- (IBAction)actionSort:(id)sender
//{
//    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_UI] message:nil];
//    
//    NSMutableArray *sourceArray = [NSMutableArray arrayWithCapacity:ARRAY_LABELS_SOURCE.count];
//    for (UILabel *label in ARRAY_LABELS_SOURCE) [sourceArray addObject:label.text];
//    
//#warning TO DO – Missing implementation for -[actionSort:]
//}

@end
