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
            
        case 4:
            spriteName = @"GoldenGooseTile";
            break;
            
        default:
            break;
    }
    return spriteName;
}

- (instancetype)initWithTileType:(NSInteger)type {
    self = [super init];
    if (self) {
        self.tileType = type;
        
        switch (self.tileType) {
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
                
            case 4:
                self.isABlocker = YES;
                self.requiresACookie = NO;
                
            default:
                break;
        }
    }
    return self;
}

@end
