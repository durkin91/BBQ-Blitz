//
//  BBQCombineCookies.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/15/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQCombo.h"
#import "BBQLevel.h"

@implementation BBQCombo

- (instancetype)initWithCookieA:(BBQCookie *)cookieA cookieB:(BBQCookie *)cookieB {
    self = [super init];
    if (self) {
        self.cookieA = cookieA;
        self.cookieB = cookieB;

    //cookie replacement logic in the level is performed in game logic class
    }
    return self;
}


- (NSString *)description {
    return [NSString stringWithFormat:@"%@ combine cookieA: %@ with cookieB: %@", [super description], self.cookieA, self.cookieB];
}

@end
