//
//  BBQGameLogic.h
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBQLevel.h"
#import "BBQChain.h"

#define COMBOS @"Combos"
#define MOVEMENTS @"Movements"
#define MOVEMENTS_BATCH_2 @"Movements Batch 2"
#define DROP_MOVEMENTS @"Drop Movements"
#define POWERUPS @"Powerups"
#define GOLDEN_GOOSE_COOKIES @"Golden Goose Cookies"
#define NEW_STEEL_BLOCKER_TILES @"New Steel Blocker Tiles"

#define UP @"Up"
#define DOWN @"Down"
#define LEFT @"Left"
#define RIGHT @"Right"

@interface BBQGameLogic : NSObject

@property (strong, nonatomic) BBQLevel *level;
@property (nonatomic) NSInteger currentScore;
@property (nonatomic) NSInteger movesLeft;
@property (strong, nonatomic) BBQChain *chain;
@property (strong, nonatomic) NSMutableArray *chainIncludingLinkingCookies;


- (NSSet *)setupGameLogicWithLevel:(NSInteger)level;
- (BOOL)isLevelComplete;
- (BOOL)areThereMovesLeft;

- (void)startChainWithCookie:(BBQCookie *)cookie;
- (BBQChain *)removeCookiesInChain;
- (void)resetEverythingForNextTurn;
- (BOOL)isCookieABackTrack:(BBQCookie *)cookie;
- (NSArray *)backtrackedCookiesForCookie:(BBQCookie *)cookie;
- (void)calculateScoreForChain;
- (BBQCookie *)lastCookieInChain;
- (BBQCookie *)previousCookieToCookieInChain:(BBQCookie *)cookie;
- (NSArray *)tryAddingCookieToChain:(BBQCookie *)cookie inDirection:(NSString *)direction;
- (NSDictionary *)rootCookieLimits:(BBQCookie *)cookie;
- (NSString *)directionOfPreviousCookieInChain:(BBQCookie *)cookie;
- (BOOL)doesCookieNeedRemoving:(BBQCookie *)cookie;
- (void)addPowerupScoreToCurrentScore:(BBQPowerup *)powerup;
- (void)activatePowerupForCookie:(BBQCookie *)cookie;

@end
