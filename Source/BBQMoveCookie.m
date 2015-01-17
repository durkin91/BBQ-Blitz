//
//  BBQMoveCookie.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/16/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQMoveCookie.h"

@implementation BBQMoveCookie

-(instancetype)initWithCookieA:(BBQCookie *)cookieA destination:(CGPoint)position {
    self = [super init];
    if (self) {
        self.cookieA = cookieA;
        self.destination = position;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ move cookieA: %@ to position: %@", [super description], self.cookieA, NSStringFromCGPoint(self.destination)];
}


@end
