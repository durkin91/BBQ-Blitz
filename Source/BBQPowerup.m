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

- (instancetype)initWithType:(NSInteger)type direction:(NSString *)direction {
    self = [super init];
    if (self) {
        self.type = type;
        self.hasBeenActivated = NO;
        
        if ([direction isEqualToString:RIGHT] || [direction isEqualToString:LEFT]) {
            self.direction = HORIZONTAL;
        }
        else if ([direction isEqualToString:UP] || [direction isEqualToString:DOWN]) {
            self.direction = VERTICAL;
        }
    }
    
    return self;
}

- (void)performPowerupWithLevel:(BBQLevel *)level cookie:(BBQCookie *)rootCookie {
    
    _level = level;
    
    switch (self.type) {
        case 3:
            if ([self.direction isEqualToString:HORIZONTAL]) {
                [self destroyOneCookieVertically:rootCookie];
            }
            else if ([self.direction isEqualToString:VERTICAL]) {
                [self destroyOneCookieHorizontally:rootCookie];
            }
            break;
            
        case 4:
            [self destroyOneCookieHorizontally:rootCookie];
            [self destroyOneCookieVertically:rootCookie];
            break;
            
        case 5:
            if ([self.direction isEqualToString:HORIZONTAL]) {
                [self destroyEntireColumnOfCookies:rootCookie];
            }
            else if ([self.direction isEqualToString:VERTICAL]) {
                [self destroyEntireRowOfCookies:rootCookie];
            }
            break;
            
        case 6:
            [self destroyCrissCrossCookies:rootCookie];
            break;
            
        case 7:
            [self destroyEntireColumnOfCookies:rootCookie];
            [self destroyEntireRowOfCookies:rootCookie];
            break;
            
        case 8:
            [self destroyRowAndColumnAndAroundRootCookie:rootCookie];
            break;
            
        case 9:
            [self destroyThreeByThree:rootCookie];
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

- (void)destroyOneCookieVertically:(BBQCookie *)rootCookie {
    NSInteger rootRow = rootCookie.row;
    if (rootRow < NumRows - 1) {
        [self destroyCookieAtColumn:rootCookie.column row:rootRow + 1];
    }
    if (rootRow >= 1) {
        [self destroyCookieAtColumn:rootCookie.column row:rootRow - 1];
    }
}

- (void)destroyOneCookieHorizontally:(BBQCookie *)rootCookie {
    NSInteger rootColumn = rootCookie.column;
    if (rootColumn < NumColumns - 1) {
        [self destroyCookieAtColumn:rootColumn + 1 row:rootCookie.row];
    }
    if (rootColumn >= 1) {
        [self destroyCookieAtColumn:rootColumn - 1 row:rootCookie.row];
    }
}

- (void)destroyEntireColumnOfCookies:(BBQCookie *)rootCookie {
    for (int i = 0; i < NumRows; i ++) {
        if (i != rootCookie.row) {
            [self destroyCookieAtColumn:rootCookie.column row:i];
        }
    }
}

- (void)destroyEntireRowOfCookies:(BBQCookie *)rootCookie {
    for (int i = 0; i < NumColumns; i ++) {
        if (i != rootCookie.column) {
            [self destroyCookieAtColumn:i row:rootCookie.row];
        }
    }
}

- (void)destroyCrissCrossCookies:(BBQCookie *)rootCookie {
    NSInteger rootColumn = rootCookie.column;
    NSInteger rootRow = rootCookie.row;
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

- (void)destroyRowAndColumnAndAroundRootCookie:(BBQCookie *)rootCookie {
    
    
    [self destroyEntireRowOfCookies:rootCookie];
    [self destroyEntireColumnOfCookies:rootCookie];
    
    //Left side
    NSInteger x = 1;
    NSInteger leftColumn = rootCookie.column - x;
    while (leftColumn >= 0 && x <= 2) {
        NSInteger row = rootCookie.row + 2;
        for (int i = 0; i <= 4; i ++) {
            if (row < NumRows && row > 0) {
                [self destroyCookieAtColumn:leftColumn row:row - i];
                
            }
            i++;
        }
    }
    
    //Right side
    x = 1;
    NSInteger rightColumn = rootCookie.column + x;
    while (rightColumn < NumColumns && x <= 2) {
        NSInteger row = rootCookie.row + 2;
        for (int i = 0; i <= 4; i ++) {
            if (row < NumRows && row > 0) {
                [self destroyCookieAtColumn:rightColumn row:row - i];
            }
            i++;
        }
    }
    
}

- (void)destroyThreeByThree:(BBQCookie *)rootCookie {
    [self destroyEntireColumnOfCookies:rootCookie];
    [self destroyEntireRowOfCookies:rootCookie];
    
    for (int i = 0; i < NumColumns; i ++) {
        [self destroyCookieAtColumn:i row:rootCookie.row + 1];
    }
    
    for (int i = 0; i < NumColumns; i ++) {
        [self destroyCookieAtColumn:i row:rootCookie.row - 1];
    }
    
    for (int i = 0; i < NumRows; i ++) {
        [self destroyCookieAtColumn:rootCookie.column + 1 row:i];
    }
    
    for (int i = 0; i < NumRows; i ++) {
        [self destroyCookieAtColumn:rootCookie.column - 1 row:i];
    }
 
}

@end
