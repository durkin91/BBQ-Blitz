//
//  BBQCombineCookies.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/15/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQComboAnimation.h"
#import "BBQLevel.h"

@implementation BBQComboAnimation

- (instancetype)initWithCookieA:(BBQCookie *)cookieA cookieB:(BBQCookie *)cookieB destinationColumn:(NSInteger)destinationColumn destinationRow:(NSInteger)destinationRow {
    self = [super init];
    if (self) {
        self.cookieA = cookieA;
        self.cookieB = cookieB;
        self.destinationColumn = destinationColumn;
        self.destinationRow = destinationRow;
    }
    return self;
}


- (NSString *)description {
    return [NSString stringWithFormat:@"%@ combine cookieA: %@ with cookieB: %@", [super description], self.cookieA, self.cookieB];
}

@end
