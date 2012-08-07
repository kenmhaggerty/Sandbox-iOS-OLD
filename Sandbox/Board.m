//
//  Board.m
//  Sandbox
//
//  Created by Ken M. Haggerty on 5/7/12.
//  Copyright (c) 2012 MCMDI. All rights reserved.
//

#import "Board.h"

@interface Board ()
@property (nonatomic, strong) NSMutableArray *boardArray;
@end

@implementation Board

//// SETTERS AND GETTERS ////

@synthesize boardArray = _boardArray;
@synthesize rowsOnBoard = _rowsOnBoard;
@synthesize colsOnBoard = _colsOnBoard;
@synthesize cardClass = _cardClass;

//// INITS AND LOADS ////

- (id)initWithRows:(NSUInteger)rows andColumns:(NSUInteger)cols ofCardClass:(Class)cardClass
{
    self = [super init];
    if (self)
    {
        self.rowsOnBoard = rows;
        self.colsOnBoard = cols;
        self.cardClass = cardClass;
        self.boardArray = [[NSMutableArray alloc] initWithCapacity:rows*cols];
        for (int i = 0; i < rows*cols; i++)
        {
            [self.boardArray addObject:[[CardArray alloc] init]];
        }
    }
    return self;
}

//// PUBLIC FUNCTIONS ////

- (void)addCard:(Card *)card atRow:(NSUInteger)row andColumn:(NSUInteger)col
{
    if ((row <= self.rowsOnBoard) && (col <= self.colsOnBoard))
    {
        card.row = row;
        card.col = col;
        [[self.boardArray objectAtIndex:(col-1)+(row-1)*self.colsOnBoard] addCard:card];
    }
}

- (Card *)returnCardAtRow:(NSUInteger)row andColumn:(NSUInteger)col
{
    if ((row <= self.rowsOnBoard) && (col <= self.colsOnBoard)) return [[self returnCardArrayAtRow:row andColumn:col] lastCard];
    else return nil;
}

- (Card *)pullCardAtRow:(NSUInteger)row andColumn:(NSUInteger)col
{
    Card *cardToPull = [self returnCardAtRow:row andColumn:col];
    [self removeCardAtRow:row andColumn:col];
    return cardToPull;
}

- (void)removeCardAtRow:(NSUInteger)row andColumn:(NSUInteger)col
{
    if ((row <= self.rowsOnBoard) && (col <= self.colsOnBoard)) [[self returnCardArrayAtRow:row andColumn:col] removeLastCard];
}

- (CardArray *)returnCardArrayAtRow:(NSUInteger)row andColumn:(NSUInteger)col
{
    if ((row <= self.rowsOnBoard) && (col <= self.colsOnBoard)) return [self.boardArray objectAtIndex:(col-1)+(row-1)*self.colsOnBoard];
    else return nil;
}

- (void)reset
{
    for (int i = 0; i < self.rowsOnBoard*self.colsOnBoard; i++)
    {
        [[self.boardArray objectAtIndex:i] removeAllCards];
    }
}

- (Board *)getBoardOfTopCardsOnStacks
{
    Board *newBoard = [[Board alloc] initWithRows:self.rowsOnBoard andColumns:self.colsOnBoard ofCardClass:self.cardClass];
    for (int i = 1; i <= self.rowsOnBoard; i++)
    {
        for (int j = 1; j <= self.colsOnBoard; j++) [newBoard addCard:[self returnCardAtRow:i andColumn:j] atRow:i andColumn:j];
    }
    return newBoard;
}

@end
