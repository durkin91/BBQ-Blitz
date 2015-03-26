//
//  BBQCookieOrder.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 3/25/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQCookieOrder.h"

@implementation BBQCookieOrder

- (instancetype)initWithCookieType:(NSInteger)cookieType startingAmount:(NSInteger)startingAmount {
    self = [super init];
    if (self) {
        self.cookie = [[BBQCookie alloc] init];
        self.cookie.cookieType = cookieType;
        self.quantity = startingAmount;
        self.quantityLeft = startingAmount;
    }
    return self;
}

@end
