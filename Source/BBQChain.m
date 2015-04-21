//
//  BBQChain.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 3/18/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQChain.h"
#import "BBQLevel.h"

@implementation BBQChain {
    NSMutableArray *_cookies;
}

- (void)addCookie:(BBQCookie *)cookie {
    if (_cookiesInChain == nil) {
        _cookiesInChain = [NSMutableArray array];
    }
    
    //Only set the chain type if its not a pivot pad
    if (cookie.activePowerup.type != 9 && !_cookieType) {
        _cookieType = cookie.cookieType;
    }
    
    [_cookiesInChain addObject:cookie];
}

- (BOOL)containsCookie:(BBQCookie *)cookie {
    return [self.cookiesInChain containsObject:cookie];
}

- (BOOL)isACompleteChain {
    if ([self.cookiesInChain count] >= 3 || [self isATwoCookieChain]) {
        return YES;
    }
    else return NO;
}

- (BOOL)isATwoCookieChain {
    BBQCookie *firstCookie = [self.cookiesInChain firstObject];
    BBQCookie *secondCookie;
    if ([self.cookiesInChain count] >= 2) {
        secondCookie = [self.cookiesInChain objectAtIndex:1];
    }
    
    if ([self.cookiesInChain count] == 2 && [firstCookie.activePowerup isAMultiCookie]) {
        return YES;
    }
    
    else if ([self.cookiesInChain count] == 2 &&
             [secondCookie.activePowerup isAMultiCookie]) {
        return YES;
    }
    
    //If both cookies are either a type 6, box or criss cross powerup
    else if ([self.cookiesInChain count] == 2 &&
             ([firstCookie.activePowerup isATypeSixPowerup] || [firstCookie.activePowerup isACrissCross] || [firstCookie.activePowerup isABox]) &&
             ([secondCookie.activePowerup isATypeSixPowerup] || [secondCookie.activePowerup isABox] || [secondCookie.activePowerup isACrissCross])) {
        return YES;
    }
    
    else if ([self.cookiesInChain count] == 2 &&
             ([firstCookie.activePowerup isATwoSixesCombo] ||
              [firstCookie.activePowerup isATwoCrissCrossCombo] ||
              [firstCookie.activePowerup isATwoBoxCombo] ||
              [firstCookie.activePowerup isaTypeSixWithBoxCombo] ||
              [firstCookie.activePowerup isATypeSixWithCrissCrossCombo] ||
              [firstCookie.activePowerup isABoxAndCrissCrossCombo] ||
             [secondCookie.activePowerup isATwoSixesCombo] ||
             [secondCookie.activePowerup isATwoCrissCrossCombo] ||
             [secondCookie.activePowerup isATwoBoxCombo] ||
             [secondCookie.activePowerup isaTypeSixWithBoxCombo] ||
             [secondCookie.activePowerup isATypeSixWithCrissCrossCombo] ||
             [secondCookie.activePowerup isABoxAndCrissCrossCombo])) {
                 
                 return YES;
    }
    else return NO;
}

- (void)upgradePowerupsIfNecessary {
    if ([self.cookiesInChain count] == 2) {
        BBQCookie *firstCookie = [self.cookiesInChain firstObject];
        BBQCookie *secondCookie = [self.cookiesInChain lastObject];
        
        if (firstCookie.activePowerup && secondCookie.activePowerup) {
            
            if ([firstCookie.activePowerup isATypeSixPowerup] && [secondCookie.activePowerup isATypeSixPowerup]) {
                secondCookie.activePowerup.type = 100;
                firstCookie.activePowerup = nil;
            }
            
            else if ([firstCookie.activePowerup isABox] && [secondCookie.activePowerup isABox]) {
                secondCookie.activePowerup.type = 150;
                firstCookie.activePowerup = nil;
            }
            
            else if ([firstCookie.activePowerup isACrissCross] && [secondCookie.activePowerup isACrissCross]) {
                secondCookie.activePowerup.type = 150;
                firstCookie.activePowerup = nil;
            }
            
            else if (([firstCookie.activePowerup isATypeSixPowerup] && [secondCookie.activePowerup isACrissCross]) || ([firstCookie.activePowerup isACrissCross] && [secondCookie.activePowerup isATypeSixPowerup])) {
                secondCookie.activePowerup.type = 250;
                firstCookie.activePowerup = nil;
            }
            
            else if (([firstCookie.activePowerup isATypeSixPowerup] && [secondCookie.activePowerup isABox]) || ([firstCookie.activePowerup isABox] && [secondCookie.activePowerup isATypeSixPowerup])) {
                secondCookie.activePowerup.type = 300;
                firstCookie.activePowerup = nil;
            }
            
            else if (([firstCookie.activePowerup isABox] && [secondCookie.activePowerup isACrissCross]) || ([firstCookie.activePowerup isACrissCross] && [secondCookie.activePowerup isABox])) {
                secondCookie.activePowerup.type = 350;
                firstCookie.activePowerup = nil;
            }
        }
    }
}

- (void)addCookieOrders:(NSArray *)cookieOrders {
    
    //find the right order
    for (BBQCookieOrder *cookieOrder in cookieOrders) {
        NSInteger x = 0;
        for (BBQCookie *cookie in self.cookiesInChain) {
            if (cookieOrder.cookie.cookieType == cookie.cookieType && cookieOrder.quantityLeft > 0 && !cookie.activePowerup) {
                cookie.cookieOrder = cookieOrder;
                x++;
            }
        }
        cookieOrder.quantityLeft = cookieOrder.quantityLeft - x;
        cookieOrder.quantityLeft = MAX(0, cookieOrder.quantityLeft);
    }
    
}

- (BOOL)isAMultiCookieUpgradedPowerupChain {
    if ([self.cookiesInChain count] == 2) {
        BBQCookie *firstCookie = self.cookiesInChain[0];
        BBQCookie *secondCookie = self.cookiesInChain[1];
        
        if (([firstCookie.activePowerup isAMultiCookie] || [secondCookie.activePowerup isAMultiCookie]) &&
            ([secondCookie.activePowerup isATypeSixPowerup] || [secondCookie.activePowerup isABox] || [secondCookie.activePowerup isACrissCross] || [firstCookie.activePowerup isATypeSixPowerup] || [firstCookie.activePowerup isABox] || [firstCookie.activePowerup isACrissCross])) {
            return YES;
            
        }
    }
    
    return NO;
}

- (BBQCookie *)returnMultiCookieInMultiCookiePowerup {
    BBQCookie *multicookie;
    for (BBQCookie *cookie in self.cookiesInChain) {
        if ([cookie.activePowerup isAMultiCookie]) {
            multicookie = cookie;
            break;
        }
    }
    return multicookie;
}

- (BBQCookie *)returnPowerupJoinedToMultiCookie {
    BBQCookie *powerupCookie;
    for (BBQCookie *cookie in self.cookiesInChain) {
        if ([cookie.activePowerup canBeDetonatedWithoutAChain]) {
            powerupCookie = cookie;
            break;
        }
    }
    return powerupCookie;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"Cookies involved: %@", self.cookiesInChain];
}



@end
