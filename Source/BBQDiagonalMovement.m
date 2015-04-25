//
//  BBQDiagonalMovement.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 4/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQDiagonalMovement.h"

@implementation BBQDiagonalMovement

- (instancetype)initWithStartColumn:(NSInteger)startColumn startRow:(NSInteger)startRow destinationColumn:(NSInteger)destinationColumn destinationRow:(NSInteger)destinationRow {
    self = [super init];
    if (self) {
        _destinationColumn = destinationColumn;
        _destinationRow = destinationRow;
        _startColumn = startColumn;
        _startRow = startRow;
    }
    return self;
}

@end
