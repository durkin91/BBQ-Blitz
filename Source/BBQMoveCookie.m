//
//  BBQMoveCookie.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/16/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQMoveCookie.h"

@implementation BBQMoveCookie

-(instancetype)initWithCookieA:(BBQCookie *)cookieA cookieB:(BBQCookie *)cookieB {
    self = [super init];
    if (self) {
        self.cookieA = cookieA;
        self.cookieB = cookieB;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ move cookieA: %@ to position of cookieB: %@", [super description], self.cookieA, self.cookieB];
}


@end
