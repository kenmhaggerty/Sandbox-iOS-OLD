//
//  SandboxViewController.m
//  Sandbox
//
//  Created by Ken Haggerty on 5/2/12.
//  Copyright (c) 2012 MCMDI. All rights reserved.
//

#import "SandboxViewController.h"
#import <QuartzCore/Quartzcore.h>
#import "DraggableImageView.h"

#define ANGLE_TILTED_BACK 0.5
#define PERSPECTIVE_VALUE 400.0

@interface SandboxViewController ()
@property (nonatomic, weak) IBOutlet UIButton *testButton;
@property (nonatomic, weak) IBOutlet UIView *tiltedView;
@property (nonatomic) NSUInteger count;
@end

@implementation SandboxViewController

@synthesize testButton = _testButton;
@synthesize tiltedView = _tiltedView;
@synthesize count = _count;

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
    
//    [self.tiltedView addGestureRecognizer:singleTap];
    for (int i = 0; i < self.tiltedView.subviews.count; i++)
    {
        if ([[self.tiltedView.subviews objectAtIndex:i] isKindOfClass:[DraggableImageView class]])
        {
            [[self.tiltedView.subviews objectAtIndex:i] setDelegate:self];
        }
        else if (![[self.tiltedView.subviews objectAtIndex:i] isKindOfClass:[UIButton class]])
        {
//            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnce:)];
//            singleTap.numberOfTapsRequired = 1;
//            [[self.tiltedView.subviews objectAtIndex:i] addGestureRecognizer:singleTap];
//            NSLog(@"Class = %@", [[self.tiltedView.subviews objectAtIndex:i] class]);
        }
    }
    for (int i = 0; i < self.view.subviews.count; i++)
    {
        if ([[self.view.subviews objectAtIndex:i] isKindOfClass:[DraggableImageView class]])
        {
            [[self.view.subviews objectAtIndex:i] setDelegate:nil];
        }
    }
//    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnce:)];
//    singleTap.numberOfTapsRequired = 1;
//    singleTap.cancelsTouchesInView = NO;
//    [self.tiltedView addGestureRecognizer:singleTap];
//    [self.tiltedView setCanCancelContentTouches:NO];
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

// DELEGATED FUNCTIONS //

- (void)viewWasTapped:(DraggableImageView *)sender
{
    NSLog(@"[DraggableImageView] viewWasTapped");
    if (sender.subviews.count != 0) NSLog(@"Sender has %i subviews", sender.subviews.count);
    else
    {
        NSLog(@"TAPPED! count = %i", ++self.count);
        [sender removeFromSuperview];
    }
}

- (void)viewWasDoubleTapped:(DraggableImageView *)sender
{
    NSLog(@"[DraggableImageView] viewWasDoubleTapped");
}

- (void)viewIsBeingMoved:(DraggableImageView *)sender
{
    NSLog(@"[DraggableImageView] viewIsBeingMoved");
}

- (void)viewIsDoneMoving:(DraggableImageView *)sender
{
    NSLog(@"[DraggableImageView] viewIsDoneMoving");
}

// PUBLIC FUNCTIONS //

//- (void)tapOnce:(UIGestureRecognizer *)gesture
//{
//    NSLog(@"TRIGGERED: class = %@", gesture.view.class);
//    if (gesture.view.subviews.count == 0) NSLog(@"TAPPED! count = %i", ++self.count);
//}

// PRIVATE FUNCTIONS //

- (IBAction)testButtonAction:(id)sender
{
    NSLog(@"PRESSED: class = %@", [sender class]);
}

@end
