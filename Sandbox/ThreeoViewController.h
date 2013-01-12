//
//  ThreeoViewController.h
//  Woodbox
//
//  Created by Ken M. Haggerty on 11/23/12.
//  Copyright (c) 2012 MCMDI. All rights reserved.
//

#pragma mark - // NOTES (Public) //

//  This UIViewController creates a three-pane sliding UI,
//  wherein a sideView is hidden behind a double-height
//  containerView (private) that contains a mainView and
//  a topView. The mainView is the primary view. The
//  topView is a secondary view that can be viewed by
//  sliding the containerView down. The sideView is a
//  tertiary view that can be viewed by sliding the
//  containerView to the right. The containerView contains
//  two CustomButtons that can be tapped to animated the
//  containerView to reveal the topView or sideView.

#pragma mark - // IMPORTS (Public) //

#import <UIKit/UIKit.h>

#pragma mark - // PROTOCOLS //

@protocol MainViewControllerProtocol <NSObject>
- (void)mainViewIsSnappedClosed;
- (void)mainViewIsSnappedOpenVertical;
- (void)mainViewIsSnappedOpenHorizontal;
@end

#pragma mark - // DEFINITIONS //

@interface ThreeoViewController : UIViewController
@property (nonatomic, strong) IBOutlet UIView *mainView;
@property (nonatomic, strong) UIViewController <MainViewControllerProtocol> *mainViewController;
@property (nonatomic, strong) IBOutlet UIView *topView;
@property (nonatomic, strong) UIViewController *topViewController;
@property (nonatomic, strong) IBOutlet UIView *sideView;
@property (nonatomic, strong) UIViewController *sideViewController;
- (BOOL)viewMainView;
- (BOOL)viewTopView;
- (BOOL)viewSideView;
@end
