//
//  BBQCookie.h
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBQCookieNode.h"

static const NSUInteger NumCookieTypes = 6;
static const NSUInteger NumStartingCookies = 5;
static const NSUInteger NumCookiesToUpgrade = 40;

@interface BBQCookie : NSObject

@property (assign, nonatomic) NSInteger column;
@property (assign, nonatomic) NSInteger row;
@property (assign, nonatomic) NSUInteger cookieType;
@property (assign, nonatomic) NSInteger count;
@property (strong, nonatomic) BBQCookieNode *sprite;
@property (assign, nonatomic) BOOL isFinalCookie;
@property (assign, nonatomic) BOOL isInStaticTile;



- (NSString *)spriteName;

@end
