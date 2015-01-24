//
//  BBQMenu.h
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/24/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"
#import "BBQGameLogic.h"

#define NO_MORE_MOVES @"No More Moves"
#define LEVEL_COMPLETE @"Level Complete"

@interface BBQMenu : CCNode

- (void)displayMenuFor:(NSString *)command gameLogic:(BBQGameLogic *)gameLogic;

@end
