//
//  BBQActiveLandingPad.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/28/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQActiveLandingPad.h"
#import "GameplayScene.h"

@implementation BBQActiveLandingPad

- (void)didLoadFromCCB {
    self.userInteractionEnabled = YES;
}

- (void)setLevel:(NSInteger)level {
    _level = level;
    _levelLabel.string = [NSString stringWithFormat:@"%d", level];
}

- (void)levelSelected {
    NSLog(@"level selected: %d", self.level);
    
    CCScene *scene = [CCBReader loadAsScene:@"Gameplay"];
    GameplayScene *gamePlay = (GameplayScene *)[scene.children objectAtIndex:0];
//    [gamePlay setupGameWithLevel:self.level];
//    [[CCDirector sharedDirector] replaceScene:(CCScene *)gamePlay];
    
    [[CCDirector sharedDirector] replaceScene:scene];
}

@end
