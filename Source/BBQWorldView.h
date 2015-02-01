//
//  BBQWorldView.h
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/29/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"
#import "BBQActiveLandingPad.h"
#import "GameplayScene.h"

@interface BBQWorldView : CCNode <GameplaySceneDelegate>

@property (assign, nonatomic) NSInteger currentLevel;
@property (assign, nonatomic) NSInteger maxLevel;
@property (strong, nonatomic) BBQActiveLandingPad *currentLevelLandingPad;

@end
