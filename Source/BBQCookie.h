//
//  BBQCookie.h
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBQCookieNode.h"
#import "BBQTile.h"
#import "BBQPowerup.h"

@class BBQCookieOrder;
@class BBQCombo;
@class BBQChain;

static const NSUInteger NumCookieTypes = 6;
static const NSUInteger NumStartingCookies = 3;

@interface BBQCookie : NSObject

@property (assign, nonatomic) NSInteger column;
@property (assign, nonatomic) NSInteger row;
@property (assign, nonatomic) NSUInteger cookieType;
@property (strong, nonatomic) BBQCookieNode *sprite;
@property (assign, nonatomic) BOOL isInStaticTile;
@property (assign, nonatomic) NSInteger countdown;
@property (strong, nonatomic) BBQPowerup *activePowerup;
@property (strong, nonatomic) BBQPowerup *temporaryPowerup;
@property (strong, nonatomic) BBQCookieOrder *cookieOrder;
@property (assign, nonatomic) NSInteger score;




- (NSString *)spriteName;
- (NSString *)highlightedSpriteName;
- (CCColor *)lineColor;
- (BOOL)canBeChainedToCookie:(BBQCookie *)potentialCookie isFirstCookieInChain:(BOOL)isFirstCookieInChain ;
- (void)setScoreForCookieInChain:(BBQChain *)chain;
- (void)addCookieOrder:(NSArray *)cookieOrders;

@end
