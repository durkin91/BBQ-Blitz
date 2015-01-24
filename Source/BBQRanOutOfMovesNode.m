//
//  BBQRanOutOfMovesNode.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQRanOutOfMovesNode.h"
#import "BBQAnimations.h"

@implementation BBQRanOutOfMovesNode {
    CCButton *_keepPlayingButton;
    CCLabelTTF *_coinsLabel;
}

- (void)didLoadFromCCB {
    
    [BBQAnimations animateButton:_keepPlayingButton];
    
}

@end
