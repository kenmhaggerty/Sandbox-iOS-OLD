//
//  SandboxBrain.h
//  Sandbox
//
//  Created by Ken Haggerty on 5/18/12.
//  Copyright (c) 2012 MCMDI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"
#import "Player.h"

@interface SandboxBrain : NSObject

- (void)addCard:(Card *)card AtRow:(NSUInteger)row andColumn:(NSUInteger)col withSender:(id)sender;
- (void)dealCardToPlayer:(Player *)player withSender:(id)sender;
- (void)endGameWithSender:(id)sender;
- (void)newGameWithSender:(id)sender;
- (void)saveGameWithSender:(id)sender;

@end
