//
//  BBQAnimations.h
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBQCookie.h"
#import "BBQGameLogic.h"

@interface BBQAnimations : NSObject

+ (void)animateButton:(CCButton *)button;
+ (void)animateScoreLabel:(CCLabelTTF *)scoreLabel;
+ (void)animateMenuWithBackground:(CCNode *)background popover:(CCNode *)popover;
+ (void)animateMarker:(CCNode *)marker;
+ (void)dismissMenuWithBackground:(CCNode *)background popover:(CCNode *)popover;
+ (void)dismissMenuWithoutTouchingBackground:(CCNode *)background popover:(CCNode *)popover;
+ (void)dismissMenu:(CCNode *)menu1 andShowMenu:(CCNode *)menu2 background:(CCNode *)background;
+ (void)animateProgressToNextLevelWithGreySteppingStones:(NSArray *)greySteppingStones yellowSteppingStones:(NSArray *)yellowSteppingStones greyLandingPad:(CCSprite *)greyLandingPad activeLandingPad:(CCNode *)activeLandingPad marker:(CCSprite *)marker;


@end
