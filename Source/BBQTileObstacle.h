//
//  BBQTileObstacle.h
//  BbqBlitz
//
//  Created by Nikki Durkin on 4/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

#define GOLD_PLATED_TILE @"Gold Plated Tile"
#define SILVER_PLATED_TILE @"Silver Plated Tile"

@interface BBQTileObstacle : NSObject

@property (assign, nonatomic) NSInteger column;
@property (assign, nonatomic) NSInteger row;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) CCSprite *sprite;
@property (assign, nonatomic) NSInteger zOrder;

@property (assign, nonatomic) BOOL isABlocker;
@property (assign, nonatomic) BOOL requiresACookie;


- (instancetype)initWithType:(NSString *)type column:(NSInteger)column row:(NSInteger)row;
- (NSString *)spriteName;

@end
