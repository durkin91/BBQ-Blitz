//
//  BBQStraightMovement.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 4/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQStraightMovement.h"

@implementation BBQStraightMovement

- (instancetype)initWithDestinationColumn:(NSInteger)column row:(NSInteger)row {
    self = [super init];
    if (self) {
        self.destinationColumn = column;
        self.destinationRow = row;
    }
    return self;
}

@end
