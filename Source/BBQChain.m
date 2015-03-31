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
    if (_cookies == nil) {
        _cookies = [NSMutableArray array];
    }
    [_cookies addObject:cookie];
}

- (NSArray *)cookiesInChain {
    return _cookies;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"Cookies involved: %@", self.cookiesInChain];
}

@end
