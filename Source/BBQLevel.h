//
//  BBQLevel.h
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBQCookie.h"
#import "BBQTile.h"
#import "BBQComboAnimation.h"
#import "BBQMoveCookie.h"

static const NSInteger NumColumns = 9;
static const NSInteger NumRows = 9;

@interface BBQLevel : NSObject

@property (assign, nonatomic) NSUInteger targetScore;
@property (assign, nonatomic) NSUInteger maximumMoves;
@property (assign, nonatomic) NSUInteger securityGuardCountdown;
@property (strong, nonatomic) NSMutableArray *goldenGooseTiles;
@property (strong, nonatomic) NSMutableArray *steelBlockerFactoryTiles;
@property (strong, nonatomic) NSMutableArray *securityGuardCookies;


- (NSSet *)shuffle;

- (BBQCookie *)cookieAtColumn:(NSInteger)column row:(NSInteger)row;
- (instancetype)initWithFile:(NSString *)filename;
- (BBQTile *)tileAtColumn:(NSInteger)column row:(NSInteger)row;
- (void)replaceCookieAtColumn:(int)column row:(int)row withCookie:(BBQCookie *)cookie;
- (NSSet *)createCookiesInBlankTiles;
- (BBQCookie *)createCookieAtColumn:(NSInteger)column row:(NSInteger)row withType:(NSUInteger)cookieType;
- (NSArray *)fillHoles;
- (NSArray *)topUpCookies;

@end
