//
//  BBQReplayNode.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/30/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQReplayNode.h"
#import "BBQAnimations.h"

@implementation BBQReplayNode {
    CCLabelTTF *_levelLabel;
    CCButton *_replayButton;
}

- (void)didLoadFromCCB {
    [BBQAnimations animateButton:_replayButton];
}

- (void)replay {
    [self.delegate didPressReplay];
}

@end
