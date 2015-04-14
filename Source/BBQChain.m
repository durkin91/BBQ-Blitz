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
    if (cookie.powerup.type != 9 && !_cookieType) {
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
    
    if ([self.cookiesInChain count] == 2 &&
        ([firstCookie.powerup isAMultiCookie] || [firstCookie.powerup isARobbersSack])) {
        return YES;
    }
    
    else if ([self.cookiesInChain count] == 2 &&
             ([secondCookie.powerup isAMultiCookie] || [secondCookie.powerup isARobbersSack])) {
        return YES;
    }
    
    //If both cookies are either a type 6, box or criss cross powerup
    else if ([self.cookiesInChain count] == 2 &&
             ([firstCookie.powerup isATypeSixPowerup] || [firstCookie.powerup isACrissCross] || [firstCookie.powerup isABox]) &&
             ([secondCookie.powerup isATypeSixPowerup] || [secondCookie.powerup isABox] || [secondCookie.powerup isACrissCross])) {
        return YES;
    }
    
    else if ([self.cookiesInChain count] == 2 &&
             ([firstCookie.powerup isATwoSixesCombo] ||
              [firstCookie.powerup isATwoCrissCrossCombo] ||
              [firstCookie.powerup isATwoBoxCombo] ||
              [firstCookie.powerup isaTypeSixWithBoxCombo] ||
              [firstCookie.powerup isATypeSixWithCrissCrossCombo] ||
              [firstCookie.powerup isABoxAndCrissCrossCombo] ||
             [secondCookie.powerup isATwoSixesCombo] ||
             [secondCookie.powerup isATwoCrissCrossCombo] ||
             [secondCookie.powerup isATwoBoxCombo] ||
             [secondCookie.powerup isaTypeSixWithBoxCombo] ||
             [secondCookie.powerup isATypeSixWithCrissCrossCombo] ||
             [secondCookie.powerup isABoxAndCrissCrossCombo])) {
                 
                 return YES;
    }
    else return NO;
}

- (void)upgradePowerupsIfNecessary {
    if ([self.cookiesInChain count] == 2) {
        BBQCookie *firstCookie = [self.cookiesInChain firstObject];
        BBQCookie *secondCookie = [self.cookiesInChain lastObject];
        
        if (firstCookie.powerup.isCurrentlyTemporary == NO && secondCookie.powerup.isCurrentlyTemporary == NO) {
            
            if ([firstCookie.powerup isATypeSixPowerup] && [secondCookie.powerup isATypeSixPowerup]) {
                secondCookie.powerup.type = 100;
                firstCookie.powerup = nil;
            }
            
            else if ([firstCookie.powerup isABox] && [secondCookie.powerup isABox]) {
                secondCookie.powerup.type = 150;
                firstCookie.powerup = nil;
            }
            
            else if ([firstCookie.powerup isACrissCross] && [secondCookie.powerup isACrissCross]) {
                secondCookie.powerup.type = 150;
                firstCookie.powerup = nil;
            }
            
            else if (([firstCookie.powerup isATypeSixPowerup] && [secondCookie.powerup isACrissCross]) || ([firstCookie.powerup isACrissCross] && [secondCookie.powerup isATypeSixPowerup])) {
                secondCookie.powerup.type = 250;
                firstCookie.powerup = nil;
            }
            
            else if (([firstCookie.powerup isATypeSixPowerup] && [secondCookie.powerup isABox]) || ([firstCookie.powerup isABox] && [secondCookie.powerup isATypeSixPowerup])) {
                secondCookie.powerup.type = 300;
                firstCookie.powerup = nil;
            }
            
            else if (([firstCookie.powerup isABox] && [secondCookie.powerup isACrissCross]) || ([firstCookie.powerup isACrissCross] && [secondCookie.powerup isABox])) {
                secondCookie.powerup.type = 350;
                firstCookie.powerup = nil;
            }
        }
    }
}

- (void)addCookieOrders:(NSArray *)cookieOrders {
    
    //find the right order
    for (BBQCookieOrder *cookieOrder in cookieOrders) {
        NSInteger x = 0;
        for (BBQCookie *cookie in self.cookiesInChain) {
            if (cookieOrder.cookie.cookieType == cookie.cookieType && cookieOrder.quantityLeft > 0 && !cookie.powerup) {
                cookie.cookieOrder = cookieOrder;
                x++;
            }
        }
        cookieOrder.quantityLeft = cookieOrder.quantityLeft - x;
        cookieOrder.quantityLeft = MAX(0, cookieOrder.quantityLeft);
    }
    
    //    //find the right order
    //    for (BBQCookieOrder *cookieOrder in self.level.cookieOrders) {
    //        if (cookieOrder.cookie.cookieType == self.chain.cookieType) {
    //            self.chain.cookieOrder = cookieOrder;
    //
    //            //Figure out how many of the cookies are used for the order
    //            for (NSInteger i = 0; i < [self.chain.cookiesInChain count] && cookieOrder.quantityLeft > 0; i++) {
    //                self.chain.numberOfCookiesForOrder ++;
    //                cookieOrder.quantityLeft --;
    //            }
    //        }
    //    }
    
}

- (BOOL)isAMultiCookieUpgradedPowerupChain {
    if ([self.cookiesInChain count] == 2) {
        BBQCookie *firstCookie = self.cookiesInChain[0];
        BBQCookie *secondCookie = self.cookiesInChain[1];
        
        if (([firstCookie.powerup isAMultiCookie] || [secondCookie.powerup isAMultiCookie]) &&
            ([secondCookie.powerup isATypeSixPowerup] || [secondCookie.powerup isABox] || [secondCookie.powerup isACrissCross] || [firstCookie.powerup isATypeSixPowerup] || [firstCookie.powerup isABox] || [firstCookie.powerup isACrissCross])) {
            return YES;
            
        }
    }
    
    return NO;
}

- (BBQCookie *)returnMultiCookieInMultiCookiePowerup {
    BBQCookie *multicookie;
    for (BBQCookie *cookie in self.cookiesInChain) {
        if ([cookie.powerup isAMultiCookie]) {
            multicookie = cookie;
            break;
        }
    }
    return multicookie;
}

- (void)removeUndetonatedPowerupFromArraysOfPowerupsToDetonate:(BBQCookie *)cookie {
    if ([self isAMultiCookieUpgradedPowerupChain]) {
        BBQCookie *multicookie = [self returnMultiCookieInMultiCookiePowerup];
        
        for (NSInteger index = 0; index < [multicookie.powerup.arraysOfDisappearingCookies count]; index ++) {
            [multicookie.powerup.arraysOfDisappearingCookies[index] removeObject:cookie];
        }
    }
}

-(NSString *)description {
    return [NSString stringWithFormat:@"Cookies involved: %@", self.cookiesInChain];
}

@end
