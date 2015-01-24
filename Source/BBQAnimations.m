//
//  BBQAnimations.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQAnimations.h"

@implementation BBQAnimations

+ (void)animateButton:(CCButton *)button {
    //Create the action to animate the keep playing button
    CCActionScaleTo *scaleUp = [CCActionScaleTo actionWithDuration:1.0 scale:1.05];
    CCActionScaleTo *scaleDown = [CCActionScaleTo actionWithDuration:1.0 scale:1.0];
    CCActionSequence *sequence = [CCActionSequence actions:scaleUp, scaleDown, nil];
    CCActionRepeatForever *repeat = [CCActionRepeatForever actionWithAction:sequence];
    [button runAction:repeat];
}

+ (void)animateMenuWithBackground:(CCNode *)background popover:(CCNode *)popover {
    
    //fade in background
    CCActionFadeTo *fadeIn = [CCActionFadeTo actionWithDuration:0.3 opacity:0.7];
    [background runAction:fadeIn];
    
    //move popover
    float x = background.contentSize.width / 2;
    float y = background.contentSizeInPoints.height / 2;
    CGPoint endingPosition = CGPointMake(x, y);
    
    //popoverNode.position = startingPosition;
    CCActionMoveTo *movePopover = [CCActionMoveTo actionWithDuration:0.3 position:endingPosition];
    [popover runAction:movePopover];

}

@end
