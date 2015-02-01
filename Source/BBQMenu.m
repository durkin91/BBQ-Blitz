//
//  BBQMenu.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/24/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQMenu.h"
#import "BBQAnimations.h"



@implementation BBQMenu {
    BBQRanOutOfMovesNode *_noMoreMovesPopover;
    BBQLevelCompleteNode *_levelCompletePopover;
    BBQStartLevelNode *_startLevelPopover;
    BBQReplayNode *_replayPopover;
    CCNodeColor *_background;
}

- (void)didLoadFromCCB {
    _startLevelPopover.delegate = self;
    _levelCompletePopover.delegate = self;
    _noMoreMovesPopover.delegate = self;
    _replayPopover.delegate = self;
}


- (void)displayMenuFor:(NSString *)command {
    
    //Find the right popover
    CCNode *popover = [self findCorrectPopoverForMenu:command];
    
    
    if ([command isEqualToString:LEVEL_COMPLETE]) {
        _levelCompletePopover.yourScoreLabel.string = [NSString stringWithFormat:@"Your Score: %ld", (long)self.gameLogic.currentScore];
    }

    
    [BBQAnimations animateMenuWithBackground:_background popover:popover];
    [self.delegate removeGestureRecognizers];
    
}

- (void)dismissMenu:(NSString *)command withBackgroundFadeOut:(BOOL)wantsFadeOut {
    CCNode *popover = [self findCorrectPopoverForMenu:command];
    
    if (wantsFadeOut) {
        [BBQAnimations dismissMenuWithBackground:_background popover:popover];
        [self.delegate addGestureRecognizers];
    }
    else [BBQAnimations dismissMenuWithoutTouchingBackground:_background popover:popover];
}

- (void)dismissMenu:(NSString *)menu1 andShowMenu:(NSString *)menu2 {
    CCNode *menu1Popover = [self findCorrectPopoverForMenu:menu1];
    CCNode *menu2Popover = [self findCorrectPopoverForMenu:menu2];
    [BBQAnimations dismissMenu:menu1Popover andShowMenu:menu2Popover background:_background];
}

- (CCNode *)findCorrectPopoverForMenu:(NSString *)menuName {
    CCNode *popover;
    
    if ([menuName isEqualToString:NO_MORE_MOVES]) {
        popover = _noMoreMovesPopover;
    }
    
    else if ([menuName isEqualToString:LEVEL_COMPLETE]) {
        popover = _levelCompletePopover;
    }
    
    else if ([menuName isEqualToString:START_LEVEL]) {
        popover = _startLevelPopover;
    }
    
    else if ([menuName isEqualToString:REPLAY]) {
        popover = _replayPopover;
    }
    
    return popover;
}

#pragma mark - Button presses

//on starting popover
-(void)didPlay {
    [self dismissMenu:START_LEVEL withBackgroundFadeOut:YES];
}

//on level complete popover
- (void)didPressNext {
    [self.delegate progressToNextMaxLevel];
    [self dismissMenu:LEVEL_COMPLETE withBackgroundFadeOut:NO];
}

//when 'end game' is pressed on 'no more moves' popover
- (void)didPressEnd {
    [self dismissMenu:NO_MORE_MOVES andShowMenu:REPLAY];
}

//on replay popover
- (void)didPressReplay {
    [self.delegate replayGame];
    [self dismissMenu:REPLAY withBackgroundFadeOut:NO];
}



@end
