//
//  BBQTile.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQTile.h"

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

- (void)addTileObstacle:(NSString *)tileType {
//    BBQTile *obstacle = [[BBQTile alloc] initWithTileType:tileType column:self.column row:self.row];
//    
//    if ([tileType isEqualToString:REGULAR_TILE] || [tileType isEqualToString:GOLD_PLATED_TILE] || [tileType isEqualToString:SILVER_PLATED_TILE]) {
//        if (!self.bottomTileObstacles) {
//            self.bottomTileObstacles = [NSMutableArray array];
//        }
//        [self.bottomTileObstacles addObject:obstacle];
//    }
}

@end
