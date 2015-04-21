//
//  BBQTile.h
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBQLaserTileNode.h"
#import "BBQTileObstacle.h"

@interface BBQTile : NSObject


@property (strong, nonatomic) CCNode *sprite;
@property (strong, nonatomic) BBQLaserTileNode *overlayTile;
@property (nonatomic) BOOL isABlocker;
@property (nonatomic) BOOL requiresACookie;
@property (nonatomic) NSInteger column;
@property (nonatomic) NSInteger row;
@property (assign, nonatomic) NSInteger tileType;
@property (strong, nonatomic) NSMutableArray *obstacles;
@property (strong, nonatomic) BBQTileObstacle *activeObstacle;


- (instancetype)initWithTileType:(NSInteger)tileType column:(NSInteger)column row:(NSInteger)row;
- (void)addTileObstacles:(NSArray *)obstacleName;
- (void)addTileObstacle:(BBQTileObstacle *)obstacle;
- (void)removeTileObstacle:(BBQTileObstacle *)obstacle;

@end
