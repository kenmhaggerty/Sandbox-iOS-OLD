//
//  CardButton.h
//  Sandbox
//
//  Created by Ken Haggerty on 5/4/12.
//  Copyright (c) 2012 MCMDI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Card.h"

@interface CardButton : UIButton //<CardLocationDelegate>
@property (nonatomic) Card *card;
@property (nonatomic) NSUInteger row;
@property (nonatomic) NSUInteger col;
- (id)initWithRow:(NSUInteger)row andColumn:(NSUInteger)col;
@end