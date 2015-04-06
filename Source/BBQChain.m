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
        _cookieType = cookie.cookieType;
    }
    [_cookiesInChain addObject:cookie];
}

- (BOOL)containsCookie:(BBQCookie *)cookie {
    return [self.cookiesInChain containsObject:cookie];
}

- (BOOL)isACompleteChain {
    if ([self.cookiesInChain count] >= 3) {
        return YES;
    }
    else return NO;
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

-(NSString *)description {
    return [NSString stringWithFormat:@"Cookies involved: %@", self.cookiesInChain];
}

@end
