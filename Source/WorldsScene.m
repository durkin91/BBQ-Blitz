//
//  WorldsScene.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/28/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "WorldsScene.h"
#import "BBQWorldView.h"
#import "BBQActiveLandingPad.h"

@implementation WorldsScene {
    CCScrollView *_worldMapScrollView;
    BBQWorldView *_worldNode;
    CCSprite *_livesSprite;
    CCSprite *_coinsSprite;
    CCLabelTTF *_numberOfLivesLabel;
    CCLabelTTF *_numberOfCoinsLabel;
    CCButton *_backButton;
    CCButton *_forwardButton;
    CCLabelTTF *_worldNameLabel;
}

- (void)didLoadFromCCB {
    _worldNode = (BBQWorldView *)_worldMapScrollView.contentNode;
    
}

- (void)openUpNextLevel {
    
}




@end
