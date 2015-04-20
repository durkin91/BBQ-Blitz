//
//  BBQTile.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQTile.h"

@implementation BBQTile

- (NSString *)spriteName {
    
    NSString *spriteName;
    
    //CODE HERE
    
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
}


@end
