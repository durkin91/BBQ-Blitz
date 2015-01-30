//
//  BBQStartLevelNode.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/29/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQStartLevelNode.h"
#import "BBQAnimations.h"

@implementation BBQStartLevelNode {
    CCButton *_playButton;
}

- (void)didLoadFromCCB {
    [BBQAnimations animateButton:_playButton];
}

- (void)play {
    [self.delegate didPlay];
}

@end
