//
//  BBQTileObstacle.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 4/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQTileObstacle.h"

@implementation BBQTileObstacle

- (instancetype)initWithType:(NSString *)type column:(NSInteger)column row:(NSInteger)row {
    self = [super init];
    if (self) {
        self.type = type;
        self.column = column;
        self.row = row;
        
        [self setupProperties];
    }
    return self;
}

- (NSString *)spriteName {
    NSString *spriteName;
    if ([_type isEqualToString:GOLD_PLATED_TILE]) {
        spriteName = @"GoldPlatedTile";
    }
    
    else if ([_type isEqualToString:SILVER_PLATED_TILE]) {
        spriteName = @"SilverPlatedTile";
    }
    return spriteName;
 }

-(void)setupProperties {
    
    if ([_type isEqualToString:GOLD_PLATED_TILE]) {
        _isABlocker = NO;
        _requiresACookie = YES;
        _zOrder = 1;
    }
    
    else if ([_type isEqualToString:SILVER_PLATED_TILE]) {
        _isABlocker = NO;
        _requiresACookie = YES;
        _zOrder = 1;
    }
}

@end
