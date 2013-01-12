//
//  ThreeoViewController.m
//  Woodbox
//
//  Created by Ken M. Haggerty on 11/23/12.
//  Copyright (c) 2012 MCMDI. All rights reserved.
//

#pragma mark - // NOTES (Private) //

//  [_] Change animations to CPAnimationSteps
//  [_] Check for existence before performing relevant actions
//  [_] Adjust sideView size depending on if mainView exists
//  [_] When done moving, check if view controller exists????

//  [_] Convert "pop top then main" to just move off screen, then re-locate to correct offview position
//  [_] Double-check all animation sequences and timing
//  [_] Test in sandbox

#pragma mark - // IMPORTS (Private) //

#import "ThreeoViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CPAnimationProgram.h"
#import "CPAnimationSequence.h"
#import "CPAnimationStep.h"
#import "CustomButton.h"

#pragma mark - // DEFINITIONS (Private) //

#define MAINVIEW_CONTROLLER_ID @"Game View Controller"
#define TOPVIEW_CONTROLLER_ID @"Top View Controller"
#define SIDEVIEW_CONTROLLER_ID @"Side View Controller"
#define MAINVIEW_TOP_MARGIN 64
#define MAINVIEW_SIDE_MARGIN 80
#define MIN_PULL_TO_OPEN 10
#define DEFAULT_ANIMATION_SPEED 0.15
#define ANIMATION_MULTIPLE 1.75
#define ANIMATION_SLOW 1.5
#define STATUS_BAR_HEIGHT [[UIApplication sharedApplication] statusBarFrame].size.height

@interface ThreeoViewController () <CustomButtonDelegate>
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic) BOOL containerViewIsBeingMoved;
@property (nonatomic, strong) UIView *lockForMainView;
@property (nonatomic, weak) IBOutlet CustomButton *buttonTopView;
@property (nonatomic, weak) IBOutlet CustomButton *buttonSideView;
@property (nonatomic) CGPoint mainViewSnapLocationDefault;
@property (nonatomic) CGPoint mainViewSnapLocationVertical;
@property (nonatomic) CGPoint mainViewSnapLocationHorizontal;
@property (nonatomic) CGPoint mainViewSnapLocation;
@property (nonatomic, strong) NSNumber *viewHasAppeared;
- (CGRect)frameForMainView;
- (CGRect)frameForTopView;
- (CGRect)frameForSideView;
- (CPAnimationSequence *)viewMainViewAnimationSequence;
- (CPAnimationSequence *)viewTopViewAnimationSequence;
- (CPAnimationSequence *)viewSideViewAnimationSequence;
- (CPAnimationSequence *)fadeOutViewAnimationSequence:(UIView *)view;
- (void)layout;
- (void)lockMainView;
- (void)unlockMainView;
- (void)popTopViewThenViewSideView;
@end

@implementation ThreeoViewController

#pragma mark - // SETTERS AND GETTERS //

@synthesize mainView = _mainView;
@synthesize mainViewController = _mainViewController;
@synthesize topView = _topView;
@synthesize topViewController = _topViewController;
@synthesize sideView = _sideView;
@synthesize sideViewController = _sideViewController;
@synthesize containerView = _containerView;
@synthesize containerViewIsBeingMoved = _containerViewIsBeingMoved;
@synthesize lockForMainView = _lockForMainView;
@synthesize buttonTopView = _buttonTopView;
@synthesize buttonSideView = _buttonSideView;
@synthesize mainViewSnapLocationDefault = _mainViewSnapLocationDefault;
@synthesize mainViewSnapLocationVertical = _mainViewSnapLocationVertical;
@synthesize mainViewSnapLocationHorizontal = _mainViewSnapLocationHorizontal;
@synthesize mainViewSnapLocation = _mainViewSnapLocation;
@synthesize viewHasAppeared = _viewHasAppeared;

- (void)setMainView:(UIView *)mainView
{
    if ((mainView) && (!_mainView))
    {
        _mainView = mainView;
        if (![self.containerView.subviews containsObject:_mainView])
        {
            [self.containerView addSubview:_mainView];
            [self.containerView bringSubviewToFront:self.buttonSideView];
            [self.containerView bringSubviewToFront:self.buttonTopView];
        }
        [_mainView setFrame:[self frameForMainView]];
        [_mainView setClipsToBounds:YES];
        
        self.mainViewSnapLocationHorizontal = CGPointMake(self.view.bounds.size.width+self.containerView.frame.size.width/2.0-MAINVIEW_SIDE_MARGIN, self.view.bounds.size.height-self.containerView.frame.size.height/2.0);
        [[self viewMainViewAnimationSequence] runAnimated:[self.viewHasAppeared boolValue]];
        
        if (self.sideView)
        {
            CPAnimationStep *narrowSideView = [CPAnimationStep for:ANIMATION_SLOW*DEFAULT_ANIMATION_SPEED*ANIMATION_MULTIPLE animate:^{
                [self.sideView setFrame:self.frameForSideView];
            }];
            [narrowSideView runAnimated:[self.viewHasAppeared boolValue]];
        }
    }
    else if ((!mainView) && (_mainView))
    {
        [[self fadeOutViewAnimationSequence:_mainView] runAnimated:[self.viewHasAppeared boolValue]];
        _mainView = mainView;
        self.mainViewSnapLocationHorizontal = CGPointMake(self.view.bounds.size.width+self.containerView.frame.size.width/2.0, self.view.bounds.size.height-self.containerView.frame.size.height/2.0);
        if (CGPointEqualToPoint(self.mainViewSnapLocation, self.mainViewSnapLocationDefault)) [[self viewSideViewAnimationSequence] runAnimated:[self.viewHasAppeared boolValue]];
        else if (CGPointEqualToPoint(self.mainViewSnapLocation, self.mainViewSnapLocationVertical))
        {
            [self popTopViewThenViewSideView];
        }
        if (self.sideView)
        {
            CPAnimationStep *narrowSideView = [CPAnimationStep for:ANIMATION_SLOW*DEFAULT_ANIMATION_SPEED*ANIMATION_MULTIPLE animate:^{
                [self.sideView setFrame:self.frameForSideView];
            }];
            [narrowSideView runAnimated:[self.viewHasAppeared boolValue]];
        }
    }
    else if ((mainView) && (_mainView))
    {
        [_mainView removeFromSuperview];
        _mainView = mainView;
        if (![self.containerView.subviews containsObject:_mainView])
        {
            [self.containerView addSubview:_mainView];
            [self.containerView bringSubviewToFront:self.buttonSideView];
            [self.containerView bringSubviewToFront:self.buttonTopView];
        }
        [_mainView setFrame:[self frameForMainView]];
        [_mainView setClipsToBounds:YES];
    }
}

- (UIView *)mainView
{
    return _mainView;
}

- (void)setMainViewController:(UIViewController <MainViewControllerProtocol> *)mainViewController
{
    if ((mainViewController) && (!_mainViewController))
    {
        _mainViewController = mainViewController;
        if (![self.childViewControllers containsObject:_mainViewController]) [self addChildViewController:_mainViewController];
        self.mainView = _mainViewController.view;
    }
    else if ((!mainViewController) && (_mainViewController))
    {
        [_mainViewController removeFromParentViewController];
        _mainViewController = mainViewController;
        self.mainView = nil;
    }
    else if ((mainViewController) && (_mainViewController))
    {
//        [_mainViewController removeFromParentViewController];
        _mainViewController = mainViewController;
//        if (![self.childViewControllers containsObject:_mainViewController]) [self addChildViewController:_mainViewController];
        self.mainView = _mainViewController.view;
    }
}

- (UIViewController *)mainViewController
{
    return _mainViewController;
}

- (void)setTopView:(UIView *)topView
{
    if ((topView) && (!_topView))
    {
        _topView = topView;
        if (![self.containerView.subviews containsObject:_topView])
        {
            [self.containerView addSubview:_topView];
            if (self.mainView) [self.containerView bringSubviewToFront:self.mainView];
            [self.containerView bringSubviewToFront:self.buttonSideView];
            [self.containerView bringSubviewToFront:self.buttonTopView];
        }
        [_topView setFrame:[self frameForTopView]];
        [_topView setClipsToBounds:YES];
    }
    else if ((!topView) && (_topView))
    {
        [[self fadeOutViewAnimationSequence:_topView] runAnimated:[self.viewHasAppeared boolValue]];
        _topView = topView;
        if (CGPointEqualToPoint(self.mainViewSnapLocation, self.mainViewSnapLocationVertical)) [[self viewMainViewAnimationSequence] runAnimated:[self.viewHasAppeared boolValue]];
    }
    else if ((topView) && (_topView))
    {
        [_topView removeFromSuperview];
        _topView = topView;
        if (![self.containerView.subviews containsObject:_topView])
        {
            [self.containerView addSubview:_topView];
            if (self.mainView) [self.containerView bringSubviewToFront:self.mainView];
            [self.containerView bringSubviewToFront:self.buttonSideView];
            [self.containerView bringSubviewToFront:self.buttonTopView];
        }
        [_topView setFrame:[self frameForTopView]];
        [_topView setClipsToBounds:YES];
    }
}

- (UIView *)topView
{
    return _topView;
}

- (void)setTopViewController:(UIViewController *)topViewController
{
    if ((topViewController) && (!_topViewController))
    {
        _topViewController = topViewController;
        if (![self.childViewControllers containsObject:_topViewController]) [self addChildViewController:_topViewController];
        self.topView = _topViewController.view;
    }
    else if ((!topViewController) && (_topViewController))
    {
        [_topViewController removeFromParentViewController];
        _topViewController = topViewController;
        self.topView = nil;
    }
    else if ((topViewController) && (_topViewController))
    {
//        [_topViewController removeFromParentViewController];
        _topViewController = topViewController;
//        if (![self.childViewControllers containsObject:_topViewController]) [self addChildViewController:_topViewController];
        self.topView = _topViewController.view;
    }
}

- (UIViewController *)topViewController
{
    return _topViewController;
}

- (void)setSideView:(UIView *)sideView
{
    if ((sideView) && (!_sideView))
    {
        _sideView = sideView;
        if (![self.view.subviews containsObject:_sideView])
        {
            [self.view addSubview:_sideView];
            [self.view bringSubviewToFront:self.containerView];
        }
        [_sideView setFrame:[self frameForSideView]];
        [_sideView setClipsToBounds:YES];
        _sideView.layer.shadowOffset = CGSizeMake(0, 10);
        _sideView.layer.shadowRadius = 10;
        _sideView.layer.shadowOpacity = 1;
        _sideView.layer.shadowPath = [UIBezierPath bezierPathWithRect:_sideView.bounds].CGPath;
    }
    else if ((!sideView) && (_sideView))
    {
        [[self fadeOutViewAnimationSequence:_sideView] runAnimated:[self.viewHasAppeared boolValue]];
        _sideView = sideView;
        if ((CGPointEqualToPoint(self.mainViewSnapLocation, self.mainViewSnapLocationHorizontal)) && (self.mainView)) [[self viewMainViewAnimationSequence] runAnimated:[self.viewHasAppeared boolValue]];
    }
    else if ((sideView) && (_sideView))
    {
        [_sideView removeFromSuperview];
        _sideView = sideView;
        if (![self.view.subviews containsObject:_sideView])
        {
            [self.view addSubview:_sideView];
            [self.view bringSubviewToFront:self.containerView];
        }
        [_sideView setFrame:[self frameForSideView]];
        [_sideView setClipsToBounds:YES];
        _sideView.layer.shadowOffset = CGSizeMake(0, 10);
        _sideView.layer.shadowRadius = 10;
        _sideView.layer.shadowOpacity = 1;
        _sideView.layer.shadowPath = [UIBezierPath bezierPathWithRect:_sideView.bounds].CGPath;
    }
}

- (UIView *)sideView
{
    return _sideView;
}

- (void)setSideViewController:(UIViewController *)sideViewController
{
    if ((sideViewController) && (!_sideViewController))
    {
        _sideViewController = sideViewController;
        if (![self.childViewControllers containsObject:_sideViewController]) [self addChildViewController:_sideViewController];
        self.sideView = _sideViewController.view;
    }
    else if ((!sideViewController) && (_sideViewController))
    {
        [_sideViewController removeFromParentViewController];
        _sideViewController = sideViewController;
        self.sideView = nil;
    }
    else if ((sideViewController) && (_sideViewController))
    {
        [_sideViewController removeFromParentViewController];
        _sideViewController = sideViewController;
        if (![self.childViewControllers containsObject:_sideViewController]) [self addChildViewController:_sideViewController];
        self.sideView = _sideViewController.view;
    }
}

- (UIViewController *)sideViewController
{
    return _sideViewController;
}

- (void)setLockForMainView:(UIView *)lockForMainView
{
    _lockForMainView = lockForMainView;
}

- (UIView *)lockForMainView
{
    if (!_lockForMainView)
    {
        _lockForMainView = [[UIView alloc] initWithFrame:self.mainView.frame];
        [_lockForMainView setUserInteractionEnabled:YES];
    }
    return _lockForMainView;
}

- (void)setMainViewSnapLocation:(CGPoint)mainViewSnapLocation
{
    _mainViewSnapLocation = mainViewSnapLocation;
    if (CGPointEqualToPoint(mainViewSnapLocation, self.mainViewSnapLocationDefault)) [self unlockMainView];
    else [self lockMainView];
}

- (CGPoint)mainViewSnapLocation
{
    return _mainViewSnapLocation;
}

- (void)setViewHasAppeared:(NSNumber *)viewHasAppeared
{
    _viewHasAppeared = viewHasAppeared;
}

- (NSNumber *)viewHasAppeared
{
    if (!_viewHasAppeared) _viewHasAppeared = [NSNumber numberWithBool:NO];
    return _viewHasAppeared;
}

#pragma mark - // INITS AND LOADS //

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"NSTexturedFullScreenBackgroundColor.png"]]];
    [self.containerView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];
    
    self.containerViewIsBeingMoved = NO;
    
    // Set MainView and SideView //
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    self.mainViewController = [mainStoryboard instantiateViewControllerWithIdentifier:MAINVIEW_CONTROLLER_ID];
    self.topViewController = [mainStoryboard instantiateViewControllerWithIdentifier:TOPVIEW_CONTROLLER_ID];
    self.sideViewController = [mainStoryboard instantiateViewControllerWithIdentifier:SIDEVIEW_CONTROLLER_ID];
    
//    NSMutableArray *viewControllersToCheck = [[NSMutableArray alloc] initWithArray:self.sideViewController.childViewControllers];
//    while (viewControllersToCheck.count != 0)
//    {
//        UIViewController *viewController = [viewControllersToCheck objectAtIndex:0];
//        if ([viewController isKindOfClass:[MultigameTableViewController class]])
//        {
//            NSLog(@"[TEST] Found Woodbox, setting delegates");
//            ((MultigameTableViewController *)viewController).gameViewDelegate = (WoodboxViewController *)self.mainViewController;
//            ((MultigameTableViewController *)viewController).threeoViewDelegate = self;
//            break;
//        }
//        else if (viewController.childViewControllers.count != 0) [viewControllersToCheck addObjectsFromArray:viewController.childViewControllers];
//        [viewControllersToCheck removeObject:viewController];
//    }
    
    // Custom Buttons Setup //
    
    self.buttonSideView.delegate = self;
    self.buttonSideView.viewForCoordinates = self.view;
    self.buttonSideView.imageUntouched = [UIImage imageNamed:@"button_sidebar_unpressed_nomessages.png"];
    self.buttonSideView.imageActive = [UIImage imageNamed:@"button_sidebar_unpressed_messages.png"];
    self.buttonSideView.imageTouched = [UIImage imageNamed:@"button_sidebar_pressed.png"];
    self.buttonTopView.delegate = self;
    self.buttonTopView.viewForCoordinates = self.view;
    self.buttonTopView.imageUntouched = [UIImage imageNamed:@"button_help_unpressed_noupdates.png"];
    self.buttonTopView.imageActive = [UIImage imageNamed:@"button_help_unpressed_updates.png"];
    self.buttonTopView.imageTouched = [UIImage imageNamed:@"button_help_pressed.png"];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self layout];
    self.mainViewSnapLocation = self.mainViewSnapLocationDefault;
    
    [self.containerView setClipsToBounds:YES];
    self.containerView.layer.shadowOffset = CGSizeMake(0, 10);
    self.containerView.layer.shadowRadius = 10;
    self.containerView.layer.shadowOpacity = 0.5;
    self.containerView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.containerView.bounds].CGPath;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setViewHasAppeared:[NSNumber numberWithBool:YES]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - // PUBLIC FUNCTIONS //

- (BOOL)viewMainView
{
    if (self.mainView)
    {
        if (!self.containerViewIsBeingMoved)
        {
            [[self viewMainViewAnimationSequence] runAnimated:[self.viewHasAppeared boolValue]];
            return YES;
        }
    }
    return NO;
}

- (BOOL)viewTopView
{
    if (self.topView)
    {
        if (!self.containerViewIsBeingMoved)
        {
            [[self viewTopViewAnimationSequence] runAnimated:[self.viewHasAppeared boolValue]];
            return YES;
        }
    }
    return NO;
}

- (BOOL)viewSideView
{
    if (self.sideView)
    {
        if (!self.containerViewIsBeingMoved)
        {
            [[self viewSideViewAnimationSequence] runAnimated:[self.viewHasAppeared boolValue]];
            return YES;
        }
    }
    return NO;
}

#pragma mark - // DELEGATED FUNCTIONS (CustomButton) //

- (void)buttonIsBeingMoved:(CustomButton *)sender
{
    if (([sender isEqual:self.buttonSideView]) && (self.containerView.center.y == self.mainViewSnapLocationDefault.y))
    {
        if ((self.containerView.center.x < self.mainViewSnapLocationDefault.x) || (!self.sideView))
        {
            [self.containerView setCenter:CGPointMake(self.mainViewSnapLocationDefault.x+(sender.touchCurrent.x-sender.touchStart.x+self.mainViewSnapLocation.x-self.mainViewSnapLocationDefault.x)/2, self.containerView.center.y)];
        }
        else if (self.mainViewSnapLocationHorizontal.x < self.containerView.center.x)
        {
            [self.containerView setCenter:CGPointMake(self.mainViewSnapLocationHorizontal.x+(sender.touchCurrent.x-sender.touchStart.x+self.mainViewSnapLocation.x-self.mainViewSnapLocationHorizontal.x)/2, self.containerView.center.y)];
        }
        else
        {
            [self.containerView setCenter:CGPointMake(self.mainViewSnapLocation.x+sender.touchCurrent.x-sender.touchStart.x, self.containerView.center.y)];
        }
    }
    else if (([sender isEqual:self.buttonTopView]) && (self.containerView.center.x == self.mainViewSnapLocationDefault.x))
    {
        if ((self.containerView.center.y < self.mainViewSnapLocationDefault.y) || (!self.topView))
        {
            [self.containerView setCenter:CGPointMake(self.containerView.center.x, self.mainViewSnapLocationDefault.y+(sender.touchCurrent.y-sender.touchStart.y+self.mainViewSnapLocation.y-self.mainViewSnapLocationDefault.y)/2)];
        }
        else if (self.mainViewSnapLocationVertical.y < self.containerView.center.y)
        {
            [self.containerView setCenter:CGPointMake(self.containerView.center.x, self.mainViewSnapLocationVertical.y+(sender.touchCurrent.y-sender.touchStart.y+self.mainViewSnapLocation.y-self.mainViewSnapLocationVertical.y)/2)];
        }
        else
        {
            [self.containerView setCenter:CGPointMake(self.containerView.center.x, self.mainViewSnapLocation.y+sender.touchCurrent.y-sender.touchStart.y)];
        }
    }
}

- (void)buttonIsDoneMoving:(CustomButton *)sender
{
    if (([sender isEqual:self.buttonSideView]) && (self.containerView.center.y == self.mainViewSnapLocationDefault.y))
    {
        if (CGPointEqualToPoint(self.mainViewSnapLocation, self.mainViewSnapLocationDefault))
        {
            if ((((self.mainViewSnapLocationDefault.x < self.containerView.center.x - MIN_PULL_TO_OPEN) && (([self.buttonSideView.touchDirection isEqualToString:@"NE"]) || ([self.buttonSideView.touchDirection isEqualToString:@"E"]) || ([self.buttonSideView.touchDirection isEqualToString:@"SE"]))) || ((self.mainViewSnapLocationHorizontal.x < self.containerView.center.x))) && (self.sideView))
            {
                [self viewSideView];
            }
        }
        else if (CGPointEqualToPoint(self.mainViewSnapLocation, self.mainViewSnapLocationHorizontal))
        {
            if ((((self.containerView.center.x + MIN_PULL_TO_OPEN < self.mainViewSnapLocationHorizontal.x) && (([self.buttonSideView.touchDirection isEqualToString:@"NW"]) || ([self.buttonSideView.touchDirection isEqualToString:@"W"]) || ([self.buttonSideView.touchDirection isEqualToString:@"SW"]))) || (self.containerView.center.x < self.mainViewSnapLocationDefault.x)) || (!self.sideView))
            {
                [self viewMainView];
                [self.mainViewController mainViewIsSnappedClosed];
            }
        }
    }
    else if (([sender isEqual:self.buttonTopView]) && (self.containerView.center.x == self.mainViewSnapLocationDefault.x)) // add in snap detection if past most recent message
    {
        if (CGPointEqualToPoint(self.mainViewSnapLocation, self.mainViewSnapLocationDefault))
        {
            if ((((self.mainViewSnapLocationDefault.y < self.containerView.center.y - MIN_PULL_TO_OPEN) && (([self.buttonTopView.touchDirection isEqualToString:@"SW"]) || ([self.buttonTopView.touchDirection isEqualToString:@"S"]) || ([self.buttonTopView.touchDirection isEqualToString:@"SE"]))) || (self.mainViewSnapLocationVertical.y < self.containerView.center.y)) && (self.topView))
            {
                [self viewTopView];
                [self.mainViewController mainViewIsSnappedOpenVertical];
            }
        }
        else if (CGPointEqualToPoint(self.mainViewSnapLocation, self.mainViewSnapLocationVertical))
        {
            if ((((self.containerView.center.y + MIN_PULL_TO_OPEN < self.mainViewSnapLocationVertical.y) && (([self.buttonTopView.touchDirection isEqualToString:@"NW"]) || ([self.buttonTopView.touchDirection isEqualToString:@"N"]) || ([self.buttonTopView.touchDirection isEqualToString:@"NE"]))) || (self.containerView.center.y < self.mainViewSnapLocationDefault.y)) || (!self.topView))
            {
                [self viewMainView];
                [self.mainViewController mainViewIsSnappedClosed];
            }
        }
    }
}

- (void)buttonWasTapped:(CustomButton *)sender
{
    if (([sender isEqual:self.buttonSideView]) && (self.containerView.center.y == self.mainViewSnapLocationDefault.y) && (!self.buttonTopView.isBeingTouched))
    {
        if ((CGPointEqualToPoint(self.mainViewSnapLocation, self.mainViewSnapLocationDefault)) && (self.sideView))
        {
            [self viewSideView];
            [self.mainViewController mainViewIsSnappedOpenHorizontal];
        }
        else if (CGPointEqualToPoint(self.mainViewSnapLocation, self.mainViewSnapLocationHorizontal))
        {
            [self viewMainView];
            [self.mainViewController mainViewIsSnappedClosed];
        }
    }
    else if (([sender isEqual:self.buttonTopView]) && (self.containerView.center.x == self.mainViewSnapLocationDefault.x) && (!self.buttonTopView.isBeingTouched))
    {
        if ((CGPointEqualToPoint(self.mainViewSnapLocation, self.mainViewSnapLocationDefault)) && (self.topView))
        {
            [self viewTopView];
            [self.mainViewController mainViewIsSnappedOpenVertical];
        }
        else if (CGPointEqualToPoint(self.mainViewSnapLocation, self.mainViewSnapLocationVertical))
        {
            [self viewMainView];
            [self.mainViewController mainViewIsSnappedClosed];
        }
    }
}

#pragma mark - // PRIVATE FUNCTIONS //

- (CGRect)frameForMainView
{
    return CGRectMake(0.0, self.view.bounds.size.height-MAINVIEW_TOP_MARGIN, self.view.bounds.size.width, self.view.bounds.size.height);
}

- (CGRect)frameForTopView
{
    return CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height);
}

- (CGRect)frameForSideView
{
    if (self.mainView) return CGRectMake(0.0, 0.0, self.view.bounds.size.width-MAINVIEW_SIDE_MARGIN, self.view.bounds.size.height);
    else return CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height);
}

- (CPAnimationSequence *)viewMainViewAnimationSequence
{
    CPAnimationStep *animateToLocation = [CPAnimationStep for:ANIMATION_SLOW*DEFAULT_ANIMATION_SPEED*ANIMATION_MULTIPLE animate:^{
        self.mainViewSnapLocation = self.mainViewSnapLocationDefault;
        [self.containerView setCenter:self.mainViewSnapLocation];
    }];
    return [CPAnimationSequence sequenceWithSteps:animateToLocation, nil];
}

- (CPAnimationSequence *)viewTopViewAnimationSequence
{
    if ((self.containerView.center.y == self.mainViewSnapLocationDefault.y) && (self.containerView.center.x != self.mainViewSnapLocationDefault.x) && (self.mainView))
    {
        CPAnimationStep *animateToMainView = [CPAnimationStep for:ANIMATION_SLOW*DEFAULT_ANIMATION_SPEED*ANIMATION_MULTIPLE animate:^{
            self.mainViewSnapLocation = self.mainViewSnapLocationDefault;
            self.containerView.center = self.mainViewSnapLocation;
        }];
        CPAnimationStep *animateToTopView = [CPAnimationStep for:ANIMATION_SLOW*DEFAULT_ANIMATION_SPEED*ANIMATION_MULTIPLE animate:^{
            self.mainViewSnapLocation = self.mainViewSnapLocationVertical;
            self.containerView.center = self.mainViewSnapLocation;
        }];
        return [CPAnimationSequence sequenceWithSteps:animateToMainView, animateToTopView, nil];
    }
    else
    {
        CPAnimationStep *animateToLocation = [CPAnimationStep for:ANIMATION_SLOW*DEFAULT_ANIMATION_SPEED*ANIMATION_MULTIPLE animate:^{
            self.mainViewSnapLocation = self.mainViewSnapLocationVertical;
            self.containerView.center = self.mainViewSnapLocation;
        }];
        return [CPAnimationSequence sequenceWithSteps:animateToLocation, nil];
    }
}

- (CPAnimationSequence *)viewSideViewAnimationSequence
{
    if ((self.containerView.center.x == self.mainViewSnapLocationDefault.x) && (self.containerView.center.y != self.mainViewSnapLocationDefault.y) && (self.mainView))
    {
        CPAnimationStep *animateToMainView = [CPAnimationStep for:ANIMATION_SLOW*DEFAULT_ANIMATION_SPEED*ANIMATION_MULTIPLE animate:^{
            self.mainViewSnapLocation = self.mainViewSnapLocationDefault;
            self.containerView.center = self.mainViewSnapLocation;
        }];
        CPAnimationStep *animateToSideView = [CPAnimationStep for:ANIMATION_SLOW*DEFAULT_ANIMATION_SPEED*ANIMATION_MULTIPLE animate:^{
            self.mainViewSnapLocation = self.mainViewSnapLocationHorizontal;
            self.containerView.center = self.mainViewSnapLocation;
        }];
        return [CPAnimationSequence sequenceWithSteps:animateToMainView, animateToSideView, nil];
    }
    else
    {
        CPAnimationStep *animateToLocation = [CPAnimationStep for:ANIMATION_SLOW*DEFAULT_ANIMATION_SPEED*ANIMATION_MULTIPLE animate:^{
            self.mainViewSnapLocation = self.mainViewSnapLocationHorizontal;
            self.containerView.center = self.mainViewSnapLocation;
        }];
        return [CPAnimationSequence sequenceWithSteps:animateToLocation, nil];
    }
}

- (CPAnimationSequence *)fadeOutViewAnimationSequence:(UIView *)view
{
    CPAnimationStep *fadeView = [CPAnimationStep for:ANIMATION_SLOW*DEFAULT_ANIMATION_SPEED*ANIMATION_MULTIPLE animate:^{
        [view setAlpha:0.0];
    }];
    CPAnimationStep *removeView = [CPAnimationStep for:0.0 animate:^{
        [view setAlpha:1.0];
        [view removeFromSuperview];
    }];
    return [CPAnimationSequence sequenceWithSteps:fadeView, removeView, nil];
}

- (void)layout
{
    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat viewHeight = self.view.bounds.size.height;
    
    [self.lockForMainView setFrame:self.mainView.frame];
    
    if (![self.containerView.subviews containsObject:self.buttonSideView]) [self.containerView addSubview:self.buttonSideView];
    [self.buttonSideView setCenter:CGPointMake(self.buttonSideView.frame.size.width/2.0, viewHeight-MAINVIEW_TOP_MARGIN/2.0)];
    
    if (![self.containerView.subviews containsObject:self.buttonTopView]) [self.containerView addSubview:self.buttonTopView];
    [self.buttonTopView setCenter:CGPointMake(viewWidth-self.buttonTopView.frame.size.width/2.0, viewHeight-MAINVIEW_TOP_MARGIN/2.0)];
    
    self.mainViewSnapLocationDefault = self.containerView.center;
    self.mainViewSnapLocationVertical = CGPointMake(self.containerView.center.x, self.containerView.center.y+viewHeight-MAINVIEW_TOP_MARGIN);
    self.mainViewSnapLocationHorizontal = CGPointMake(self.containerView.center.x+MAINVIEW_SIDE_MARGIN, self.containerView.center.y);
}

- (void)lockMainView
{
    if (![self.containerView.subviews containsObject:self.lockForMainView])
    {
        [self.containerView addSubview:self.lockForMainView];
        [self.containerView bringSubviewToFront:self.buttonSideView];
        [self.containerView bringSubviewToFront:self.buttonTopView];
    }
}

- (void)unlockMainView
{
    if ([self.containerView.subviews containsObject:self.lockForMainView])
    {
        [self.lockForMainView removeFromSuperview];
    }
}

- (void)popTopViewThenViewSideView
{
    CPAnimationStep *moveContainerViewOffScreen = [CPAnimationStep for:ANIMATION_SLOW*DEFAULT_ANIMATION_SPEED*ANIMATION_MULTIPLE animate:^{
        self.mainViewSnapLocationHorizontal = CGPointMake(self.view.bounds.size.width+self.containerView.frame.size.width/2.0, self.containerView.center.y);
        self.mainViewSnapLocation = self.mainViewSnapLocationHorizontal;
        [self.containerView setCenter:self.mainViewSnapLocation];
    }];
    CPAnimationStep *recenterContainerView = [CPAnimationStep for:0.0 animate:^{
        self.mainViewSnapLocationHorizontal = CGPointMake(self.view.bounds.size.width+self.containerView.frame.size.width/2.0, self.view.bounds.size.height-self.containerView.frame.size.height/2.0);
        self.mainViewSnapLocation = self.mainViewSnapLocationHorizontal;
        [self.containerView setCenter:self.mainViewSnapLocation];
    }];
    CPAnimationSequence *fullSequence = [CPAnimationSequence sequenceWithSteps:moveContainerViewOffScreen, recenterContainerView, nil];
    [fullSequence runAnimated:[self.viewHasAppeared boolValue]];
}

@end
