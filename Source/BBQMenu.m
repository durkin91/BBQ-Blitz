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

@implementation BBQMenu {
    BBQRanOutOfMovesNode *_noMoreMovesPopover;
    CCNodeColor *_background;
}


- (void)displayMenuFor:(NSString *)command {
    
    //Find the right popover
    CCNode *popover;
    
    if ([command isEqualToString:NO_MORE_MOVES]) {
        popover = _noMoreMovesPopover;
    }
    
    [BBQAnimations animateMenuWithBackground:_background popover:popover];
    
}
@end
