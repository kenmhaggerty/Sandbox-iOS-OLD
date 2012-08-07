//
//  Deck.m
//  Sandbox
//
//  Created by Ken M. Haggerty on 5/3/12.
//  Copyright (c) 2012 MCMDI. All rights reserved.
//

#import "Deck.h"

@interface Deck ()
- (NSMutableArray *)fisherYatesShuffle:(NSArray *)arraytoShuffle;
@end

@implementation Deck

//// SET, GET, INIT ////

@synthesize cardClass = _cardClass;

- (id)initWithCardClass:(Class)cardClass
{
    self = [super init];
    self.cardClass = cardClass;
    return self;
}

- (id)initWithNumOfDecks:(NSInteger)numOfDecks ofCardClass:(Class)cardClass
{
    self = [self initWithCardClass:cardClass];
    if (self)
    {
        Card *protoCard = [[cardClass alloc] init];
        for (int h = 0; h < numOfDecks; h++)
        {
            for (int i = 0; i < protoCard.suitsArray.count; i++)
            {
                for (int j = 0; j < protoCard.numsArray.count; j++)
                {
                    [self addCard:[[cardClass alloc] initWithSuit:[protoCard.suitsArray objectAtIndex:i] andNumber:[[protoCard.numsArray objectAtIndex:j] integerValue]]];
                }
            }
        }
    }
    return self;
}

- (id)initWithDeck:(Deck *)deck
{
    self = [self initWithCardClass:deck.cardClass];
    if (self) [self addCardsFromCardArray:deck];
    return self;
}

//// PUBLIC FUNCTIONS ////

- (void)shuffle
{
    self.array = [self fisherYatesShuffle:self.array];
}

//// PRIVATE FUNCTIONS ////

- (NSMutableArray *)fisherYatesShuffle:(NSArray *)arrayToShuffle
{
    NSMutableArray *mutableCopy = [arrayToShuffle mutableCopy];
    NSMutableArray *shuffledArray = [[NSMutableArray alloc] initWithCapacity:arrayToShuffle.count];
    while (mutableCopy.count > 0)
    {
        int i = arc4random() % mutableCopy.count;
        [shuffledArray addObject:[mutableCopy objectAtIndex:i]];
        [mutableCopy removeObjectAtIndex:i];
    }
    return shuffledArray;
}

@end