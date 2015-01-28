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

@end
