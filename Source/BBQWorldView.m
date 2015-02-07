//
//  BBQWorldView.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/29/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQWorldView.h"
#import "BBQAnimations.h"

@implementation BBQWorldView {
    CCNode *_levelsNode;
    CCSprite *_marker;
}

- (void)didLoadFromCCB {
    self.currentLevel = 4;
    self.maxLevel = 4;
    [self setupWorld];
}

- (void)setupWorld {
    //Will have to rewrite this to read from JSON or something to put in world data
    
    for (int i = 1; i <= self.currentLevel; i++) {
        
        CCNode *nodeForThisLevel = _levelsNode.children[i - 1];
        
        //Light up the stepping stones
        NSArray *greySteppingStones = [self getSteppingStonesForLevel:i];
        for (CCSprite *stone in greySteppingStones) {
            CCSprite *lightedStone = [CCSprite spriteWithImageNamed:@"assets/worlds/yellowSteppingStone.png"];
            lightedStone.position = stone.position;
            [nodeForThisLevel addChild:lightedStone];
            [stone removeFromParent];
        }
        
        //Light up the landing pad and place the marker
        CCNode *greyLandingPad = [self getGreyLandingPadForLevel:i];
        BBQActiveLandingPad *activeLandingPad = (BBQActiveLandingPad *)[CCBReader load:@"ActiveLandingPad"];
        activeLandingPad.level = i;
        activeLandingPad.position = greyLandingPad.position;
        [nodeForThisLevel addChild:activeLandingPad];
        [greyLandingPad removeFromParent];
        
        
        if (i == self.currentLevel) {
            _marker = [CCSprite spriteWithImageNamed:@"assets/worlds/marker.png"];
            CGPoint position = CGPointMake(activeLandingPad.position.x, activeLandingPad.position.y + 20);
            _marker.position = position;
            _marker.anchorPoint = CGPointMake(0.5, 0);
            [self addChild:_marker];
            [BBQAnimations animateMarker:_marker];
            self.currentLevelLandingPad = activeLandingPad;
        }
    }
}

- (void)progressToNextLevel {
    self.maxLevel = self.maxLevel + 1;
    CCNode *nodeForThisLevel = _levelsNode.children[self.maxLevel - 1];
    
    //get grey and yellow stepping stones
    NSArray *greySteppingStones = [self getSteppingStonesForLevel:self.maxLevel];
    NSMutableArray *yellowSteppingStones = [@[] mutableCopy];
    for (CCSprite *greyStone in greySteppingStones) {
        CCSprite *lightedStone = [CCSprite spriteWithImageNamed:@"assets/worlds/yellowSteppingStone.png"];
        lightedStone.position = greyStone.position;
        lightedStone.visible = NO;
        [nodeForThisLevel addChild:lightedStone];
        [yellowSteppingStones addObject:lightedStone];
    }
    
    //get grey and active landing pad
    CCSprite *greyLandingPad = [self getGreyLandingPadForLevel:self.maxLevel];
    BBQActiveLandingPad *activeLandingPad = (BBQActiveLandingPad *)[CCBReader load:@"ActiveLandingPad"];
    activeLandingPad.level = self.maxLevel;
    activeLandingPad.position = greyLandingPad.position;
    activeLandingPad.visible = NO;
    [nodeForThisLevel addChild:activeLandingPad];
    
    [BBQAnimations animateProgressToNextLevelWithGreySteppingStones:greySteppingStones yellowSteppingStones:yellowSteppingStones greyLandingPad:greyLandingPad activeLandingPad:activeLandingPad marker:_marker];
    
}


- (NSArray *)getSteppingStonesForLevel:(NSInteger )level {
    CCNode *withSteppingStones = _levelsNode.children[level - 1];
    NSMutableArray *stonesArray = [withSteppingStones.children mutableCopy];
    [stonesArray removeObjectAtIndex:0];
    return stonesArray;
}

- (CCSprite *)getGreyLandingPadForLevel:(NSInteger )level {
    CCNode *withSteppingStones = _levelsNode.children[level - 1];
    return withSteppingStones.children[0];
}




@end
