//
//  BBQTile.h
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBQLaserTileNode.h"

@interface BBQTile : NSObject

@property (assign, nonatomic) NSInteger tileType;
@property (strong, nonatomic) CCNode *sprite;
@property (strong, nonatomic) BBQLaserTileNode *overlayTile;
@property (nonatomic) BOOL isABlocker;
@property (nonatomic) NSInteger staticTileCountdown;
@property (nonatomic) BOOL requiresACookie;

- (NSString *)spriteName;
- (instancetype)initWithTileType:(NSInteger)type;

@end
