//
//  BBQCookieNode.h
//  BbqBlitz
//
//  Created by Nikki Durkin on 2/2/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface BBQCookieNode : CCNode

@property (strong, nonatomic) CCSprite *cookieSprite;
@property (strong, nonatomic) CCNode *countCircle;
@property (strong, nonatomic) CCLabelTTF *countLabel;
@property (strong, nonatomic) CCSprite *tickSprite;

@property (assign, nonatomic) NSInteger column;
@property (assign, nonatomic) NSInteger row;
@property (assign, nonatomic) NSInteger cookieType;

@end
