//
//  BBQTile.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQTile.h"

@implementation BBQTile

- (NSString *)obstacleSpriteName {
    
    NSString *spriteName;
    
    if ([self.tileType isEqualToString:GOLD_PLATED_TILE]) {
        spriteName = @"GoldPlatedTile";
    }
    else if ([self.tileType isEqualToString:SILVER_PLATED_TILE]) {
        spriteName = @"SilverPlatedTile";
    }
    
    return spriteName;
}

- (instancetype)initWithTileType:(NSString *)tileType column:(NSInteger)column row:(NSInteger)row {
    self = [super init];
    if (self) {
        self.tileType = tileType;
        self.column = column;
        self.row = row;
    }
    return self;
}

-(void)setTileType:(NSString *)tileType {
    _tileType = tileType;
    
    if ([tileType isEqualToString:NO_TILE]) {
        _isABlocker = YES;
        _requiresACookie = NO;
    }
    
    else if ([tileType isEqualToString:REGULAR_TILE]) {
        _isABlocker = NO;
        _requiresACookie = YES;
    }
    
    else if ([tileType isEqualToString:GOLD_PLATED_TILE]) {
        _isABlocker = NO;
        _requiresACookie = YES;
    }
    
    else if ([tileType isEqualToString:SILVER_PLATED_TILE]) {
        _isABlocker = NO;
        _requiresACookie = YES;
    }
}


- (void)addTileObstacle:(NSString *)tileType {
    BBQTile *obstacle = [[BBQTile alloc] initWithTileType:tileType column:self.column row:self.row];
    
    if ([tileType isEqualToString:REGULAR_TILE] || [tileType isEqualToString:GOLD_PLATED_TILE] || [tileType isEqualToString:SILVER_PLATED_TILE]) {
        if (!self.bottomTileObstacles) {
            self.bottomTileObstacles = [NSMutableArray array];
        }
        [self.bottomTileObstacles addObject:obstacle];
    }
}

@end
