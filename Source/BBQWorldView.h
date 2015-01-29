//
//  BBQWorldView.h
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/29/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"
#import "BBQActiveLandingPad.h"

@interface BBQWorldView : CCNode

@property (assign, nonatomic) NSInteger currentLevel;
@property (strong, nonatomic) BBQActiveLandingPad *currentLevelLandingPad;

@end
