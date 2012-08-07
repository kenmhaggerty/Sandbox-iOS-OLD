//
//  CardButton.m
//  Sandbox
//
//  Created by Ken Haggerty on 5/4/12.
//  Copyright (c) 2012 MCMDI. All rights reserved.
//

#import "CardButton.h"

@implementation CardButton

@synthesize card = _card;
@synthesize row = _row;
@synthesize col = _col;

//// SET, GET, INIT ////

- (Card *)card
{
    return _card;
}

- (void)setCard:(Card *)card
{
    _card = card;
    [self setTitle:[NSString stringWithFormat:@"%@ %@", card.suit, [NSString stringWithFormat:@"%i", card.number]] forState:UIControlStateNormal];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithRow:(NSUInteger)row andColumn:(NSUInteger)col
{
    self = [super init];
    if (self)
    {
        self.row = [[self.currentTitle substringToIndex:1] integerValue];
        self.col = [[self.currentTitle substringFromIndex:1] integerValue];
        [self setTitle:[NSMutableString stringWithFormat:@"NO CARD"] forState:UIControlStateNormal];
    }
    return self;
}

- (void)awakeFromNib
{
    self.row = [[self.currentTitle substringToIndex:1] integerValue];
    self.col = [[self.currentTitle substringFromIndex:1] integerValue];
    NSLog(@"CardButton set to row %i and col %i", self.row, self.col);
    [self setTitle:[NSMutableString stringWithFormat:@"NO CARD"] forState:UIControlStateNormal];
//    if ([self.positionDelegate isOnBoardView:self])
//    {
//        self.card.row = [[self.currentTitle substringToIndex:1] integerValue];
//        self.card.col = [[self.currentTitle substringFromIndex:1] integerValue];
//        [self setTitle:[NSMutableString stringWithFormat:@"NO CARD"] forState:UIControlStateNormal];
//    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end