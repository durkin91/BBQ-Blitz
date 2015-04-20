//
//  BBQTile.h
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBQLaserTileNode.h"

#define NO_TILE @"No Tile"
#define REGULAR_TILE @"Regular Tile"
#define GOLD_PLATED_TILE @"Gold Plated Tile"
#define SILVER_PLATED_TILE @"Silver Plated Tile"

@interface BBQTile : NSObject


@property (strong, nonatomic) CCNode *sprite;
@property (strong, nonatomic) BBQLaserTileNode *overlayTile;
@property (nonatomic) BOOL isABlocker;
@property (nonatomic) BOOL requiresACookie;
@property (nonatomic) NSInteger column;
@property (nonatomic) NSInteger row;
@property (strong, nonatomic) NSString *tileType;

- (NSString *)spriteName;
- (instancetype)initWithTileType:(NSString *)tileType column:(NSInteger)column row:(NSInteger)row;

@end
