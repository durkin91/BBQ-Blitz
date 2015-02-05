//
//  BBQAnimations.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQAnimations.h"
#import "BBQGameLogic.h"
#import "GameplayScene.h"
#import "BBQComboModel.h"

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

+ (void)animateSwipe:(NSDictionary *)animations scoreLabel:(CCLabelTTF *)scoreLabel movesLabel:(CCLabelTTF *)movesLabel cookiesLayer:(CCNode *)cookiesLayer currentScore:(NSInteger)currentScore movesLeft:(NSInteger)movesLeft completion:(dispatch_block_t)completion {
    
    const NSTimeInterval duration = 0.4;
    
    ////**** COMBOS ACTION BLOCK ****
    
    CCActionCallBlock *performCombosAndMoveCookies = [CCActionCallBlock actionWithBlock:^{
        
        ////COMBOS
        for (BBQComboAnimation *combo in animations[COMBOS]) {
            
            //Put cookie A on top and move cookie A to cookie B, then remove cookie A
            combo.cookieA.sprite.zOrder = 100;
            combo.cookieB.sprite.zOrder = 90;
            
            CCActionMoveTo *moveA = [CCActionMoveTo actionWithDuration:duration position:[GameplayScene pointForColumn:combo.destinationColumn row:combo.destinationRow]];
            CCActionRemove *removeA = [CCActionRemove action];
            
            CCActionCallBlock *updateCountCircle = [CCActionCallBlock actionWithBlock:^{
                combo.cookieB.sprite.countCircle.visible = YES;
                combo.cookieB.sprite.countLabel.string = [NSString stringWithFormat:@"%ld", (long)combo.cookieB.count];
                
                //scale up and down
                CCActionScaleTo *scaleUp = [CCActionScaleTo actionWithDuration:0.1 scale:1.2];
                CCActionScaleTo *scaleDown = [CCActionScaleTo actionWithDuration:0.1 scale:1.0];
                CCActionSequence *scaleSequence = [CCActionSequence actions:scaleUp, scaleDown, nil];
                [combo.cookieB.sprite runAction:scaleSequence];
                
                //add particle effect
//                CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"CombineCookiesEffect"];
//                explosion.autoRemoveOnFinish = TRUE;
//                explosion.position = combo.cookieB.sprite.position;
//                [combo.cookieB.sprite.parent addChild:explosion];
                
            }];
            
            CCActionSequence *sequenceA = [CCActionSequence actions:moveA, removeA, updateCountCircle, nil];
            [combo.cookieA.sprite runAction:sequenceA];
            
        }
        
        ////MOVE COOKIES
        for (BBQMoveCookie *movement in animations[MOVEMENTS]) {
            CGPoint position = [GameplayScene pointForColumn:movement.destinationColumn row:movement.destinationRow];
            CCActionMoveTo *moveAnimation = [CCActionMoveTo actionWithDuration:duration position:position];
            [movement.cookieA.sprite runAction:moveAnimation];
        }
        
    }];
    
    ///****SCORE COMBOS****
//    CCActionCallBlock *scoreCombos = [CCActionCallBlock actionWithBlock:^{
//        NSArray *comboObjects = animations[COMBO_SCORES];
//        for (BBQComboModel *combo in comboObjects) {
//            NSString *scoreString = [NSString stringWithFormat:@"%ld", (long)combo.score];
//            CCLabelTTF *scoreLabel = [CCLabelTTF labelWithString:scoreString fontName:@"GillSans-BoldItalic" fontSize:16.0];
//            scoreLabel.position = combo.cookieB.sprite.position;
//            scoreLabel.outlineColor = [CCColor blackColor];
//            scoreLabel.outlineWidth = 1.0;
//            scoreLabel.zOrder = 300;
//            [cookiesLayer addChild:scoreLabel];
//            [self animateScoreLabel:scoreLabel];
//        }
//    }];
    
    ////**** UPDATE SCORE & MOVES ****
    CCActionCallBlock *updateScoreBlock = [CCActionCallBlock actionWithBlock:^{
        scoreLabel.string = [NSString stringWithFormat:@"%ld", (long)currentScore];
        movesLabel.string = [NSString stringWithFormat:@"%ld", (long)movesLeft];
    }];
    
    ////**** FINAL SEQUENCE ****
    CCActionSequence *finalSequence = [CCActionSequence actions:performCombosAndMoveCookies, updateScoreBlock, [CCActionCallBlock actionWithBlock:completion], nil];
    [cookiesLayer runAction:finalSequence];
}

@end
