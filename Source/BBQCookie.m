//
//  BBQCookie.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQCookie.h"
#import "BBQChain.h"

@implementation BBQCookie

- (NSString *)spriteNameBase {
    NSString *spriteName;
    
    switch (self.cookieType) {
        case 1:
            spriteName = @"Croissant";
            break;
            
        case 2:
            spriteName = @"Cupcake";
            break;
            
        case 3:
            spriteName = @"Danish";
            break;
            
        case 4:
            spriteName = @"Donut";
            break;
            
        case 5:
            spriteName = @"Macaroon";
            break;
            
        case 6:
            spriteName = @"SugarCookie";
            break;
            
        default:
            break;
    }
    
    return spriteName;
    
}

- (NSString *)spriteName {
    NSString *spriteName;
    
    if (self.temporaryPowerup == nil && self.activePowerup == nil) {
        spriteName = [self spriteNameBase];
    }
    
    if (self.temporaryPowerup) {
        
        if ([self.temporaryPowerup canBeDetonatedWithoutAChain]) {
            spriteName = [NSString stringWithFormat:@"%@%@", [self spriteNameBase], [self.temporaryPowerup powerupName]];
        }
        
        else {
            spriteName = [self.temporaryPowerup powerupName];
        }
    }
    
    else if (self.activePowerup) {
        if ([self.activePowerup canBeDetonatedWithoutAChain]) {
            spriteName = [NSString stringWithFormat:@"%@%@", [self spriteNameBase], [self.activePowerup powerupName]];
        }
        
        else {
            spriteName = [self.activePowerup powerupName];
        }
    }
    
    else {
        spriteName = [self spriteNameBase];
    }
    
    //safety net
    if (spriteName == nil) {
        spriteName = [self spriteNameBase];
    }
    
    return spriteName;
}

- (NSString *)highlightedSpriteName {
    
    NSString *spriteName = [NSString stringWithFormat:@"%@-Highlighted", [self spriteName]];
    return spriteName;
}

- (CCColor *)lineColor {
    CCColor *color;
    
    switch (_cookieType) {
        case 1:
            color = [CCColor colorWithRed:255.0/255.0 green:166.0/255.0 blue:0];
            break;
            
        case 2:
            color = [CCColor colorWithRed:217/255.0 green:55/255.0 blue:63/255.0];
            break;
            
        case 3:
            color = [CCColor colorWithRed:41/255.0 green:186/255.0 blue:248/255.0];
            break;
            
        case 4:
            color = [CCColor colorWithRed:248/255.0 green:97/255.0 blue:193/255.0];
            break;
            
        case 5:
            color = [CCColor colorWithRed:50/255.0 green:150/255.0 blue:77/255.0];
            break;
            
        case 6:
            color = [CCColor colorWithRed:226/255.0 green:217/255.0 blue:93/255.0];
            break;
            
        default:
            break;
    }
    
    return color;
}

- (BOOL)canBeChainedToCookie:(BBQCookie *)potentialCookie isFirstCookieInChain:(BOOL)isFirstCookieInChain {
    BOOL answer = NO;
    
    //Robbers sacks or multi cookies can't join to a pivot pad
    if (([self.activePowerup isAMultiCookie] || [self.activePowerup isAPivotPad]) &&
        ([potentialCookie.activePowerup isAPivotPad] || [potentialCookie.activePowerup isAMultiCookie])) {
        answer = NO;
    }
    
    else if ([self.activePowerup canOnlyJoinWithCookieNextToIt] &&
             isFirstCookieInChain &&
             (potentialCookie.column != self.column + 1 || potentialCookie.column != self.column - 1 || potentialCookie.row != self.row + 1 || potentialCookie.column != self.row - 1)) {
        answer = NO;
    }
    
    //If the cookie is the first cookie in the chain, and it tries to join with a multicookie or robbers sack then it can
    else if (([potentialCookie.activePowerup isAMultiCookie]) &&
             (potentialCookie.column == self.column + 1 || potentialCookie.column == self.column - 1 || potentialCookie.row == self.row + 1 || potentialCookie.row == self.row - 1) &&
             isFirstCookieInChain) {
        
        answer = YES;
        
    }
    
    //IF the cookie is the first cookie in the chain, and the potential cookie is next to it, and they are both a type 6, box or criss cross then they can be joined.
    else if (isFirstCookieInChain &&
             (potentialCookie.column == self.column + 1 || potentialCookie.column == self.column - 1 || potentialCookie.row == self.row + 1 || potentialCookie.row == self.row - 1) &&
             ([self.activePowerup isATypeSixPowerup] || [self.activePowerup isACrissCross] || [self.activePowerup isABox]) &&
             ([potentialCookie.activePowerup isATypeSixPowerup] || [potentialCookie.activePowerup isACrissCross] || [potentialCookie.activePowerup isABox])) {
        answer = YES;
    }
    
    //Multi cookies, robbers sacks and pivot pads can only join with the cookie next to it
    else if ([self.activePowerup canOnlyJoinWithCookieNextToIt] &&
        (potentialCookie.column == self.column + 1 || potentialCookie.column == self.column - 1 || potentialCookie.row == self.row + 1 || potentialCookie.row == self.row - 1)) {
        answer = YES;
    }
    
    //Pivot pads can join to anything (but not robbers sack and multi cookie, which has already been taken care of
    else if ([potentialCookie.activePowerup isAPivotPad]) {
        answer = YES;
    }
    
    //Same cookie types can join together
    else if (self.cookieType == potentialCookie.cookieType) {
        answer = YES;
    }
    
    else {
        answer = NO;
    }
    
    return answer;
}

- (void)setScoreForCookieInChain:(BBQChain *)chain {
    
    if ([self.activePowerup canBeDetonatedWithoutAChain]) {
        self.score = 150;
    }
    
    else if ([self.activePowerup isAMultiCookie]) {
        self.score = 200;
    }
    
    else {
        self.score = 30 + (([chain.cookiesInChain count] - 2) * 10);
    }
}

- (void)addCookieOrder:(NSArray *)cookieOrders {
    
    //find the right order
    for (BBQCookieOrder *cookieOrder in cookieOrders) {
        NSInteger x = 0;
        if (cookieOrder.cookie.cookieType == self.cookieType && cookieOrder.quantityLeft > 0 && !self.activePowerup) {
            self.cookieOrder = cookieOrder;
            x++;
        }
        cookieOrder.quantityLeft = cookieOrder.quantityLeft - x;
        cookieOrder.quantityLeft = MAX(0, cookieOrder.quantityLeft);
    }
    
}

- (void)addMovement:(id)movement {
    if (!_movements) {
        _movements = [NSMutableArray array];
    }
    [_movements addObject:movement];
}


- (NSString *)description {
    return [NSString stringWithFormat:@"type:%ld square:(%ld, %ld)", (long)self.cookieType, (long)self.column, (long)self.row];
}



@end
