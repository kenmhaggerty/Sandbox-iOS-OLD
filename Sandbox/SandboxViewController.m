//
//  SandboxViewController.m
//  Sandbox
//
//  Created by Ken Haggerty on 5/2/12.
//  Copyright (c) 2012 MCMDI. All rights reserved.
//

#import "SandboxViewController.h"
#import <QuartzCore/Quartzcore.h>

#define ANGLE_TILTED_BACK 0.75
#define PERSPECTIVE_VALUE 400.0

@interface SandboxViewController ()
@property (nonatomic, weak) IBOutlet UIButton *testButton;
@property (nonatomic, weak) IBOutlet UIView *tiltedView;
@end

@implementation SandboxViewController

@synthesize testButton = _testButton;
@synthesize tiltedView = _tiltedView;

// SETTERS AND GETTERS //

// INITS AND LOADS //

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self awakeFromNib];
    
    // TILT tiltedView BACK - START //
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1 / PERSPECTIVE_VALUE;
    transform = CATransform3DRotate(transform, ANGLE_TILTED_BACK * M_PI_2, 1, 0, 0);
    self.tiltedView.layer.transform = transform;
    // TILT tiltedView BACK - END //
    
    // ADD GESTURE RECOGNIZERS FOR SUBVIEWS OF tiltedView - START //
//    for (int i = 0; i < self.tiltedView.subviews.count; i++)
//    {
//        UIView *subviewOfInterest = [self.tiltedView.subviews objectAtIndex:i];
//        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:subviewOfInterest action:@selector(tapOnce:)];
//        singleTap.numberOfTapsRequired = 1;
//        [subviewOfInterest addGestureRecognizer:singleTap];
//    }
    // ADD GESTURE RECOGNIZERS FOR SUBVIEWS OF tiltedView - START //
}

- (void)viewDidUnload
{
    [self setTestButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// PUBLIC FUNCTIONS //

- (void)tapOnce:(UIGestureRecognizer *)gesture
{
    //on a single  tap, call zoomToRect in UIScrollView
    NSLog(@"TAPPED!");
}

// PRIVATE FUNCTIONS //

- (IBAction)testButtonAction:(id)sender
{
    NSLog(@"PRESSED");
}

@end
