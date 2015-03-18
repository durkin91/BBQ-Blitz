//
//  BBQAnimations.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQAnimations.h"
#import "GameplayScene.h"

@implementation BBQAnimations

+ (void)animateButton:(CCButton *)button {
    //Create the action to animate the keep playing button
    CCActionScaleTo *scaleUp = [CCActionScaleTo actionWithDuration:1.0 scale:1.05];
    CCActionScaleTo *scaleDown = [CCActionScaleTo actionWithDuration:1.0 scale:1.0];
    CCActionSequence *sequence = [CCActionSequence actions:scaleUp, scaleDown, nil];
    CCActionRepeatForever *repeat = [CCActionRepeatForever actionWithAction:sequence];
    [button runAction:repeat];
}

+ (void)animateScoreLabel:(CCLabelTTF *)scoreLabel {
    CGPoint endPoint = CGPointMake(scoreLabel.position.x, scoreLabel.position.y + 40);
    CCActionMoveTo *moveLabel = [CCActionMoveTo actionWithDuration:0.6 position:endPoint];
    
    CCActionDelay *delayBeforeFade = [CCActionDelay actionWithDuration:0.3];
    CCActionFadeOut *fadeOut = [CCActionFadeOut actionWithDuration:0.3];
    CCActionSequence *fadeSequence = [CCActionSequence actions:delayBeforeFade, fadeOut, nil];
    
    CCActionSpawn *spawn = [CCActionSpawn actions:moveLabel, fadeSequence, nil];
    CCActionSequence *labelSequence = [CCActionSequence actions:spawn, [CCActionRemove action], nil];
    [scoreLabel runAction:labelSequence];
}

#pragma mark - Animate World View

+ (void)animateMarker:(CCNode *)marker {
    CGPoint startingPosition = marker.position;
    CCActionMoveTo *moveDown = [CCActionMoveTo actionWithDuration:1.0 position:ccp(marker.position.x, marker.position.y - 5)];
    CCActionMoveTo *moveUp = [CCActionMoveTo actionWithDuration:1.0 position:startingPosition];
    CCActionSequence *sequence = [CCActionSequence actions:moveDown, moveUp, nil];
    CCActionRepeatForever *repeat = [CCActionRepeatForever actionWithAction:sequence];
    [marker runAction:repeat];
}

+ (void)animateProgressToNextLevelWithGreySteppingStones:(NSArray *)greySteppingStones yellowSteppingStones:(NSArray *)yellowSteppingStones greyLandingPad:(CCSprite *)greyLandingPad activeLandingPad:(CCNode *)activeLandingPad marker:(CCSprite *)marker {
    
    [marker stopAllActions];
    
    //move across stones
    NSMutableArray *moveAcrossStones = [@[] mutableCopy];
    for (CCSprite *greyStone in greySteppingStones) {
        CGPoint position = CGPointMake(greyStone.position.x, greyStone.position.y + 20);
        CCActionMoveTo *moveMarker = [CCActionMoveTo actionWithDuration:0.5 position:position];
        CCActionCallBlock *showYellowStone = [CCActionCallBlock actionWithBlock:^{
            NSInteger index = [greySteppingStones indexOfObject:greyStone];
            CCSprite *yellowStone = yellowSteppingStones[index];
            yellowStone.visible = YES;
            [greyStone removeFromParent];
        }];
        CCActionSequence *sequence = [CCActionSequence actions:moveMarker, showYellowStone, nil];
        [moveAcrossStones addObject:sequence];
    }
    
    //move to active landing pad
    CGPoint markerPosition = CGPointMake(greyLandingPad.position.x, greyLandingPad.position.y + 20);
    CCActionMoveTo *moveToActivePad = [CCActionMoveTo actionWithDuration:0.5 position:markerPosition];
    [moveAcrossStones addObject:moveToActivePad];
    CCActionCallBlock *showActivePad = [CCActionCallBlock actionWithBlock:^{
        activeLandingPad.visible = YES;
        [greyLandingPad removeFromParent];
        [BBQAnimations animateMarker:marker];
    }];
    [moveAcrossStones addObject:showActivePad];
    
    CCActionSequence *moveMarker = [CCActionSequence actionWithArray:moveAcrossStones];
    [marker runAction:moveMarker];
}

#pragma mark - Animate Menus

+ (void)animateMenuWithBackground:(CCNode *)background popover:(CCNode *)popover {
    
    //fade in background
    CCActionFadeTo *fadeIn = [CCActionFadeTo actionWithDuration:0.3 opacity:0.7];
    [background runAction:fadeIn];
    
    popover.position = CGPointMake(popover.position.x, -160.0);
    [popover runAction:[BBQAnimations movePopoverOnScreenWithbackground:background]];

}

+ (void)animateMenuWithoutTouchingBackground:(CCNode *)background popover:(CCNode *)popover {
    popover.position = CGPointMake(popover.position.x, -160.0);
    [popover runAction:[BBQAnimations movePopoverOnScreenWithbackground:background]];
}

+ (void)dismissMenuWithBackground:(CCNode *)background popover:(CCNode *)popover {
    [popover runAction:[BBQAnimations movePopoverOffScreenWithBackground:background]];
    [BBQAnimations fadeOutBackground:background];
}

+ (void)dismissMenuWithoutTouchingBackground:(CCNode *)background popover:(CCNode *)popover {
    [popover runAction:[BBQAnimations movePopoverOffScreenWithBackground:background]];
}

+ (void)dismissMenu:(CCNode *)menu1 andShowMenu:(CCNode *)menu2 background:(CCNode *)background {
    
    menu2.position = CGPointMake(menu2.position.x, -160.0);
    
    CCActionCallBlock *dismissBlock = [CCActionCallBlock actionWithBlock:^{
        CCActionMoveTo *dismiss = [BBQAnimations movePopoverOffScreenWithBackground:background];
        [menu1 runAction:dismiss];
    }];
    
    CCActionCallBlock *enterBlock = [CCActionCallBlock actionWithBlock:^{
        CCActionMoveTo *enter = [BBQAnimations movePopoverOnScreenWithbackground:background];
        [menu2 runAction:enter];
    }];
    
    
    CCActionSequence *sequence = [CCActionSequence actions:dismissBlock, enterBlock, nil];
    [menu1 runAction:sequence];
    
}

+ (CCActionMoveTo *)movePopoverOffScreenWithBackground:(CCNode *)background {
    CGPoint endingPosition = CGPointMake(background.contentSize.width / 2 , background.contentSizeInPoints.height + 160);
    CCActionMoveTo *movePopover = [CCActionMoveTo actionWithDuration:0.3 position:endingPosition];
    return movePopover;
}

+ (CCActionMoveTo *)movePopoverOnScreenWithbackground:(CCNode *)background {
    //move popover
    float x = background.contentSize.width / 2;
    float y = background.contentSizeInPoints.height / 2;
    CGPoint endingPosition = CGPointMake(x, y);
    CCActionMoveTo *movePopover = [CCActionMoveTo actionWithDuration:0.3 position:endingPosition];
    return movePopover;
}

+ (void)fadeOutBackground:(CCNode *)background {
    CCActionFadeOut *fadeOut = [CCActionFadeOut actionWithDuration:0.3];
    [background runAction:fadeOut];
}

#pragma mark - Gameplay Scene Animations

+ (void)animateFallingCookies:(NSArray *)columns tileHeight:(CGFloat)tileHeight gameplayScene:(CCNode *)gameplayScene completion:(dispatch_block_t)completion {
    
    __block NSTimeInterval longestDuration = 0;
    
    for (NSArray *array in columns) {
        [array enumerateObjectsUsingBlock:^(BBQCookie *cookie, NSUInteger idx, BOOL *stop) {
            CGPoint newPosition = [GameplayScene pointForColumn:cookie.column row: cookie.row];
            NSTimeInterval delay = 0.5 + 0.15*idx;
            
            NSTimeInterval duration = ((cookie.sprite.position.y - newPosition.y) / tileHeight) * 0.1;
            longestDuration = MAX(longestDuration, duration + delay);
            
            CCActionMoveTo *moveAction = [CCActionMoveTo actionWithDuration:duration position:newPosition];
            CCActionSequence *sequence = [CCActionSequence actions:[CCActionDelay actionWithDuration:delay], moveAction, nil];
            [cookie.sprite runAction:sequence];
        }];
    }
    
    CCActionSequence *sequence = [CCActionSequence actions:[CCActionDelay actionWithDuration:longestDuration], [CCActionCallBlock actionWithBlock:completion], nil];
    [gameplayScene runAction:sequence];
    
}

@end
