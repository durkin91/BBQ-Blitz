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
    
    switch (self.tileType) {
        case 1:
            spriteName = @"RegularTile";
            break;
            
        case 2:
            spriteName = @"GlassTile";
            break;
            
        case 3:
            spriteName = @"RegularTile";
            break;
            
        case 5:
            spriteName = @"SteelBlockerTile";
            break;
            
        case 6:
            spriteName = @"SteelBlockerFactoryTile";
            break;
            
        case 7:
            spriteName = @"RegularTile";
            break;
            
        case 8:
            spriteName = @"RegularTile";
            break;
            
        default:
            break;
    }
    return spriteName;
}

- (instancetype)initWithTileType:(NSInteger)type column:(NSInteger)column row:(NSInteger)row {
    self = [super init];
    if (self) {
        self.tileType = type;
        self.column = column;
        self.row = row;
    }
    return self;
}

- (void)setTileType:(NSInteger)tileType {
    _tileType = tileType;
    
    switch (_tileType) {
            
        case 0:
            self.isABlocker = YES;
            self.requiresACookie = NO;
            break;
            
        case 1:
            self.isABlocker = NO;
            self.requiresACookie = YES;
            self.staticTileCountdown = 0;
            break;
            
        case 2:
            self.isABlocker = YES;
            self.staticTileCountdown = 1;
            self.requiresACookie = YES;
            break;
            
        case 3:
            self.isABlocker = YES;
            self.staticTileCountdown = 2;
            self.requiresACookie = YES;
            break;
            
        case 5:
            self.isABlocker = YES;
            self.requiresACookie = NO;
            break;
            
        case 6:
            self.isABlocker = YES;
            self.requiresACookie = NO;
            break;
            
        case 7:
            self.isABlocker = NO;
            self.requiresACookie = YES;
            self.staticTileCountdown = 0;
            break;
            
        case 8:
            self.isABlocker = NO;
            self.requiresACookie = YES;
            self.staticTileCountdown = 0;
            break;
            
        default:
            break;
    }
}

@end
