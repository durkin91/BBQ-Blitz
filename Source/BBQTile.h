//
//  BBQTile.h
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBQTile : NSObject

@property (assign, nonatomic) NSInteger tileType;
@property (assign, nonatomic) CCSprite *sprite;

- (NSString *)spriteName;
- (instancetype)initWithTileType:(NSInteger)type;

@end
