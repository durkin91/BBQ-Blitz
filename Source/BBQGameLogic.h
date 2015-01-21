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
#define EATEN_COOKIES @"Eaten Cookies"

static const NSInteger startingScoreForCookie = 20;

@interface BBQGameLogic : NSObject

@property (strong, nonatomic) BBQLevel *level;
@property (assign, nonatomic) NSInteger *currentScore;


- (NSSet *)setupGame;
- (NSDictionary *)swipe:(NSString *)swipeDirection;
- (NSMutableArray *)eatCookies;


@end
