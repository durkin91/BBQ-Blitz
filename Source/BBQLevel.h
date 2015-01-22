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
#import "BBQCombo.h"
#import "BBQMoveCookie.h"

static const NSInteger NumColumns = 9;
static const NSInteger NumRows = 9;

@interface BBQLevel : NSObject

@property (assign ,nonatomic) NSUInteger targetScore;
@property (assign, nonatomic) NSUInteger maximumMoves;
@property (strong, nonatomic) NSMutableArray *cookieOrders;

- (NSSet *)shuffle;

- (BBQCookie *)cookieAtColumn:(NSInteger)column row:(NSInteger)row;
- (instancetype)initWithFile:(NSString *)filename;
- (BBQTile *)tileAtColumn:(NSInteger)column row:(NSInteger)row;
- (void)replaceCookieAtColumn:(int)column row:(int)row withCookie:(BBQCookie *)cookie;
- (NSSet *)createCookiesInBlankTiles;

@end
