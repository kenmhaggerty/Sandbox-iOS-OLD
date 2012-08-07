//
//  SandboxBrain.m
//  Sandbox
//
//  Created by Ken Haggerty on 5/18/12.
//  Copyright (c) 2012 MCMDI. All rights reserved.
//

//// TO DO ////
// [_] Create protocol <BrainDelegateProtocol> that SandboxBrain follows
// [_] SandboxBrain will act as BrainDelegate for SandboxViewController
// [_] SandboxBrain handles ALL game logic for threeo
// [_] Only public functions for SandboxBrain are those that relate to user actions
// [_] SandboxBrain has access to all public API of sender
// [x] Does currentPlayer need lazy instantiation? >> NO

#import "SandboxBrain.h"
#import "Board.h"
#import "Deck.h"

#define ROWS_ON_BOARD 3
#define COLS_ON_BOARD 3
#define NUM_OF_DECKS 1
#define CARDS_IN_ROW_TO_CLAIM 3

@interface SandboxBrain ()

@property (nonatomic, strong) Board *board;
@property (nonatomic, strong) Deck *masterDeck;
@property (nonatomic, strong) Deck *sourceDeck;
@property (nonatomic, strong) Player *player;
@property (nonatomic, strong) Player *opponent;
@property (nonatomic, strong) Player *currentPlayer;
@property (nonatomic, strong) Card *currentCard;
- (void)functionsToPerformBetweenTurns;
- (NSMutableArray *)getAllThreeosOnBoard:(Board *)board;

@end

@implementation SandboxBrain

@synthesize board = _board;
@synthesize masterDeck = _masterDeck;
@synthesize sourceDeck = _sourceDeck;
@synthesize player = _player;
@synthesize opponent = _opponent;
@synthesize currentPlayer = _currentPlayer;
@synthesize currentCard = _currentCard;

//// SETTERS AND GETTERS ////

- (void)setBoard:(Board *)board
{
    _board = board;
}

- (Board *)board
{
    if (!_board) _board = [[Board alloc] initWithRows:ROWS_ON_BOARD andColumns:COLS_ON_BOARD ofCardClass:[Card class]];
    return _board;
}

- (void)setMasterDeck:(Deck *)masterDeck
{
    _masterDeck = masterDeck;
}

- (Deck *)masterDeck
{
    if (!_masterDeck) _masterDeck = [[Deck alloc] initWithNumOfDecks:NUM_OF_DECKS ofCardClass:[Card class]];
    return _masterDeck;
}

- (void)setSourceDeck:(Deck *)sourceDeck
{
    _sourceDeck = sourceDeck;
}

- (Deck *)sourceDeck
{
    if (!_sourceDeck)
    {
        _sourceDeck = [[Deck alloc] initWithDeck:self.masterDeck];
    }
    return _sourceDeck;
}

- (void)setPlayer:(Player *)player
{
    _player = player;
}

- (Player *)player
{
    if (!_player)
    {
        _player = [[Player alloc] init];
    }
    return _player;
}

- (void)setOpponent:(Player *)opponent
{
    _opponent = opponent;
}

- (Player *)opponent
{
    if (!_opponent)
    {
        _opponent = [[Player alloc] init];
    }
    return _opponent;
}

//// LOADS AND INITS ////

- (id)init
{
    self = [super init];
    if (self)
    {
        self.sourceDeck = [[Deck alloc] initWithNumOfDecks:NUM_OF_DECKS ofCardClass:[Card class]];
        self.currentPlayer = self.player;
        [self.sourceDeck shuffle];
    }
    return self;
}

//// PUBLIC FUNCTIONS ////

- (void)addCard:(Card *)card AtRow:(NSUInteger)row andColumn:(NSUInteger)col withSender:(id)sender
{
    
}

- (void)dealCardToPlayer:(Player *)player withSender:(id)sender
{
    
}

- (void)endGameWithSender:(id)sender
{
    
}

- (void)newGameWithSender:(id)sender
{
    
}

- (void)saveGameWithSender:(id)sender
{
    
}

//// PRIVATE FUNCTIONS ////

- (void)functionsToPerformBetweenTurns
{
    NSMutableArray *threeosOnBoard = [[NSMutableArray alloc] initWithArray:[self getAllThreeosOnBoard:self.board]];
    NSMutableArray *suitToAddToTally = [[NSMutableArray alloc] init];
    for (int i = 0; i < threeosOnBoard.count; i++) // for each threeo
    {
        for (int j = 0; j < [[threeosOnBoard objectAtIndex:i] count]; j++) // for each item in threeo
        {
            if ([[[threeosOnBoard objectAtIndex:i] objectAtIndex:j] number] == [[[threeosOnBoard objectAtIndex:i] objectAtIndex:0] number]) // make sure all cards are of same value
            {
                if (j == 0) suitToAddToTally = [[[[threeosOnBoard objectAtIndex:i] objectAtIndex:j] suitsArray] mutableCopy];
                [suitToAddToTally removeObject:[[[threeosOnBoard objectAtIndex:i] objectAtIndex:j] suit]];
            }
            else
            {
                NSLog(@"Threeo set %i not all of same number", i);
                break;
            }
            
            // remove cards from board
        }
        if (suitToAddToTally.count == 1)
        {
            NSString *suitForTally = [suitToAddToTally lastObject];
            NSUInteger numForTally = [[[threeosOnBoard objectAtIndex:i] objectAtIndex:0] number];
            [self.currentPlayer.tally addObject:[[Card alloc] initWithSuit:suitForTally andNumber:numForTally]];
            NSLog(@"Card added to tally: %i %@", [[self.currentPlayer.tally lastObject] number], [[self.currentPlayer.tally lastObject] suit]);
        }
    }
}

- (NSMutableArray *)getAllThreeosOnBoard:(Board *)board
{
    Board *visibleBoard = [board getBoardOfTopCardsOnStacks];
    NSMutableArray *arrayOfAllThreeoArrays = [[NSMutableArray alloc] init];
    if ((visibleBoard.colsOnBoard >= CARDS_IN_ROW_TO_CLAIM) || (visibleBoard.rowsOnBoard >= CARDS_IN_ROW_TO_CLAIM))
    {
        NSMutableArray *threeoTrackerForRow = [[NSMutableArray alloc] init];
        NSMutableArray *threeoTrackerForCol = [[NSMutableArray alloc] initWithCapacity:visibleBoard.colsOnBoard];
        for (int i = 0; i < visibleBoard.colsOnBoard; i++)
        {
            [threeoTrackerForCol addObject:[[NSMutableArray alloc] init]];
        }
        NSUInteger numOfDiagonalThreeos = 1+(visibleBoard.rowsOnBoard-CARDS_IN_ROW_TO_CLAIM)+(visibleBoard.colsOnBoard-CARDS_IN_ROW_TO_CLAIM);
        NSMutableArray *threeoTrackerForDownRight = [[NSMutableArray alloc] initWithCapacity:numOfDiagonalThreeos];
        NSMutableArray *threeoTrackerForUpRight = [[NSMutableArray alloc] initWithCapacity:numOfDiagonalThreeos];
        for (int i = 0; i < numOfDiagonalThreeos; i++)
        {
            [threeoTrackerForDownRight addObject:[[NSMutableArray alloc] init]];
            [threeoTrackerForUpRight addObject:[[NSMutableArray alloc] init]];
        }
        for (int i = 1; i <= visibleBoard.rowsOnBoard; i++) // go through rows
        {
            for (int j = 1; j <= visibleBoard.colsOnBoard; j++) // items in each row
            {
                Card *cardOfInterest = [visibleBoard returnCardAtRow:i andColumn:j];
                NSLog(@"card of interest = %i %@", cardOfInterest.number, cardOfInterest.suit);
                //// SEACH ROW THREEOS ////
                if (CARDS_IN_ROW_TO_CLAIM-threeoTrackerForRow.count <= visibleBoard.colsOnBoard-j+1) // enough cards left in row to check row threeo
                {
                    if (threeoTrackerForRow.count == 2) // two cards already detected
                    {
                        if ([[threeoTrackerForRow lastObject] number] == cardOfInterest.number) // is same as previous so threeo
                        {
                            NSLog(@"Row Threeo found!");
                            [threeoTrackerForRow addObject:cardOfInterest];
                            [arrayOfAllThreeoArrays addObject:[threeoTrackerForRow mutableCopy]];
                            [threeoTrackerForRow removeAllObjects]; // does this empty out?
                            NSLog(@"Row Threeo added to array? Count = %i with %i objects", arrayOfAllThreeoArrays.count, [[arrayOfAllThreeoArrays lastObject] count]);
                        }
                        else // clear tracker, add current card
                        {
                            NSLog(@"%i %@ (%i,%i) != %i %@ (%i,%i)", cardOfInterest.number, cardOfInterest.suit, i, j, [[threeoTrackerForRow lastObject] number], [[threeoTrackerForRow lastObject] suit], [[threeoTrackerForRow lastObject] row], [[threeoTrackerForRow lastObject] col]);
                            [threeoTrackerForRow removeAllObjects];
                            [threeoTrackerForRow addObject:cardOfInterest];
                        }
                    }
                    else if (threeoTrackerForRow.count == 1) // one card saved
                    {
                        if ([[threeoTrackerForRow lastObject] number] == cardOfInterest.number) // current card matches previous
                        {
                            NSLog(@"Two in a row found!");
                            [threeoTrackerForRow addObject:cardOfInterest];
                        }
                        else // clear tracker, add current card
                        {
                            NSLog(@"%i %@ (%i,%i) != %i %@ (%i,%i)", cardOfInterest.number, cardOfInterest.suit, i, j, [[threeoTrackerForRow lastObject] number], [[threeoTrackerForRow lastObject] suit], [[threeoTrackerForRow lastObject] row], [[threeoTrackerForRow lastObject] col]);
                            [threeoTrackerForRow removeAllObjects];
                            [threeoTrackerForRow addObject:cardOfInterest];
                        }
                    }
                    else // no cards saved
                    {
                        NSLog(@"cardOfInterest added to threeoTrackerForRow");
                        [threeoTrackerForRow addObject:cardOfInterest];
                    }
                    NSLog(@"Done seaching row threeos for (%i,%i)", i, j);
                }
                //// SEARCH COLUMN THREEOS ////
                if (CARDS_IN_ROW_TO_CLAIM-[[threeoTrackerForCol objectAtIndex:j-1] count] <= visibleBoard.rowsOnBoard-i+1) // enough cards left in col to check col threeo
                {
                    NSLog(@"Tracker for Col %i has %i objects", j, [[threeoTrackerForCol objectAtIndex:j-1] count]);
                    if ([[threeoTrackerForCol objectAtIndex:j-1] count] == 2) // two cards already detected
                    {
                        if ([[[threeoTrackerForCol objectAtIndex:j-1] lastObject] number] == cardOfInterest.number) // is same as previous so threeo
                        {
                            NSLog(@"Col Threeo found!");
                            [[threeoTrackerForCol objectAtIndex:j-1] addObject:cardOfInterest];
                            [arrayOfAllThreeoArrays addObject:[[threeoTrackerForCol objectAtIndex:j-1] mutableCopy]];
                            [[threeoTrackerForCol objectAtIndex:j-1] removeAllObjects];
                            NSLog(@"Col Threeo added to array? Count = %i with %i objects", arrayOfAllThreeoArrays.count, [[arrayOfAllThreeoArrays lastObject] count]);
                        }
                        else // clear tracker, add current card
                        {
                            NSLog(@"%i %@ (%i,%i) != %i %@ (%i,%i)", cardOfInterest.number, cardOfInterest.suit, i, j, [[[threeoTrackerForCol objectAtIndex:j-1] lastObject] number], [[[threeoTrackerForCol objectAtIndex:j-1] lastObject] suit], [[[threeoTrackerForCol objectAtIndex:j-1] lastObject] row], [[[threeoTrackerForCol objectAtIndex:j-1] lastObject] col]);
                            [[threeoTrackerForCol objectAtIndex:j-1] removeAllObjects];
                            [[threeoTrackerForCol objectAtIndex:j-1] addObject:cardOfInterest];
                        }
                    }
                    else if ([[threeoTrackerForCol objectAtIndex:j-1] count] == 1) // one card saved
                    {
                        NSLog(@"Last Card is %i %@", [[[threeoTrackerForCol objectAtIndex:j-1] lastObject] number], [[[threeoTrackerForCol objectAtIndex:j-1] lastObject] suit]);
                        NSLog(@"cardOfInterest.number = %i", cardOfInterest.number);
                        if ([[[threeoTrackerForCol objectAtIndex:j-1] lastObject] number] == cardOfInterest.number) // current card matches previous
                        {
                            NSLog(@"Two in a col found!");
                            [[threeoTrackerForCol objectAtIndex:j-1] addObject:cardOfInterest];
                        }
                        else // clear tracker, add current card
                        {
                            NSLog(@"%i %@ (%i,%i) != %i %@ (%i,%i)", cardOfInterest.number, cardOfInterest.suit, i, j, [[[threeoTrackerForCol objectAtIndex:j-1] lastObject] number], [[[threeoTrackerForCol objectAtIndex:j-1] lastObject] suit], [[[threeoTrackerForCol objectAtIndex:j-1] lastObject] row], [[[threeoTrackerForCol objectAtIndex:j-1] lastObject] col]);
                            [[threeoTrackerForCol objectAtIndex:j-1] removeAllObjects];
                            [[threeoTrackerForCol objectAtIndex:j-1] addObject:cardOfInterest];
                        }
                    }
                    else // no cards saved
                    {
                        NSLog(@"cardOfInterest added to threeoTrackerForCol");
                        [[threeoTrackerForCol objectAtIndex:j-1] addObject:cardOfInterest];
                    }
                    NSLog(@"Done seaching col threeos for (%i,%i)", i, j);
                }
                //// SEARCH DOWNRIGHT THREEOS ////
                NSInteger indexOfDownRightThreeoTracker = i-j;
                if (indexOfDownRightThreeoTracker > (NSInteger)visibleBoard.rowsOnBoard-CARDS_IN_ROW_TO_CLAIM)
                {
                    indexOfDownRightThreeoTracker = numOfDiagonalThreeos+1;
                }
                if (indexOfDownRightThreeoTracker < 0)
                {
                    indexOfDownRightThreeoTracker = (NSInteger)visibleBoard.rowsOnBoard-CARDS_IN_ROW_TO_CLAIM+j-i;
                }
                if (indexOfDownRightThreeoTracker < numOfDiagonalThreeos)
                {
                    if ([[threeoTrackerForDownRight objectAtIndex:indexOfDownRightThreeoTracker] count] == 2) // two cards already detected
                    {
                        if ([[[threeoTrackerForDownRight objectAtIndex:indexOfDownRightThreeoTracker] lastObject] number] == cardOfInterest.number) // is same as previous so threeo
                        {
                            NSLog(@"DownRight Threeo found!");
                            [[threeoTrackerForDownRight objectAtIndex:indexOfDownRightThreeoTracker] addObject:cardOfInterest];
                            [arrayOfAllThreeoArrays addObject:[[threeoTrackerForDownRight objectAtIndex:indexOfDownRightThreeoTracker] mutableCopy]];
                            [[threeoTrackerForDownRight objectAtIndex:indexOfDownRightThreeoTracker] removeAllObjects];
                            NSLog(@"DownRight Threeo added to array? Count = %i with %i objects", arrayOfAllThreeoArrays.count, [[arrayOfAllThreeoArrays lastObject] count]);
                        }
                        else // clear tracker, add current card
                        {
                            [[threeoTrackerForDownRight objectAtIndex:indexOfDownRightThreeoTracker] removeAllObjects];
                            [[threeoTrackerForDownRight objectAtIndex:indexOfDownRightThreeoTracker] addObject:cardOfInterest];
                        }
                    }
                    else if ([[threeoTrackerForDownRight objectAtIndex:indexOfDownRightThreeoTracker] count] == 1) // one card saved
                    {
                        if ([[[threeoTrackerForDownRight objectAtIndex:indexOfDownRightThreeoTracker] lastObject] number] == cardOfInterest.number) // current card matches previous
                        {
                            [[threeoTrackerForDownRight objectAtIndex:indexOfDownRightThreeoTracker] addObject:cardOfInterest];
                        }
                        else // clear tracker, add current card
                        {
                            [[threeoTrackerForDownRight objectAtIndex:indexOfDownRightThreeoTracker] removeAllObjects];
                            [[threeoTrackerForDownRight objectAtIndex:indexOfDownRightThreeoTracker] addObject:cardOfInterest];
                        }
                    }
                    else // no cards saved
                    {
                        NSLog(@"cardOfInterest added to threeoTrackerForDownRight");
                        [[threeoTrackerForDownRight objectAtIndex:indexOfDownRightThreeoTracker] addObject:cardOfInterest];
                    }
                    NSLog(@"Done seaching downRight threeos for (%i,%i)", i, j);
                }
                //// SEARCH UPRIGHT THREEOS ////
                NSInteger indexOfUpRightThreeoTracker = (NSInteger)visibleBoard.rowsOnBoard-i+1-j;
                if (indexOfUpRightThreeoTracker > (NSInteger)visibleBoard.rowsOnBoard-CARDS_IN_ROW_TO_CLAIM)
                {
                    indexOfUpRightThreeoTracker = numOfDiagonalThreeos+1;
                }
                if (indexOfUpRightThreeoTracker < 0)
                {
                    indexOfUpRightThreeoTracker = i+j-CARDS_IN_ROW_TO_CLAIM-1;
                }
                if (indexOfUpRightThreeoTracker < numOfDiagonalThreeos)
                {
                    if ([[threeoTrackerForUpRight objectAtIndex:indexOfUpRightThreeoTracker] count] == 2) // two cards already detected
                    {
                        if ([[[threeoTrackerForUpRight objectAtIndex:indexOfUpRightThreeoTracker] lastObject] number] == cardOfInterest.number) // is same as previous so threeo
                        {
                            NSLog(@"UpRight Threeo found!");
                            [[threeoTrackerForUpRight objectAtIndex:indexOfUpRightThreeoTracker] addObject:cardOfInterest];
                            [arrayOfAllThreeoArrays addObject:[[threeoTrackerForUpRight objectAtIndex:indexOfUpRightThreeoTracker] mutableCopy]];
                            [[threeoTrackerForUpRight objectAtIndex:indexOfUpRightThreeoTracker] removeAllObjects];
                            NSLog(@"UpRight Threeo added to array? Count = %i with %i objects", arrayOfAllThreeoArrays.count, [[arrayOfAllThreeoArrays lastObject] count]);
                        }
                        else // clear tracker, add current card
                        {
                            [[threeoTrackerForUpRight objectAtIndex:indexOfUpRightThreeoTracker] removeAllObjects];
                            [[threeoTrackerForUpRight objectAtIndex:indexOfUpRightThreeoTracker] addObject:cardOfInterest];
                        }
                    }
                    else if ([[threeoTrackerForUpRight objectAtIndex:indexOfUpRightThreeoTracker] count] == 1) // one card saved
                    {
                        if ([[[threeoTrackerForUpRight objectAtIndex:indexOfUpRightThreeoTracker] lastObject] number] == cardOfInterest.number) // current card matches previous
                        {
                            [[threeoTrackerForUpRight objectAtIndex:indexOfUpRightThreeoTracker] addObject:cardOfInterest];
                        }
                        else // clear tracker, add current card
                        {
                            [[threeoTrackerForUpRight objectAtIndex:indexOfUpRightThreeoTracker] removeAllObjects];
                            [[threeoTrackerForUpRight objectAtIndex:indexOfUpRightThreeoTracker] addObject:cardOfInterest];
                        }
                    }
                    else // no cards saved
                    {
                        NSLog(@"cardOfInterest added to threeoTrackerForUpRight");
                        [[threeoTrackerForUpRight objectAtIndex:indexOfUpRightThreeoTracker] addObject:cardOfInterest];
                    }
                    NSLog(@"Done seaching upRight threeos for (%i,%i)", i, j);
                }
                
                // more stuff here
            }
            [threeoTrackerForRow removeAllObjects];
        }
    }
    NSLog(@"Num of Threeos = %i", arrayOfAllThreeoArrays.count);
    return arrayOfAllThreeoArrays;
}

@end
