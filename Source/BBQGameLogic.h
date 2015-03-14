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
#define POWERUPS @"Powerups"
#define GOLDEN_GOOSE_COOKIES @"Golden Goose Cookies"
#define NEW_STEEL_BLOCKER_TILES @"New Steel Blocker Tiles"

@interface BBQGameLogic : NSObject

@property (strong, nonatomic) BBQLevel *level;
@property (nonatomic) NSInteger currentScore;
@property (nonatomic) NSInteger movesLeft;
@property (strong, nonatomic) NSMutableArray *cookieTypeCount;


- (NSSet *)setupGameLogicWithLevel:(NSInteger)level;
- (NSDictionary *)swipe:(NSString *)swipeDirection column:(NSInteger)columnToSwipe row:(NSInteger)rowToSwipe;
- (BOOL)isLevelComplete;
- (BOOL)areThereMovesLeft;
- (BOOL)isSecurityGuardAtZero;


@end
