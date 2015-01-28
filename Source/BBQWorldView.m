//
//  BBQWorldView.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/29/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQWorldView.h"

@implementation BBQWorldView {
    CCNode *_levelsNode;
}

- (void)didLoadFromCCB {
    self.currentLevel = 2;
    [self setupWorld];
}

- (void)setupWorld {
    //Will have to rewrite this to read from JSON or something to put in world data
    
    for (int i = 1; i <= self.currentLevel; i++) {
        
        CCNode *nodeForThisLevel = _levelsNode.children[i - 1];
        
        //Light up the stepping stones
        NSArray *greySteppingStones = [self getSteppingStonesForLevel:i];
        NSLog(@"Stepping stones: %@", greySteppingStones);
        for (CCSprite *stone in greySteppingStones) {
            CCSprite *lightedStone = [CCSprite spriteWithImageNamed:@"assets/worlds/yellowSteppingStone.png"];
            lightedStone.position = stone.position;
            [nodeForThisLevel addChild:lightedStone];
            [stone removeFromParent];
        }
        NSLog(@"level's children: %@", nodeForThisLevel.children);
        
        //Light up the landing pad
        CCNode *greyLandingPad = [self getGreyLandingPadForLevel:i];
        CCSprite *activeLandingPad = [CCSprite spriteWithImageNamed:@"assets/worlds/activeLandingPad.png"];
        activeLandingPad.position = greyLandingPad.position;
        [nodeForThisLevel addChild:activeLandingPad];
        [greyLandingPad removeFromParent];
    }
}


- (NSArray *)getSteppingStonesForLevel:(NSInteger )level {
    CCNode *withSteppingStones = _levelsNode.children[level - 1];
    NSMutableArray *stonesArray = [withSteppingStones.children mutableCopy];
    [stonesArray removeObjectAtIndex:0];
    return stonesArray;
}

- (CCNode *)getGreyLandingPadForLevel:(NSInteger )level {
    CCNode *withSteppingStones = _levelsNode.children[level - 1];
    return withSteppingStones.children[0];
}

@end
