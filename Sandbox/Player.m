//
//  Player.m
//  Sandbox
//
//  Created by Ken M. Haggerty on 5/4/12.
//  Copyright (c) 2012 MCMDI. All rights reserved.
//

#import "Player.h"
#import "Card.h"

@implementation Player

@synthesize hand = _hand;
@synthesize tally = _tally;

// SETTERS AND GETTERS //

- (CardArray *)hand
{
    if (!_hand) _hand = [[CardArray alloc] init];
    return _hand;
}

- (void)setHand:(CardArray *)hand
{
    _hand = hand;
}

- (CardArray *)tally
{
    if (!_tally) _tally = [[CardArray alloc] init];
    return _tally;
}

- (void)setTally:(CardArray *)tally
{
    _tally = tally;
}

// LOADS AND INITS //

- (id)init
{
    self = [super init];
    if (self)
    {
        self.hand = [[CardArray alloc] init];
        self.tally = [[CardArray alloc] init];
    }
    return self;
}

//// PUBLIC FUNCTIONS ////

- (void)addCard:(Card *)card
{
    [self.hand addCard:card];
}

- (void)addCardsFromArray:(NSArray *)array
{
    [self.hand addCardsFromArray:array];
}

- (void)addCardsFromCardArray:(CardArray *)cardArray
{
    [self.hand addCardsFromCardArray:cardArray];
}

- (void)removeCard:(Card *)card
{
    [self.hand removeCard:card];
}

- (void)addCardToTally:(Card *)card
{
    [self.tally addCard:card];
}

- (void)addCardsToTallyFromArray:(NSArray *)array
{
    [self.tally addCardsFromArray:array];
}

- (void)addCardsToTallyFromCardArray:(CardArray *)cardArray
{
    [self.tally addCardsFromCardArray:cardArray];
}

- (void)reset
{
    [self.hand removeAllCards];
    [self.tally removeAllCards];
}

//// PRIVATE FUNCTIONS ////

@end