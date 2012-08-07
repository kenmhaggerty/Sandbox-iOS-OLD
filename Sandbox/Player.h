//
//  Player.h
//  Sandbox
//
//  Created by Ken Haggerty on 5/4/12.
//  Copyright (c) 2012 MCMDI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"
#import "CardArray.h"

@interface Player : NSObject
@property (nonatomic, strong) CardArray *hand;
@property (nonatomic, strong) CardArray *tally;
- (id)init;
- (void)addCard:(Card *)card;
- (void)addCardsFromArray:(NSArray *)array;
- (void)addCardsFromCardArray:(CardArray *)cardArray;
- (void)removeCard:(Card *)card;
- (void)addCardToTally:(Card *)card;
- (void)addCardsToTallyFromArray:(NSArray *)array;
- (void)addCardsToTallyFromCardArray:(CardArray *)cardArray;
- (void)reset;
@end