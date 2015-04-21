//
//  BBQTile.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQTile.h"
#import "BBQTileObstacle.h"

@implementation BBQTile


- (instancetype)initWithTileType:(NSInteger)tileType column:(NSInteger)column row:(NSInteger)row {
    self = [super init];
    if (self) {
        self.tileType = tileType;
        self.column = column;
        self.row = row;
    }
    return self;
}

- (void)setTileType:(NSInteger)tileType {
    _tileType = tileType;
    
    switch (tileType) {
        case 0:
        self.requiresACookie = NO;
        self.isABlocker = YES;
        break;
        
        case 1:
        self.requiresACookie = YES;
        self.isABlocker = NO;
        break;
        
        default:
        break;
    }
}

- (void)addTileObstacles:(NSArray *)obstacleNames {
    if (!self.obstacles) {
        self.obstacles = [NSMutableArray array];
    }
    for (NSString *obstacleName in obstacleNames) {
        BBQTileObstacle *obstacle = [[BBQTileObstacle alloc] initWithType:obstacleName column:self.column row:self.row];
        [self addTileObstacle:obstacle];
    }
}

- (void)addTileObstacle:(BBQTileObstacle *)obstacle {
    [self.obstacles addObject:obstacle];
    self.isABlocker = obstacle.isABlocker;
    self.requiresACookie = obstacle.requiresACookie;
}
@end
