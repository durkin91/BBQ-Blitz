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
static const NSUInteger NumStartingCookies = 2;
static const NSUInteger NumCookiesToUpgrade = 4;

@interface BBQCookie : NSObject

@property (assign, nonatomic) NSInteger column;
@property (assign, nonatomic) NSInteger row;
@property (assign, nonatomic) NSUInteger cookieType;
@property (assign, nonatomic) NSInteger count;
@property (assign, nonatomic) BBQCookieNode *sprite;



- (NSString *)spriteName;
- (NSString *)highlightedSpriteName;

@end
