//
//  BBQTileObstacle.h
//  BbqBlitz
//
//  Created by Nikki Durkin on 4/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBQCookieOrder.h"

@class BBQCookieOrder;

#define GOLD_PLATED_TILE @"Gold Plated Tile"
#define SILVER_PLATED_TILE @"Silver Plated Tile"
#define WAD_OF_CASH_ONE @"Wad Of Cash One"
#define WAD_OF_CASH_TWO @"Wad Of Cash Two"
#define WAD_OF_CASH_THREE @"Wad Of Cash Three"

@interface BBQTileObstacle : NSObject

@property (assign, nonatomic) NSInteger column;
@property (assign, nonatomic) NSInteger row;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) CCSprite *sprite;
@property (assign, nonatomic) NSInteger zOrder;
@property (strong, nonatomic) BBQCookieOrder *cookieOrder;

@property (assign, nonatomic) BOOL isABlocker;
@property (assign, nonatomic) BOOL requiresACookie;
@property (assign, nonatomic) BOOL detonatesWhenAdjacentToCookie;


- (instancetype)initWithType:(NSString *)type column:(NSInteger)column row:(NSInteger)row;
- (NSString *)spriteName;
- (NSString *)spriteNameForPurposesOfCookieOrderCollection;
- (void)addOrderToObstacle:(NSArray *)cookieOrders;

@end
