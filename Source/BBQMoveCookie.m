//
//  BBQMoveCookie.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/16/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQMoveCookie.h"

@implementation BBQMoveCookie

-(instancetype)initWithCookieA:(BBQCookie *)cookieA destinationColumn:(NSInteger)column destinationRow:(NSInteger)row {
    self = [super init];
    if (self) {
        self.cookieA = cookieA;
        self.destinationColumn = column;
        self.destinationRow = row;
        cookieA.column = column;
        cookieA.row = row;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ move cookieA: %@ to:(%ld, %ld)", [super description], self.cookieA, (long)self.destinationColumn, (long)self.destinationRow];
}


@end
