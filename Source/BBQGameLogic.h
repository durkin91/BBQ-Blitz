//
//  BBQGameLogic.h
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBQLevel.h"

#define COMBOS @"Combos"
#define MOVEMENTS @"Movements"

static const NSInteger startingScoreForCookie = 20;

@interface BBQGameLogic : NSObject

@property (strong, nonatomic) BBQLevel *level;
@property (assign, nonatomic) NSInteger currentScore;
@property (assign, nonatomic) NSInteger movesLeft;


- (NSSet *)setupGameLogicWithLevel:(NSInteger)level;
- (NSDictionary *)swipe:(NSString *)swipeDirection;
- (BOOL)isLevelComplete;
- (BOOL)areThereMovesLeft;


@end
