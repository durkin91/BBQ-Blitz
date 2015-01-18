//
//  BBQCookie.h
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

static const NSUInteger NumCookieTypes = 6;
static const NSUInteger NumStartingCookies = 2;

@interface BBQCookie : NSObject

@property (assign, nonatomic) NSInteger column;
@property (assign, nonatomic) NSInteger row;
@property (assign, nonatomic) NSUInteger cookieType;
@property (assign, nonatomic) CCSprite *sprite;
@property (assign, nonatomic) CCSprite *upgradedSprite;
@property (assign, nonatomic) NSUInteger status;

//Status 1 is alive, status 2 is eaten

- (NSString *)spriteName;
- (NSString *)highlightedSpriteName;

@end
