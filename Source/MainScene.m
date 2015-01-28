//
//  MainScene.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/28/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "MainScene.h"
#import "BBQAnimations.h"

@implementation MainScene {
    CCButton *_playButton;
}

- (void)didLoadFromCCB {
    [BBQAnimations animateButton:_playButton];    
}

- (void)playGame {
    CCScene *gamePlayScene = [CCBReader loadAsScene:@"Worlds"];
    [[CCDirector sharedDirector] replaceScene:gamePlayScene];
}

@end
