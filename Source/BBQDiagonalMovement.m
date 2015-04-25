//
//  BBQDiagonalMovement.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 4/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQDiagonalMovement.h"

@implementation BBQDiagonalMovement

- (instancetype)initWithDestinationColumn:(NSInteger)column row:(NSInteger)row {
    self = [super init];
    if (self) {
        _destinationColumn = column;
        _destinationRow = row;
    }
    return self;
}

@end
