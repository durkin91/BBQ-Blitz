//
//  BBQPauseMovement.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 4/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQPauseMovement.h"

@implementation BBQPauseMovement

- (instancetype)init {
    self = [super init];
    if (self) {
        self.numberOfTilesToPauseFor = 1;
    }
    return self;
}

@end
