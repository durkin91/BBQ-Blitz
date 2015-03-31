//
//  BBQMovement.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 3/27/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQMovement.h"

@implementation BBQMovement

- (instancetype)initWithCookie:(BBQCookie *)cookie destinationColumn:(NSInteger)destinationColumn destinationRow:(NSInteger)destinationRow {
    self = [super init];
    if (self) {
        self.cookie = cookie;
        self.destinationColumn = destinationColumn;
        self.destinationRow = destinationRow;
    }
    
    return self;
}

@end
