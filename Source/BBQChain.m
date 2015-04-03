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

-(NSString *)description {
    return [NSString stringWithFormat:@"Cookies involved: %@", self.cookiesInChain];
}

@end
