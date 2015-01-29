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
}

- (void)didLoadFromCCB {
    self.currentLevel = 3;
    [self setupWorld];
    NSLog(@"Position of world view: %@", NSStringFromCGPoint(self.position));
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
            CCSprite *marker = [CCSprite spriteWithImageNamed:@"assets/worlds/marker.png"];
            CGPoint position = CGPointMake(activeLandingPad.position.x, activeLandingPad.position.y + 20);
            marker.position = position;
            marker.anchorPoint = CGPointMake(0.5, 0);
            [self addChild:marker];
            [BBQAnimations animateMarker:marker];
            self.currentLevelLandingPad = activeLandingPad;
        }
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

-(void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    
    NSLog(@"World View was touched");
    
//    CGPoint touchLocation = [touch locationInNode:self];
//    
//    BBQActiveLandingPad *highlightedLandingPad;
//    
//    //find the correct landing pad that is touched
//    for (BBQActiveLandingPad *landingPad in _activeLandingPads) {
//        if (CGRectContainsPoint([landingPad boundingBox], touchLocation)) {
//            NSLog(@"Landing Pad for level %d was touched", landingPad.level);
//        }
//    }
}



@end
