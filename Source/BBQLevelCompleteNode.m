//
//  BBQLevelCompleteNode.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQLevelCompleteNode.h"
#import "BBQAnimations.h"


@implementation BBQLevelCompleteNode {
    CCButton *_nextButton;
}

- (void)didLoadFromCCB {
    [BBQAnimations animateButton:_nextButton];
}

- (void)nextButtonPressed {
    [self.delegate didPressNext];
}

@end
