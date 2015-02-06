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
    static NSString * const spriteNames[] = {
        @"SharkTile",
    };
    
    return spriteNames[self.tileType - 2];
}

- (instancetype)initWithTileType:(NSInteger)type {
    self = [super init];
    if (self) {
        self.tileType = type;
    }
    return self;
}

@end
