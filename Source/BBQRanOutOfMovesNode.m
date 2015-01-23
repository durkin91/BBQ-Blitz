//
//  BBQRanOutOfMovesNode.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQRanOutOfMovesNode.h"

@implementation BBQRanOutOfMovesNode {
    CCButton *_keepPlayingButton;
}

- (void)didLoadFromCCB {
    
    //Create the action to animate the keep playing button
    CCActionScaleTo *scaleUp = [CCActionScaleTo actionWithDuration:1.0 scale:1.05];
    CCActionScaleTo *scaleDown = [CCActionScaleTo actionWithDuration:1.0 scale:1.0];
    CCActionSequence *sequence = [CCActionSequence actions:scaleUp, scaleDown, nil];
    CCActionRepeatForever *repeat = [CCActionRepeatForever actionWithAction:sequence];
    [_keepPlayingButton runAction:repeat];
    
}

@end
