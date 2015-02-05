//
//  BBQComboModel.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 2/5/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQComboModel.h"

@implementation BBQComboModel

- (instancetype)initWithCookieB:(BBQCookie *)cookieB numberOfCookiesInCombo:(NSInteger)numberOfCookiesInCombo {
    self = [super init];
    if (self) {
        self.cookieB = cookieB;
        self.numberOfCookiesInCombo = numberOfCookiesInCombo;
    }
    return self;
}

-(void)scoreCombo {
    NSInteger additionalCookiesInCombo = self.numberOfCookiesInCombo - 2;
    NSInteger exponential = pow(additionalCookiesInCombo + 1, 2.0);
    self.score = startingScoreForCombo + startingScoreForCombo * exponential;
}

@end
