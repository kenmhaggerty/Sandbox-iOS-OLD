//
//  Deck.h
//  Sandbox
//
//  Created by Ken M. Haggerty on 5/3/12.
//  Copyright (c) 2012 MCMDI. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "Card.h"
#import "CardArray.h"

@interface Deck : CardArray
@property (nonatomic) Class cardClass;
- (id)initWithCardClass:(Class)cardClass;
- (id)initWithNumOfDecks:(NSInteger)numOfDecks ofCardClass:(Class)cardClass;
- (id)initWithDeck:(Deck *)deck;
- (void)shuffle;
@end