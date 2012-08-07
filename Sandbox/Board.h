//
//  Board.h
//  Sandbox
//
//  Created by Ken M. Haggerty on 5/7/12.
//  Copyright (c) 2012 MCMDI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"
#import "CardArray.h"

@interface Board : NSObject
@property (nonatomic) NSUInteger rowsOnBoard;
@property (nonatomic) NSUInteger colsOnBoard;
@property (nonatomic) Class cardClass;
- (id)initWithRows:(NSUInteger)rows andColumns:(NSUInteger)cols ofCardClass:(Class)cardClass;
- (void)addCard:(Card *)card atRow:(NSUInteger)row andColumn:(NSUInteger)col;
- (Card *)returnCardAtRow:(NSUInteger)row andColumn:(NSUInteger)col;
- (Card *)pullCardAtRow:(NSUInteger)row andColumn:(NSUInteger)col;
- (void)removeCardAtRow:(NSUInteger)row andColumn:(NSUInteger)col;
- (CardArray *)returnCardArrayAtRow:(NSUInteger)row andColumn:(NSUInteger)col;
- (void)reset;
- (Board *)getBoardOfTopCardsOnStacks; // eventually remove
@end
