//
//  BBQPowerup.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 3/13/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQPowerup.h"
#import "BBQLevel.h"
#import "BBQGameLogic.h"

@implementation BBQPowerup {
    BBQLevel *_level;
}

- (instancetype)initWithCookie:(BBQCookie *)cookie type:(NSInteger)type direction:(NSString *)swipeDirection {
    self = [super init];
    if (self) {
        self.rootCookie = cookie;
        self.type = type;
        
        if ([swipeDirection isEqualToString:RIGHT] || [swipeDirection isEqualToString:LEFT]) {
            self.direction = HORIZONTAL;
        }
        else if ([swipeDirection isEqualToString:UP] || [swipeDirection isEqualToString:DOWN]) {
            self.direction = VERTICAL;
        }
    }
    
    return self;
}

- (void)performPowerupWithLevel:(BBQLevel *)level {
    
    _level = level;
    
    switch (self.type) {
        case 3:
            if ([self.direction isEqualToString:HORIZONTAL]) {
                [self destroyOneCookieVertically];
            }
            else if ([self.direction isEqualToString:VERTICAL]) {
                [self destroyOneCookieHorizontally];
            }
            break;
            
        case 4:
            [self destroyOneCookieHorizontally];
            [self destroyOneCookieVertically];
            break;
            
        case 5:
            if ([self.direction isEqualToString:HORIZONTAL]) {
                [self destroyEntireColumnOfCookies];
            }
            else if ([self.direction isEqualToString:VERTICAL]) {
                [self destroyEntireRowOfCookies];
            }
            break;
            
        case 6:
            [self destroyCrissCrossCookies];
            break;
            
        case 7:
            [self destroyEntireColumnOfCookies];
            [self destroyEntireRowOfCookies];
            break;
            
        case 8:
            [self destroyRowAndColumnAndAroundRootCookie];
            break;
            
        case 9:
            [self destroyThreeByThree];
            break;
            
        default:
            break;
    }
}

- (void)destroyCookieAtColumn:(NSInteger)column row:(NSInteger)row {
    if (!self.disappearingCookies) {
        self.disappearingCookies = [@[] mutableCopy];
    }
    
    BBQCookie *cookie = [_level cookieAtColumn:column row:row];
    if (cookie != nil) {
        [self.disappearingCookies addObject:cookie];
        [_level replaceCookieAtColumn:column row:row withCookie:nil];
    }
}

- (void)destroyOneCookieVertically {
    NSInteger rootRow = self.rootCookie.row;
    if (rootRow < NumRows - 1) {
        [self destroyCookieAtColumn:self.rootCookie.column row:rootRow + 1];
    }
    if (rootRow >= 1) {
        [self destroyCookieAtColumn:self.rootCookie.column row:rootRow - 1];
    }
}

- (void)destroyOneCookieHorizontally {
    NSInteger rootColumn = self.rootCookie.column;
    if (rootColumn < NumColumns - 1) {
        [self destroyCookieAtColumn:rootColumn + 1 row:self.rootCookie.row];
    }
    if (rootColumn >= 1) {
        [self destroyCookieAtColumn:rootColumn - 1 row:self.rootCookie.row];
    }
}

- (void)destroyEntireColumnOfCookies {
    for (int i = 0; i < NumRows; i ++) {
        if (i != self.rootCookie.row) {
            [self destroyCookieAtColumn:self.rootCookie.column row:i];
        }
    }
}

- (void)destroyEntireRowOfCookies {
    for (int i = 0; i < NumColumns; i ++) {
        if (i != self.rootCookie.column) {
            [self destroyCookieAtColumn:i row:self.rootCookie.row];
        }
    }
}

- (void)destroyCrissCrossCookies {
    NSInteger rootColumn = self.rootCookie.column;
    NSInteger rootRow = self.rootCookie.row;
    NSInteger x = 1;
    while (rootColumn - x >= 0 && rootRow + x < NumRows) {
        [self destroyCookieAtColumn:rootColumn - x row:rootRow + x];
        x++;
    }
    x = 1;
    while (rootColumn + x < NumColumns && rootRow + x < NumRows) {
        [self destroyCookieAtColumn:rootColumn + x row:rootRow + x];
        x++;
    }
    x = 1;
    while (rootColumn - x >= 0 && rootRow - x >= 0) {
        [self destroyCookieAtColumn:rootColumn - x row:rootRow - x];
        x++;
    }
    x = 1;
    while (rootColumn + x < NumColumns && rootRow - x >= 0) {
        [self destroyCookieAtColumn:rootColumn + x row:rootRow - x];
        x++;
    }
}

- (void)destroyRowAndColumnAndAroundRootCookie {
    
    
    [self destroyEntireRowOfCookies];
    [self destroyEntireColumnOfCookies];
    
    //Left side
    NSInteger x = 1;
    NSInteger leftColumn = self.rootCookie.column - x;
    while (leftColumn >= 0 && x <= 2) {
        NSInteger row = self.rootCookie.row + 2;
        for (int i = 0; i <= 4; i ++) {
            if (row < NumRows && row > 0) {
                [self destroyCookieAtColumn:leftColumn row:row - i];
                
            }
            i++;
        }
    }
    
    //Right side
    x = 1;
    NSInteger rightColumn = self.rootCookie.column + x;
    while (rightColumn < NumColumns && x <= 2) {
        NSInteger row = self.rootCookie.row + 2;
        for (int i = 0; i <= 4; i ++) {
            if (row < NumRows && row > 0) {
                [self destroyCookieAtColumn:rightColumn row:row - i];
            }
            i++;
        }
    }
    
}

- (void)destroyThreeByThree {
    [self destroyEntireColumnOfCookies];
    [self destroyEntireRowOfCookies];
    
    for (int i = 0; i < NumColumns; i ++) {
        [self destroyCookieAtColumn:i row:self.rootCookie.row + 1];
    }
    
    for (int i = 0; i < NumColumns; i ++) {
        [self destroyCookieAtColumn:i row:self.rootCookie.row - 1];
    }
    
    for (int i = 0; i < NumRows; i ++) {
        [self destroyCookieAtColumn:self.rootCookie.column + 1 row:i];
    }
    
    for (int i = 0; i < NumRows; i ++) {
        [self destroyCookieAtColumn:self.rootCookie.column - 1 row:i];
    }
 
}

@end
