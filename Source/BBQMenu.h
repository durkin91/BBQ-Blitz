//
//  BBQMenu.h
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/24/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"
#import "BBQGameLogic.h"
#import "BBQRanOutOfMovesNode.h"
#import "BBQLevelCompleteNode.h"
#import "BBQStartLevelNode.h"
#import "BBQReplayNode.h"


#define NO_MORE_MOVES @"No More Moves"
#define LEVEL_COMPLETE @"Level Complete"
#define START_LEVEL @"Start Level"
#define REPLAY @"Replay"

@protocol BBQMenuDelegate <NSObject>

- (void)replayGame;
- (void)startNextLevel;
- (void)progressToNextMaxLevel;

@end

@interface BBQMenu : CCNode <BBQStartLevelNodeDelegate, BBQLevelCompleteNodeDelegate, BBQRanOutOfMovesNodeDelegate, BBQReplayNodeDelegate>

@property (weak, nonatomic) id <BBQMenuDelegate> delegate;
@property (strong, nonatomic) BBQGameLogic *gameLogic;

- (void)displayMenuFor:(NSString *)command;
- (void)dismissMenu:(NSString *)command withBackgroundFadeOut:(BOOL)wantsFadeOut;

@end
