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
#define GOLDEN_GOOSE_COOKIES @"Golden Goose Cookies"

@interface BBQGameLogic : NSObject

@property (strong, nonatomic) BBQLevel *level;
@property (nonatomic) NSInteger currentScore;
@property (nonatomic) NSInteger movesLeft;
@property (strong, nonatomic) NSMutableArray *cookieTypeCount;


- (NSSet *)setupGameLogicWithLevel:(NSInteger)level;
- (NSDictionary *)swipe:(NSString *)swipeDirection;
- (BOOL)isLevelComplete;
- (BOOL)areThereMovesLeft;


@end
