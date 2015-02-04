//
//  BBQAnimations.h
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBQCookie.h"

@interface BBQAnimations : NSObject

+ (void)animateButton:(CCButton *)button;
+ (void)animateMenuWithBackground:(CCNode *)background popover:(CCNode *)popover;
+ (void)animateScoreLabel:(CCLabelTTF *)scoreLabel;
+ (void)animateMarker:(CCNode *)marker;
+ (void)dismissMenuWithBackground:(CCNode *)background popover:(CCNode *)popover;
+ (void)dismissMenuWithoutTouchingBackground:(CCNode *)background popover:(CCNode *)popover;
+ (void)dismissMenu:(CCNode *)menu1 andShowMenu:(CCNode *)menu2 background:(CCNode *)background;
+ (void)animateProgressToNextLevelWithGreySteppingStones:(NSArray *)greySteppingStones yellowSteppingStones:(NSArray *)yellowSteppingStones greyLandingPad:(CCSprite *)greyLandingPad activeLandingPad:(CCNode *)activeLandingPad marker:(CCSprite *)marker;
+ (void)animateSwipe:(NSDictionary *)animations scoreLabel:(CCLabelTTF *)scoreLabel movesLabel:(CCLabelTTF *)movesLabel cookiesLayer:(CCNode *)cookiesLayer currentScore:(NSInteger)currentScore movesLeft:(NSInteger)movesLeft completion:(dispatch_block_t)completion;

@end
