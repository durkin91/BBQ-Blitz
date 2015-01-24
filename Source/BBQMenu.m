//
//  BBQMenu.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/24/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQMenu.h"
#import "BBQAnimations.h"
#import "BBQRanOutOfMovesNode.h"
#import "BBQLevelCompleteNode.h"


@implementation BBQMenu {
    BBQRanOutOfMovesNode *_noMoreMovesPopover;
    BBQLevelCompleteNode *_levelCompletePopover;
    CCNodeColor *_background;
}


- (void)displayMenuFor:(NSString *)command gameLogic:(BBQGameLogic *)gameLogic {
    
    //Find the right popover
    CCNode *popover;
    
    if ([command isEqualToString:NO_MORE_MOVES]) {
        popover = _noMoreMovesPopover;
    }
    
    else if ([command isEqualToString:LEVEL_COMPLETE]) {
        _levelCompletePopover.yourScoreLabel.string = [NSString stringWithFormat:@"Your Score: %ld", (long)gameLogic.currentScore];
        popover = _levelCompletePopover;
    }
    
    [BBQAnimations animateMenuWithBackground:_background popover:popover];
    
}
@end
