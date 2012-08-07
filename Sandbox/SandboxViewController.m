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
@property (nonatomic, weak) IBOutlet UIView *tiltedView;
@property (nonatomic, weak) IBOutlet UIButton *actionButton;
@end

@implementation SandboxViewController

@synthesize tiltedView = _tiltedView;
@synthesize actionButton = _actionButton;

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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// PUBLIC FUNCTIONS //

// PRIVATE FUNCTIONS //

- (IBAction)buttonPerformAnimation:(id)sender
{
    for (int i = 0; i < self.tiltedView.subviews.count; i++)
    {
        UIView *viewOfInterest = [self.tiltedView.subviews objectAtIndex:i];
//        CGRect newRect = [self.tiltedView convertRect:viewOfInterest.frame toView:self.view];
//        UIView *viewToAdd = [[UIView alloc] initWithFrame:newRect];
//        viewToAdd.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.5];
//        [self.view addSubview:viewToAdd];
        CGFloat scale = 3;
        CGRect originalRect = viewOfInterest.bounds;
        CGRect newRect = CGRectMake(viewOfInterest.bounds.origin.x, viewOfInterest.bounds.origin.y, viewOfInterest.bounds.size.width*scale, viewOfInterest.bounds.size.height*scale);
        [UIView animateWithDuration:2
                         animations:^{
                             [viewOfInterest setBounds:newRect];
                         }
                         completion:^(BOOL finished) {
                             NSLog(@"Part II");
                             [UIView animateWithDuration:2
                                              animations:^{
                                                  [viewOfInterest setBounds:originalRect];
                                              }
                                              completion:nil];
                         }];
    }
}

@end
